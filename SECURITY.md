# Security Policy

**Time as the seal · Action as the key · Time itself guards originality**

---

[English](./SECURITY.md) | [简体中文](/zh/SECURITY.md)

---

## Reporting a Vulnerability

Chronos Seal takes every security vulnerability seriously. If you discover a security issue, please follow the process below:

### Reporting Channels

**Recommended: GitHub Security Advisories**
1. Visit [https://github.com/CrCLARE/Chronos-Seal/security/advisories/new](https://github.com/CrCLARE/Chronos-Seal/security/advisories/new)
2. Click "Report a vulnerability"
3. Fill in the vulnerability description, affected versions, reproduction steps, etc.
4. I will respond and handle it within **72 hours** of receipt.

**Alternative: Email**
If GitHub Security Advisories are not accessible, you can also reach out via email.
- **Email**: [contact@crclare.top](mailto:contact@crclare.top)
- **GPG Public Key Fingerprint**: `7360A9A8B36BCA6D73B26D38DC22E64108B24CD3`
- **How to obtain the public key**:
  - Import from keyserver: `gpg --keyserver keys.openpgp.org --recv-keys 7360A9A8B36BCA6D73B26D38DC22E64108B24CD3`
  - Or visit [keys.openpgp.org](https://keys.openpgp.org) and search for `contact@crclare.top`

It is recommended to encrypt sensitive content with GPG before sending to ensure communication security.

### Information to Include

To help locate and fix the issue as quickly as possible, please include:
- A brief description of the vulnerability
- Affected version range
- Reproduction steps (as detailed as possible, POC or code attached is welcome)
- Potential impact
- Your contact information (optional)

### Processing Flow

1. **Acknowledge**: I will confirm the vulnerability within 72 hours of receipt.
2. **Evaluate**: Assess the validity and impact scope of the vulnerability.
3. **Fix**: Formulate a fix plan based on severity.
4. **Publish**: Once fixed, a new version will be released with notes in the changelog.

### Disclosure Policy

- After the fix is complete, vulnerability details will be disclosed in GitHub Security Advisories.
- If you wish to remain anonymous, please state so in your report.
- Please do not publicly disclose vulnerability details before the fixed version is released.
- For fixed issues, public discussion after release is encouraged to help the community better understand risks and improve overall security awareness.

### Bug Bounty

Chronos Seal is an open-source project and currently does not have a bug bounty program. However, I will acknowledge every security researcher who reports a vulnerability in the changelog. You are also welcome to participate in PR review work.

## Defense Strategy

To prevent supply chain poisoning attacks (referencing the XZ Utils backdoor incident), this project implements strict PR review processes for high-risk files. For detailed rules, please refer to [CONTRIBUTING.md](https://github.com/CrCLARE/Chronos-Seal/blob/main/CONTRIBUTING.md).

### High-Risk File List
**Any changes to the following files (including comments, line breaks, punctuation, format adjustments — no exemptions)** will trigger a **48-hour full freeze review period** for the PR:
- `.github/workflows/build.yml` — CI build pipeline, vcpkg dependencies, compilation environment configuration
- `binding.gyp` — N-API native module build configuration, link libraries, compilation flags
- `src/decryptor.cc` — AES-256-CBC core decryption logic, N-API interface, memory handling
- All Release packaging, artifact upload related scripts/workflows

### Review Constraints
1. `force-push` to rewrite PR history is prohibited during the freeze period; a forced push will reset the 48-hour timer.
2. PRs submitted by the maintainer are equally subject to this rule; **self-merging of high-risk files is prohibited**.
3. Review is not just reading diff text; it requires local compilation, encryption-decryption round-trip verification, and binary runtime behavior validation.

> **Regular Changes**: JS hijacking layer, documentation, example scripts, auxiliary tools — these undergo standard PR review and are not subject to the 48-hour freeze constraint.

### 🚨 Emergency Break-glass Clause
Given that the project is in its early stages and the owner (@CLARE-XHL) is currently the sole core maintainer, to avoid the inability to promptly fix catastrophic vulnerabilities:
1. **Conditions for Activation**: Only activated when a high-risk 0-day vulnerability, supply chain attack, or severe key leak incident occurs.
2. **Action**: The owner is authorized to initiate an emergency PR and merge it before the 48-hour freeze expires.
3. **Post-Mortem**: Within 24 hours after the emergency merge, the owner must publish a detailed post-mortem report explaining the reason and content of the emergency merge.
4. **Daily Limit**: For daily non-emergency submissions, the owner still abides by the 48-hour freeze and must not self-approve.

## Security Updates

- All security updates will be published on the [Releases](https://github.com/CrCLARE/Chronos-Seal/releases) page.
- Always use the latest stable version.
- Security vulnerabilities in older versions may not be fixed; please upgrade promptly.

## Contact

- Email: [contact@crclare.top](mailto:contact@crclare.top)
- GitHub Security Advisories: Preferred method.
