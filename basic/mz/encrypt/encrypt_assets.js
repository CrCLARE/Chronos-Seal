#!/usr/bin/env node
/**
 * Chronos Seal V2.2 - Asset Encryption Tool
 *
 * 与 encrypt_assets.bat 配合使用。支持四种模式：
 *   --scan      扫描 www/ 下的待加密资源，写 _cs_scan.txt
 *   --encrypt   加密资源，写 _cs_result.txt 和 _cs_originals.txt
 *   --verify    抽样解密验证，写 _cs_verify.txt
 *   无参数      交互式模式（向后兼容 V2.1）
 *
 * 与 BAT 的约定:
 *   - JS 不自己暂停，不等待输入
 *   - 输出信息后立即以 exit code 返回
 *   - 所有临时文件写入 BAT 所在目录（当前工作目录）
 *
 * 密码学约定（必须与 C++ decryptor.cc V2.2.9 严格一致）:
 *   - 文件格式: MAGIC(8) + VERSION(1) + IV(16) + HMAC(32) + ciphertext
 *   - HMAC 覆盖 VERSION + IV + ciphertext
 *   - 种子重建: 8 轮循环混合（仅用 seed / seedSalt）
 *   - 主密钥派生: 4 层链式 HMAC
 *   - 子密钥派生: 4 层链式 HMAC
 *   - 路径归一化: 反斜杠转正斜杠，ASCII 大写转小写（与 C++ std::tolower 对齐）
 *   - 单文件上限: 50 MB（与 C++ MAX_ASSET_SIZE 一致）
 *
 * 职责边界:
 *   - 本工具只处理 www/ 里的资源加密
 *   - 不生成 manifest.json（增量补丁由 patch_builder.js 独立管理）
 *   - 不碰源工程
 *
 * V2.2.9 修订:
 *   - 删除 seedMask 依赖（与 CI/workflow 对齐）
 *   - normalizePath 改为 ASCII 显式转换，与 C++ 语义一致
 *   - openNativeSession 显式传参 + 返回 {handle, mod}
 *   - --verify 抽样数提升到 10
 *   - 移除 manifest 生成逻辑（与 patch_builder 完全解耦）
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ============================================================
// 常量（必须与 C++ 端严格一致）
// ============================================================

const ASSET_VERSION = 0x01;
const MAGIC = Buffer.from('CHRNSLSE', 'ascii');
const IV_LEN = 16;
const HMAC_LEN = 32;
const AES_KEY_LEN = 32;

// 单文件上限必须与 C++ 端 MAX_ASSET_SIZE 严格一致。
const MAX_ASSET_SIZE = 50 * 1024 * 1024;

const TARGET_EXTENSIONS = [
    '.png', '.jpg', '.jpeg', '.webp', '.bmp', '.gif',
    '.ogg', '.m4a', '.mp3', '.wav'
];

const WWW_DIR_NAME = 'www';

const SCAN_FILE = '_cs_scan.txt';
const RESULT_FILE = '_cs_result.txt';
const VERIFY_FILE = '_cs_verify.txt';
const ORIGINALS_FILE = '_cs_originals.txt';

// --verify 抽样数量上限（含首条）
const VERIFY_SAMPLE_MAX = 10;

const LOG_PREFIX = '[ChronosSeal]';

// ============================================================
// 日志辅助
// ============================================================

function logInfo(msg)  { console.log(LOG_PREFIX + ' [INFO] ' + msg); }
function logOK(msg)    { console.log(LOG_PREFIX + ' [OK] ' + msg); }
function logWarn(msg)  { console.log(LOG_PREFIX + ' [WARN] ' + msg); }
function logError(msg) { console.error(LOG_PREFIX + ' [ERROR] ' + msg); }

// ============================================================
// 路径工具
// ============================================================

/**
 * 路径归一化：反斜杠 → 正斜杠，ASCII 大写转小写。
 *
 * 必须与 C++ normalize_path 逐字节一致：
 *   - C++ 用 std::tolower(static_cast<unsigned char>(c))
 *   - 这是 ASCII 语义，非 ASCII 字节原样保留
 *   - JS 的 String.prototype.toLowerCase() 是 Unicode aware，
 *     对 'İ' 等字符会改变字节长度，与 C++ 不一致
 *   - 因此这里显式用 charCodeAt 判断 ASCII 范围
 */
