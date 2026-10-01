# 安全策略

**时间作封印 · 行动作密钥 · 时间本身守护原创**

---

[English](/SECURITY.md) | [简体中文](./SECURITY.md)

---

## 报告安全漏洞

Chronos Seal 重视每一个安全漏洞的发现和修复。如果你发现了安全漏洞，请按照以下流程报告：

### 报告渠道

**推荐渠道：GitHub Security Advisories**
1. 访问 [https://github.com/CrCLARE/Chronos-Seal/security/advisories/new](https://github.com/CrCLARE/Chronos-Seal/security/advisories/new)
2. 点击“Report a vulnerability”
3. 填写漏洞描述、影响版本、复现步骤等信息
4. 提交后，我会在看到后的 **72 小时内**响应并处理

**备选渠道：邮箱**
如果无法使用 GitHub Security Advisories，也可以通过邮箱联系。
- **邮箱**：[contact@crclare.top](mailto:contact@crclare.top)
- **GPG 公钥指纹**：`7360A9A8B36BCA6D73B26D38DC22E64108B24CD3`
- **公钥获取方式**：
  - 从公钥服务器导入：`gpg --keyserver keys.openpgp.org --recv-keys 7360A9A8B36BCA6D73B26D38DC22E64108B24CD3`
  - 或访问 [keys.openpgp.org](https://keys.openpgp.org) 搜索 `contact@crclare.top`

建议使用 GPG 加密敏感内容后发送，以确保通信安全。

### 报告时应提供的信息

为帮助尽快定位和修复问题，建议包含以下内容：
- 漏洞的简要描述
- 影响的版本范围
- 复现步骤（尽量详细，可附代码或 POC）
- 漏洞可能造成的影响
- 你的联系方式（可选）

### 处理流程

1. **确认**：收到报告后，我会在收到后的 72 小时内确认漏洞
2. **评估**：确认漏洞的有效性和影响范围
3. **修复**：根据漏洞严重程度，制定修复计划
4. **发布**：修复完成后，会发布新版本并在更新日志中注明

### 漏洞披露

- 修复完成后，会在 GitHub Security Advisories 中公开漏洞详情
- 如果你希望匿名，请在报告中说明
- 修复版本发布前，请勿公开披露漏洞细节
- 对于已修复的安全问题，我们鼓励在发布后公开讨论，以帮助社区更好地理解风险并提升整体安全意识

### 漏洞赏金

Chronos Seal 是一个开源项目，目前没有设置漏洞赏金计划。但我会在更新日志中致谢每一位报告漏洞的安全研究员。同时，你也可以参与关于 PR 的审查工作。

## 防御策略

为防止供应链投毒攻击（参考 XZ Utils 后门事件），本项目对高风险文件实施严格的 PR 审查流程。详细规则请参考 [CONTRIBUTING.md](https://github.com/CrCLARE/Chronos-Seal/blob/main/CONTRIBUTING.md)。

### 高风险文件清单
以下文件**任何变更（包含注释、换行、标点、格式调整，不豁免）**，PR 将进入 **48小时全员冻结审查期**：
- `.github/workflows/build.yml` — CI构建流水线、vcpkg依赖、编译环境配置
- `binding.gyp` — N-API原生模块构建配置、链接库、编译标志
- `src/decryptor.cc` — AES-256-CBC核心解密逻辑、N-API接口、内存处理
- 所有 Release 打包、产物上传相关脚本/工作流

### 审查约束
1. 冻结期间禁止 `force-push` 重写PR历史；发生强制推送则重置48小时计时。
2. 维护者本人提交的PR同样适用本规则，**禁止自我合并高风险文件**。
3. 审查不只是阅读diff文本，必须本地编译，执行加密-解密往返校验，验证二进制运行行为。

> **普通变更**：JS劫持层、文档、示例脚本、辅助工具，执行常规PR审核，不受48h冻结约束。

### 🚨 紧急破窗条款
鉴于当前项目处于初期，且项目所有者（@CLARE-XHL）为唯一核心维护者，为避免灾难性漏洞无法及时修复：
1. **触发条件**：当且仅当发生高危 0day 漏洞、供应链攻击或严重密钥泄露事故时启用。
2. **执行方式**：所有者有权发起紧急 PR 并在未满 48 小时的情况下合并。
3. **事后复盘**：紧急合并后，所有者必须在 24 小时内发布详细的事后复盘（Post-mortem）报告，说明紧急合并的原因和改动内容。
4. **日常限制**：日常非紧急提交，所有者依然遵守 48 小时冻结，且不得自我批准。

## 安全更新

- 所有安全更新会发布在 [Releases](https://github.com/CrCLARE/Chronos-Seal/releases) 页面
- 建议始终使用最新稳定版本
- 旧版本的安全漏洞可能不会修复，请及时升级

## 联系方式

- 邮箱：[contact@crclare.top](mailto:contact@crclare.top)
- GitHub Security Advisories：优先使用
