# Chronos Seal

[English](/en/README.md) | [简体中文](./README.md)

**时序为封印 · 行为作密钥 · 岁月守护原创**

---

[![Platform](https://img.shields.io/badge/platform-NW.js%20%7C%20RPG%20Maker%20MV%2FMZ-blue)](https://nwjs.io/)
[![C++](https://img.shields.io/badge/C%2B%2B-11-blue.svg)](https://isocpp.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.2-red.svg)](CHANGELOG.md)
[![Docs](https://img.shields.io/badge/docs-docs.crclare.top-blue)](https://docs.crclare.top)

---

**适用场景**：定价 ¥12~¥60 的独立游戏，保护首发销售窗口期。

**核心哲学**：不追求绝对不可破解，而是让破解成本 > 游戏售价，从经济学层面阻止盗版传播。

**序言**：该项目完全开源免费（MIT License），欢迎各路 RM 作者直接拿去用，也欢迎各路破解者前来尝试并提交 Issue —— 你破得越深，我补得越快，这套系统就会越强，这也算是我给 RM 圈的一份 Liberty。


## V2.2 核心改进

V2.2 是 Basic 线的**定稿版本**。代码逻辑经过 13 轮修订已定型，本次更新后 Basic 进入**维护模式**。未来的重心将转向 GUI 图形化外壳与 Pro 云端验证版。

- **CSDP 增量补丁**：只加密改动文件，玩家下载几 MB 即可完成更新。解决 RM 游戏"每次更新下载几个 G"的历史难题。
- **每文件独立子密钥**：以主密钥 + 文件相对路径派生每个文件的独立密钥。单文件密钥泄露不影响其他文件。
- **字符串密文表**：关键 tag 不再以明文形式存在于二进制中。
- **构建配置头文件化**：编译期参数由 `-D` 宏传递改为生成配置文件，消除命令行转义问题。
- **CI 三重校验**：产物存在性 / 无明文泄漏 / 关键配置已编入。任一失败 → Actions 直接红。
- **移除硬过期检查**：截止日期参数已废弃，作者只需填写游戏名称与版本号。
- **运行时检测轻量化**：所有检测机制不产生行为差异，**绝不误伤正版玩家**。


## MV / MZ 引擎防护差异

V2.2 针对两个引擎版本提供两条路线，原因在于底层环境的客观差异：

| 引擎 | 防护路线 | 特征 |
|:---|:---|:---|
| **RPG Maker MV** | 纯 JS 轻量防护 | 基于 Node.js 原生 crypto 模块。零环境依赖，一键加密，100% 兼容。 |
| **RPG Maker MZ** | C++ N-API 原生加密层 | 解密负载下沉至原生二进制。性能更高、逆向门槛更强。需要云端编译。 |

选择引擎时请知悉这一差异。MV 不需要云端编译，MZ 需要 GitHub Actions 生成专属 `.node`。


## 设计哲理

Chronos Seal 不追求绝对不可破解——那在客户端环境中不存在。它追求的是：让破解的成本（时间、技术门槛、维护负担）远超游戏本身的价值，从而在经济学层面阻止盗版传播。

- **经济学博弈**：本地不存在绝对不可破解的加密。本方案旨在将破解成本提升至远超游戏售价，保护独立游戏首发的"黄金两周"。
- **种子各异**：每个作者的主种子彼此不同。破解者无法用一份通用工具吃掉所有用 Chronos Seal 的游戏——必须逐游戏逆向，这从成本模型上瓦解了"通用解包工具"的可行性。
- **零信任、零知识**：工具作者不接触、不存储任何用户密钥。
- **完全可逆**：只加密发行包，工程文件零修改。
- **绝不误伤正版玩家**：所有机制对正版玩家透明，不产生任何误判风险。


## 特性

- **原生层信任根**：核心解密逻辑在 C++ 编译二进制（`.node`）中，JS 层无密钥，F12 控制台捞不到
- **素材完整加密**：加密整个素材文件，不再是 RM 自带的仅加密前 16 字节
- **每文件独立子密钥**：以主密钥 + 文件相对路径派生，单文件泄露不影响其他文件
- **密钥运行时派生**：主密钥由版本号 + 发行日期 + 派生种子 → HMAC-SHA256 链式派生，不在任何文件中存储
- **字符串密文表**：关键 tag 不以明文形式出现在二进制中
- **素材格式带魔数**：文件头包含 `CHRNSLSE` 魔数，JS 层可快速判断是否加密文件
- **HMAC 完整性校验**：每个加密素材自带 HMAC-SHA256 签名，防止篡改（固定时间比较，防计时攻击）
- **CSDP 增量补丁**：只加密改动文件，玩家只需下载几 MB 增量包
- **云端编译**：无需本地编译环境，[GitHub Actions](https://github.com/CLARE-XHL/Chronos-Builder-Template) 一键生成专属 `.node`
- **不依赖任何外部平台**：Steam 游戏能用，免费游戏也能用


## 快速链接

| 链接 | 说明 |
|:---|:---|
| [📖 完整文档](https://docs.crclare.top) | VitePress 文档站（推荐先看） |
| [📦 主仓库](https://github.com/CLARE-XHL/Chronos-Seal) | 源码 & Releases |
| [☁️ 模板仓库](https://github.com/CLARE-XHL/Chronos-Builder-Template) | 云端编译入口 |
| [📋 Releases](https://github.com/CLARE-XHL/Chronos-Seal/releases) | 下载最新发行包 |


## 已知边界

- **Basic 线只做"首发销售窗口期防护"**，不追求"永久不可破解"——客户端加密的固有上限就在那里。
- **V2.2 是 Basic 线的终点**，除非发现安全漏洞，不会有 V2.3。
- 作者本人不承诺即时响应，但会关注社区反馈。
- **`encrypt_config.json` 与 `author_secret.txt` 是长期凭证**，丢失后无法再更新已发布的游戏。请务必离线备份。


## 反馈与协助

本版本属于**作者无环境下的定稿发布**。如果你在使用中遇到问题，欢迎反馈：

- **提交 Issue**：请附上引擎版本、操作系统、复现步骤、错误截图。
- **提交 PR**：**只接受 bug 修复**，不接受功能新增。
- **自行修改**：代码完全开放，欢迎 fork 自用。


## 许可证

本项目采用 MIT 许可证开源，详见 [LICENSE](LICENSE) 文件。

使用本软件时，请遵守以下约定：

- ✅ 允许：将 Chronos Seal 集成到你的商业或免费游戏中，闭源售卖你的游戏
- ✅ 允许：修改源码用于你自己的项目
- ✅ 允许：在遵守 MIT 协议的前提下进行分发
- ❌ 严禁：将 Chronos Seal 的源码或编译产物（`.node` 文件）作为独立商品直接售卖
- ❌ 严禁：删除或隐藏版权声明后销售 Chronos Seal 本体

**简单来说：你可以卖用了 Chronos Seal 的游戏，但不能直接卖 Chronos Seal 本身。**

---

*本声明是对 MIT 许可证的补充说明，不改变 MIT 许可证的授权条款。*


## 致谢

- [node-addon-api](https://github.com/nodejs/node-addon-api)
- [OpenSSL](https://www.openssl.org/)
- @JiuGeGe520 —— 帮忙发现初期漏洞，推动 V1.1 的 ADS 双存储方案落地
- Project 1 的 fux2 —— 指出 V1.x 版本的核心误区，促使 V2.0 彻底重构
- Project 1 的 Singular_Photon —— 指出 RM 原生素材加密的致命漏洞，推动 V2.1 素材解密下沉


## 联系方式

- 作者：CLARE-XHL
- 项目地址：[https://github.com/CLARE-XHL/Chronos-Seal](https://github.com/CLARE-XHL/Chronos-Seal)
- 文档站：[https://docs.crclare.top](https://docs.crclare.top)
- 代码签名政策请见 [CODE_SIGNING.md](./CODE_SIGNING.md)


⭐ 如果这个项目对你有帮助，请给主仓库一个 Star！