function normalizePath(p) {
    let out = '';
    for (let i = 0; i < p.length; i++) {
        const c = p.charCodeAt(i);
        if (c === 0x5C) {                      // '\\'
            out += '/';
        } else if (c >= 0x41 && c <= 0x5A) {   // 'A'~'Z'
            out += String.fromCharCode(c + 0x20);
        } else {
            out += String.fromCharCode(c);
        }
    }
    return out;
}

function toBatchPath(rootDir, fullPath) {
    const rel = path.relative(rootDir, fullPath);
    return rel.replace(/\//g, '\\');
}

function toDerivationPath(wwwRelative) {
    return normalizePath(wwwRelative);
}

// ============================================================
// 种子重建（8 轮循环混合，仅用 salt）
//
// 必须与 C++ V2.2.9 reconstruct_seed 逐字节一致。
// ============================================================

function reconstructSeed(rawSeed, salt) {
    const buf = Buffer.from(rawSeed, 'binary');

    for (let round = 0; round < 8; round++) {
        // C++: s = SEED_SALT ^ (round * 0x9E3779B9u)
        let s = (salt ^ Math.imul(round, 0x9E3779B9)) >>> 0;

        for (let i = 0; i < buf.length; i++) {
            // C++: s = s * 1664525u + 1013904223u
            s = (Math.imul(s, 1664525) + 1013904223) >>> 0;

            let v = buf[i] & 0xFF;

            // C++: v ^= (s >> 24) & 0xFF
            v = (v ^ ((s >>> 24) & 0xFF)) & 0xFF;

            // C++: v = ((v << 3) | (v >> 5)) & 0xFF
            v = (((v << 3) | (v >>> 5)) & 0xFF) >>> 0;

            // C++: v = (v + ((s >> 16) & 0xFF)) & 0xFF
            v = ((v + ((s >>> 16) & 0xFF)) & 0xFF) >>> 0;

            // C++: v ^= (s >> 8) & 0xFF
            v = (v ^ ((s >>> 8) & 0xFF)) & 0xFF;

            buf[i] = v;
        }
    }

    return buf;
}

// ============================================================
// 主密钥派生（4 层链式 HMAC）
//
// 必须与 C++ V2.2.9 derive_master_key_uncached 逐字节一致。
// ============================================================

function deriveMasterKey(seedBuf, version, date) {
    const k1 = crypto.createHmac('sha256', seedBuf)
        .update('MASTER:' + version + date).digest();

    const k2 = crypto.createHmac('sha256', seedBuf)
        .update(Buffer.concat([Buffer.from('STAGE2:'), k1])).digest();

    const k3 = crypto.createHmac('sha256', k1)
        .update(Buffer.concat([Buffer.from('STAGE3:'), k2])).digest();

    return crypto.createHmac('sha256', k3)
        .update('MASTER:FINAL').digest();
}

// ============================================================
// 子密钥派生（4 层链式 HMAC × 2）
//
// 必须与 C++ V2.2.9 derive_sub_aes_key / derive_sub_hmac_key 一致。
// 加密端不包含调试器污染逻辑（污染只发生在解密时的运行时数据流）。
// ============================================================

function deriveSubKeys(masterKey, relativePath) {
    const norm = normalizePath(relativePath);

    // ---- AES 子密钥 ----
    const as1 = crypto.createHmac('sha256', masterKey)
        .update('AES:S1:' + norm).digest();

    const as2 = crypto.createHmac('sha256', masterKey)
        .update(Buffer.concat([Buffer.from('AES:S2:'), as1])).digest();

    const as3 = crypto.createHmac('sha256', as1)
        .update(Buffer.concat([Buffer.from('AES:S3:'), as2])).digest();

    const aesKey = crypto.createHmac('sha256', as3)
        .update('AES:FINAL:' + norm).digest();

    // ---- HMAC 子密钥 ----
    const hs1 = crypto.createHmac('sha256', masterKey)
        .update('HMAC:S1:' + norm).digest();

    const hs2 = crypto.createHmac('sha256', masterKey)
        .update(Buffer.concat([Buffer.from('HMAC:S2:'), hs1])).digest();

    const hs3 = crypto.createHmac('sha256', hs1)
        .update(Buffer.concat([Buffer.from('HMAC:S3:'), hs2])).digest();

    const hmacKey = crypto.createHmac('sha256', hs3)
        .update('HMAC:FINAL:' + norm).digest();

    return { aesKey, hmacKey };
}

// ============================================================
// 单文件加密
// ============================================================

function encryptAsset(plaintext, relativePath, masterKey) {
    if (plaintext.length > MAX_ASSET_SIZE) {
        throw new Error('File too large: ' + plaintext.length +
            ' > ' + MAX_ASSET_SIZE);
    }

    const { aesKey, hmacKey } = deriveSubKeys(masterKey, relativePath);

    // 随机 IV
    const iv = crypto.randomBytes(IV_LEN);

    // AES-256-CBC 加密
    const cipher = crypto.createCipheriv('aes-256-cbc', aesKey, iv);
    const ciphertext = Buffer.concat([cipher.update(plaintext), cipher.final()]);

    // HMAC 覆盖 VERSION + IV + ciphertext（顺序必须与 C++ 一致）
    const versionByte = Buffer.from([ASSET_VERSION]);
    const hmac = crypto.createHmac('sha256', hmacKey);
    hmac.update(versionByte);
    hmac.update(iv);
    hmac.update(ciphertext);
    const tag = hmac.digest();

    // 组装: MAGIC(8) + VERSION(1) + IV(16) + HMAC(32) + ciphertext
    return Buffer.concat([MAGIC, versionByte, iv, tag, ciphertext]);
}

// ============================================================
// 配置加载
// ============================================================

function loadConfig(rootDir) {
    const configPath = path.join(rootDir, 'encrypt_config.json');
    if (!fs.existsSync(configPath)) {
        throw new Error('encrypt_config.json not found');
    }

    let cfg;
    try {
        cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    } catch (e) {
        throw new Error('encrypt_config.json parse failed: ' + e.message);
    }

    // seedMask 已废弃：C++ reconstruct_seed 只使用 seedSalt。
    // 保留在 config 里也不会被读取，但不再强制要求存在。
    const required = ['seed', 'seedSalt', 'version', 'date'];
    for (const field of required) {
        if (cfg[field] === undefined || cfg[field] === null) {
            throw new Error('encrypt_config.json missing field: ' + field);
        }
    }

    return cfg;
}

// ============================================================
// 文件扫描
// ============================================================

function shouldEncrypt(fullPath) {
    if (fullPath.endsWith('.enc')) return false;

    const ext = path.extname(fullPath).toLowerCase();
    if (TARGET_EXTENSIONS.indexOf(ext) < 0) return false;

    // 幂等：已存在 .enc 则跳过
    if (fs.existsSync(fullPath + '.enc')) return false;

    return true;
}

function walkDir(dir, results) {
    let entries;
    try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (e) {
        return;
    }

    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            walkDir(fullPath, results);
        } else if (entry.isFile()) {
            if (shouldEncrypt(fullPath)) {
                results.push(fullPath);
            }
        }
    }
}

