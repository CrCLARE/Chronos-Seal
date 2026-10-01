# Contributing Guide

Thank you for your willingness to contribute code, submit issues, or provide feedback for Chronos Seal. Below are the basic conventions for participating in this project. Please read this before submitting a Pull Request or Issue.

---

[English](./CONTRIBUTING.md) | [简体中文](/zh/CONTRIBUTING.md)

---

## Submitting an Issue

If you find a bug or have a feature suggestion, you are welcome to submit an Issue.

**Before submitting, please confirm:**

1. Search existing Issues to see if someone has already reported it.
2. Confirm you are using the latest version (if the issue is already fixed in the latest version, old version issues may not be addressed).
3. If it is a security issue, **do not discuss it in public Issues**. Please refer to [SECURITY.md](../SECURITY.md).

**Issue Template:**

- **Version**: The Chronos Seal version you are using.
- **Environment**: Windows version, Node.js version (if applicable).
- **Description**: What happened, and what was the expected result.
- **Reproduction Steps**: Specific steps will help locate the issue faster.
- **Logs/Screenshots**: Attach error logs or screenshots if available (**be careful not to leak keys**).

## Submitting a Pull Request

PRs to fix bugs or add new features are welcome.

**Before submitting a PR, please confirm:**

1. Fork this repository, create a new branch based on `main` for your modifications.
2. Code style should be consistent with the existing code (no need to strictly follow style guides, but don't make a mess).
3. If adding a new feature, explain its purpose and use case in the PR description.
4. If fixing a bug, link the corresponding Issue number in the PR description.
5. Ensure compilation passes (verified locally or via GitHub Actions) before submission.

**⚠️ Security Review Warning:**
If a PR modifies high-risk files: `.github/workflows/build.yml`, `binding.gyp`, `src/decryptor.cc`, or Release packaging related scripts, it will trigger a **48-hour full freeze review period**. **This is not exempt even for changes to comments, punctuation, or line breaks.**

Regular changes such as the JS hijacking layer, documentation, and example scripts undergo standard review.

**Suggested PR Description:**

- **Changes**: What you changed.
- **Motivation**: Why you changed it.
- **Testing Method**: How you verified the changes.
- **Impact Scope**: Whether existing features are affected.

## Code Style

- **C++ Code**: Maintain the existing style; no need to strictly follow Google Style or LLVM Style.
- **JavaScript**: Maintain the existing style as well.
- **Comments**: English is preferred, but Chinese is also acceptable.
- **No Over-engineering**: As long as it solves the problem, keep it simple.

## Commit Message Format

Strict formatting is not mandatory, but keeping it clear is recommended:
module: brief description of the changes
Detailed explanation (optional)
Example:decryptor: fix error handling when HMAC verification fails

## Code of Conduct

- Respect other contributors. Technical discussions can be intense, but no personal attacks.
- If you have different opinions on a solution, feel free to propose them, but please provide reasons.
- Anyone who submits code will be included in the [Contributors List](https://docs.crclare.top/guide/contributors) (unless you wish to remain anonymous).

## Reporting Security Vulnerabilities

Please refer to the process in [SECURITY.md](../SECURITY.md).

## Need Help?

- Documentation: [https://docs.crclare.top](https://docs.crclare.top)
- Main Repository: [https://github.com/CrCLARE/Chronos-Seal](https://github.com/CrCLARE/Chronos-Seal)
- Email: [contact@crclare.top](mailto:contact@crclare.top)

Thank you again for your contribution.
