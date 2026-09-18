# 代码签名政策 (Code Signing Policy)

[English](/CODE_SIGNING.md) | [简体中文](./CODE_SIGNING.md)

本项目（Chronos Seal / CrCLARE 相关工具）采用代码签名机制，以确保分发给用户的二进制文件在构建和分发过程中未被篡改，保障最终用户的系统安全。

## 1. 签名范围 (Scope)

以下类型的产物将申请并应用代码签名：
- Windows 平台的图形界面工具（GUI 版 .exe）
- 预编译的原生扩展模块（如 .node 文件，视工程需要而定）
- 官方发布的压缩包及其内部的安装程序

**注意：** 本项目不提供任何形式的商业双重授权，所有签名均免费提供给开源社区使用。

## 2. 构建环境与可验证性 (Build Environment & Verifiability)

- **完全自动化构建：** 所有发布版本均通过 GitHub Actions 进行自动化构建。
- **源码公开：** 构建产物的所有源代码均完全公开。任何用户都可以通过 GitHub Actions 的构建日志和源码，自行验证最终产物的生成过程。
- **构建隔离：** 每一次签名请求均基于干净的 CI 环境，无需开发者在本地编译。
- **不可变提交：** 签名请求仅针对特定的 Git Tag（版本标签）进行，确保签名版本与源码版本严格对应。

## 3. 签名审批流程 (Signing Approval Process)

- **人工审批机制：** 每一个生产环境的签名请求，必须由项目维护者（CLARE）进行手动审批，确认无误后方可执行签名。
- **禁止自动签名：** 为确保安全性，不设置任何自动签名规则（例如基于 commit 的自动触发），避免因凭据泄露导致恶意代码被自动签名。
- **唯一的发布渠道：** 签名后的二进制文件仅通过官方 GitHub Releases 页面发布。

## 4. 证书颁发者 (Certificate Issuer)

本项目的代码签名证书由 **CrCLARE Studio** 提供。

*声明：该证书由 CrCLARE Studio 生成并维护的自签名证书。受信任的签名主体为 CrCLARE Studio，但明确关联到本开源项目的官方仓库。*

*证书指纹 (ID)：* `24B6F02C01DE207A4AF55AFC8EA61BE3D420B431`

## 5. 验证签名 (Verifying Signatures)

用户可以通过以下方式验证下载文件的签名状态：
1. 右键点击可执行文件（.exe），选择“属性”。
2. 切换到“数字签名”选项卡，确认签名有效。
3. 高级用户可使用 Windows `signtool` 或 PowerShell 的 `Get-AuthenticodeSignature` 命令进行校验。

## 6. 安全政策 (Security Policy)

如果您发现任何与签名相关的异常、证书泄露或伪造签名的情况，请务必立即通过 `contact@crclare.top` 联系维护者，或提交 GitHub Security Advisories。
（详细安全政策请参阅 [SECURITY.md](./SECURITY.md)）

## 7. 许可证 (License)

本项目采用 [MIT 许可证](./LICENSE) 开源协议。任何人都可以在遵守协议的前提下自由使用、修改和分发。

---
**维护者：** CLARE (CrCLARE Studio)
**最后更新：** 2026-09-16