function scanAssets(rootDir) {
    const wwwDir = path.join(rootDir, WWW_DIR_NAME);
    if (!fs.existsSync(wwwDir)) {
        throw new Error(WWW_DIR_NAME + '/ not found');
    }

    const results = [];
    walkDir(wwwDir, results);
    return results;
}

// ============================================================
// Native 模块加载（--verify 模式需要）
// ============================================================

let _session = null;

function loadNativeModule(rootDir) {
    const candidates = [
        path.join(rootDir, 'decryptor.node'),
        path.join(rootDir, 'js', 'decryptor.node')
    ];

    for (const p of candidates) {
        if (fs.existsSync(p)) {
            return require(p);
        }
    }

    throw new Error('decryptor.node not found');
}

/**
 * 打开 native 会话。显式传 rootDir，不依赖 process.cwd()。
 * 返回 { handle, mod }，不通过副作用暴露 _decryptor。
 */
function openNativeSession(rootDir) {
    if (_session) return _session;

    const mod = loadNativeModule(rootDir);
    const handle = { token: 'encrypt_tool_session', createdAt: Date.now() };
    const result = mod.initialize(handle);

    if (!result || !result.success) {
        throw new Error('decryptor.initialize failed: ' +
            (result ? result.errorCode : 'unknown'));
    }

    _session = { handle, mod };
    return _session;
}

