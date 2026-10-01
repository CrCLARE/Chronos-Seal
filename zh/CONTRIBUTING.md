# 贡献指南

感谢你愿意为 Chronos Seal 贡献代码、提交 Issue 或提供反馈。以下是参与本项目的一些基本约定，请在提交 Pull Request 或 Issue 前阅读。

---

[English](/CONTRIBUTING.md) | [简体中文](./CONTRIBUTING.md)

---

## 提交 Issue

如果你发现了 Bug，或者有功能建议，欢迎提交 Issue。

**提交前请先确认：**

1. 搜索已有的 Issue，看看是否有人已经提过
2. 确认你使用的是最新版本（如果问题在最新版已修复，旧版 Issue 可能不会被处理）
3. 如果是安全问题，**请不要在公开 Issue 中讨论**，请参考 [SECURITY.md](../SECURITY.md)

**Issue 模板：**

- **版本号**：你使用的 Chronos Seal 版本
- **环境**：Windows 版本、Node.js 版本（如果适用）
- **问题描述**：发生了什么，你期望的结果是什么
- **复现步骤**：如果能提供具体步骤，会更快定位问题
- **日志/截图**：如果有错误日志或截图，可以附上（**注意不要泄露密钥**）

## 提交 Pull Request

欢迎提交 PR 修复 Bug 或添加新功能。

**PR 提交前请确认：**

1. Fork 本仓库，在 `main` 分支上创建新分支进行修改
2. 代码风格与现有代码保持一致（不需要严格遵守代码规范，但不要乱成一团）
3. 如果有新增功能，请在 PR 描述中说明用途和使用场景
4. 如果修复了 Bug，请在 PR 描述中关联对应的 Issue 编号
5. 提交前确认编译通过（本地或 GitHub Actions 验证）

**⚠️ 安全审查提示：**
如果 PR 改动高风险文件：`.github/workflows/build.yml`、`binding.gyp`、`src/decryptor.cc`、Release 打包相关脚本，会执行 **48 小时全员冻结审查**，**即使仅修改注释、标点、换行也不豁免**。

JS 劫持层、文档、示例脚本等普通变更执行常规审核。

**PR 描述建议包含：**

- **改动内容**：你改了什么
- **动机**：为什么要改
- **测试方式**：你如何验证改动有效
- **影响范围**：是否会影响已有功能

## 代码风格

- **C++ 代码**：保持现有风格即可，不需要严格遵循 Google Style 或 LLVM Style
- **JavaScript**：同样保持现有风格
- **注释**：尽量用英文，中文也可以接受
- **不需要过度设计**：能解决问题就好

## 提交消息格式

不强制要求严格的格式，但建议保持清晰：

模块: 简要描述改动内容

详细说明（可选）


示例：

decryptor: 修复 HMAC 校验失败时的错误处理


## 行为准则

- 尊重其他贡献者，技术讨论可以激烈，但不要人身攻击
- 如果对某个方案有不同意见，欢迎提出，但请给出理由
- 任何提交代码的人，都会被收录到 [贡献者名单](https://docs.crclare.top/guide/contributors) 中（除非你希望匿名）

## 安全漏洞报告

请参考 [SECURITY.md](../SECURITY.md) 中的安全漏洞报告流程。

## 需要帮助？

- 文档站：[https://docs.crclare.top](https://docs.crclare.top)
- 主仓库：[https://github.com/CrCLARE/Chronos-Seal](https://github.com/CrCLARE/Chronos-Seal)
- 邮箱：[contact@crclare.top](mailto:contact@crclare.top)

再次感谢你的贡献。