// ============================================================
// 模式：--scan
// ============================================================

function modeScan() {
    const rootDir = process.cwd();

    logInfo('Scanning ' + WWW_DIR_NAME + '/ for asset files...');

    let files;
    try {
        files = scanAssets(rootDir);
    } catch (e) {
        logError(e.message);
        process.exit(1);
    }

    logInfo('Found ' + files.length + ' candidate file(s).');

    const scanPath = path.join(rootDir, SCAN_FILE);
    fs.writeFileSync(scanPath, String(files.length), 'utf8');
    logInfo('Scan result written to ' + SCAN_FILE + '.');

    process.exit(0);
}

// ============================================================
// 模式：--encrypt
// ============================================================

function modeEncrypt() {
    const rootDir = process.cwd();

    let cfg;
    try {
        cfg = loadConfig(rootDir);
    } catch (e) {
        logError(e.message);
        process.exit(1);
    }

    logInfo('Game: ' + (cfg.gameName || '(unnamed)'));
    logInfo('Version: ' + cfg.version);
    logInfo('Date: ' + cfg.date);

    let masterKey;
    try {
        const seedBuf = reconstructSeed(cfg.seed, cfg.seedSalt);
        masterKey = deriveMasterKey(seedBuf, cfg.version, cfg.date);
    } catch (e) {
        logError('Key derivation failed: ' + e.message);
        process.exit(1);
    }

    const fingerprint = crypto.createHash('sha256')
        .update(masterKey).digest('hex').slice(0, 16);
    logInfo('Master key fingerprint: ' + fingerprint);

    let files;
    try {
        files = scanAssets(rootDir);
    } catch (e) {
        logError(e.message);
        process.exit(1);
    }

    if (files.length === 0) {
        logWarn('No files to encrypt.');
        fs.writeFileSync(path.join(rootDir, RESULT_FILE), '0,0', 'utf8');
        fs.writeFileSync(path.join(rootDir, ORIGINALS_FILE), '', 'utf8');
        process.exit(0);
    }

    logInfo('Encrypting ' + files.length + ' file(s)...');

    const wwwDir = path.join(rootDir, WWW_DIR_NAME);
    const originals = [];
    let success = 0;
    let fail = 0;

    const progressStep = files.length >= 100
        ? 100
        : Math.max(1, Math.floor(files.length / 10));

    for (const fullPath of files) {
        const wwwRel = path.relative(wwwDir, fullPath).replace(/\\/g, '/');
        const batchRel = toBatchPath(rootDir, fullPath);

        try {
            const plaintext = fs.readFileSync(fullPath);
            const encrypted = encryptAsset(plaintext, wwwRel, masterKey);

            const encPath = fullPath + '.enc';
            fs.writeFileSync(encPath, encrypted);

            originals.push(batchRel);
            success++;

            if (success % progressStep === 0 && success < files.length) {
                logInfo('Encrypted ' + success + '/' + files.length);
            }
        } catch (e) {
            fail++;
            logError('Failed: ' + wwwRel + ' - ' + e.message);
        }
    }

    logInfo('Encrypted ' + success + '/' + files.length + ' file(s).');

    fs.writeFileSync(path.join(rootDir, RESULT_FILE),
        success + ',' + fail, 'utf8');
    fs.writeFileSync(path.join(rootDir, ORIGINALS_FILE),
        originals.join('\r\n'), 'utf8');

    logInfo('Result written to ' + RESULT_FILE + '.');
    logInfo('Original file list written to ' + ORIGINALS_FILE + '.');

    process.exit(fail > 0 ? 1 : 0);
}

// ============================================================
// 模式：--verify
// ============================================================

function modeVerify() {
    const rootDir = process.cwd();

    const originalsPath = path.join(rootDir, ORIGINALS_FILE);
    if (!fs.existsSync(originalsPath)) {
        logError('Original file list not found: ' + ORIGINALS_FILE);
        process.exit(1);
    }

    const raw = fs.readFileSync(originalsPath, 'utf8');
    const lines = raw.split(/\r?\n/).map(s => s.trim()).filter(s => s.length > 0);

    if (lines.length === 0) {
        logWarn('No original files listed. Skipping verification.');
        fs.writeFileSync(path.join(rootDir, VERIFY_FILE), '0/0 passed', 'utf8');
        process.exit(0);
    }

    // 抽样数量：首条 + (VERIFY_SAMPLE_MAX - 1) 条随机，最多取总数
    const sampleCount = Math.min(VERIFY_SAMPLE_MAX, lines.length);

    logInfo('Verifying ' + sampleCount + ' of ' + lines.length + ' file(s)...');

    let session;
    try {
        session = openNativeSession(rootDir);
    } catch (e) {
        logError(e.message);
        process.exit(1);
    }

    const mod = session.mod;
    const handle = session.handle;

    // 组装抽样索引：0 优先，再补不重复的随机索引
    const indices = [0];
    if (sampleCount > 1) {
        const pool = new Set();
        while (pool.size < sampleCount - 1) {
            const idx = 1 + Math.floor(Math.random() * (lines.length - 1));
            pool.add(idx);
        }
        for (const idx of pool) indices.push(idx);
    }

    const wwwDir = path.join(rootDir, WWW_DIR_NAME);
    let passed = 0;

    for (const idx of indices) {
        const batchRel = lines[idx];
        const fullPath = path.join(rootDir, batchRel);
        const encPath = fullPath + '.enc';

        if (!fs.existsSync(fullPath)) {
            logError('Original missing: ' + batchRel);
            process.exit(1);
        }
        if (!fs.existsSync(encPath)) {
            logError('Encrypted missing: ' + batchRel + '.enc');
            process.exit(1);
        }

        const wwwRel = path.relative(wwwDir, fullPath).replace(/\\/g, '/');
        const derivationPath = toDerivationPath(wwwRel);

        logInfo('Verifying [' + (passed + 1) + '/' + sampleCount + ']: ' + wwwRel);

        try {
            const encrypted = fs.readFileSync(encPath);
            const result = mod.decryptAsset(encrypted, derivationPath, handle);

            if (!result || !result.ok || !result.data) {
                logError('  Decrypt failed, errCode=' +
                    (result ? result.errCode : 'unknown'));
                process.exit(1);
            }

            const original = fs.readFileSync(fullPath);
            const hashA = crypto.createHash('sha256').update(original).digest('hex');
            const hashB = crypto.createHash('sha256').update(result.data).digest('hex');

            if (hashA !== hashB) {
                logError('  Hash mismatch.');
                logError('    Original: ' + hashA);
                logError('    Decrypted: ' + hashB);
                process.exit(1);
            }

            logInfo('  Decrypt OK, hash match.');
            passed++;
        } catch (e) {
            logError('  Exception: ' + e.message);
            process.exit(1);
        }
    }

    logInfo('All ' + passed + ' sample(s) verified.');

    fs.writeFileSync(path.join(rootDir, VERIFY_FILE),
        passed + '/' + sampleCount + ' passed', 'utf8');

    process.exit(0);
}

// ============================================================
// 模式：无参数（交互模式）
// ============================================================

function modeInteractive() {
    console.log('');
    console.log('Chronos Seal V2.2 - Interactive Mode');
    console.log('');
    console.log('This tool is normally invoked by encrypt_assets.bat.');
    console.log('If you are running it directly, use one of:');
    console.log('');
    console.log('  node encrypt_assets.js --scan      Scan for asset files');
    console.log('  node encrypt_assets.js --encrypt   Encrypt all assets');
    console.log('  node encrypt_assets.js --verify    Verify encrypted assets');
    console.log('');
    console.log('For guided operation, run encrypt_assets.bat instead.');
    console.log('');
    process.exit(0);
}

// ============================================================
// 入口
// ============================================================

function main() {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        modeInteractive();
        return;
    }

    if (args.indexOf('--scan') >= 0) {
        modeScan();
        return;
    }
    if (args.indexOf('--encrypt') >= 0) {
        modeEncrypt();
        return;
    }
    if (args.indexOf('--verify') >= 0) {
        modeVerify();
        return;
    }
    if (args.indexOf('--help') >= 0 || args.indexOf('-h') >= 0) {
        modeInteractive();
        return;
    }

    logError('Unknown mode: ' + args.join(' '));
    logError('Use --scan, --encrypt, --verify, or --help.');
    process.exit(1);
}

main();
