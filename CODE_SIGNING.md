# Code Signing Policy

[English](./CODE_SIGNING.md) | [简体中文](/zh/CODE_SIGNING.md)

This project (Chronos Seal / CrCLARE related tools) adopts a code signing mechanism to ensure that binary files distributed to users are not tampered with during the build and distribution process, thereby safeguarding the system security of end users.

## 1. Scope

The following types of artifacts will apply for and apply code signing:
- Windows platform graphical interface tools (GUI version .exe)
- Precompiled native extension modules (such as .node files, subject to project requirements)
- Official release archives and their internal installers

**Note:** This project does not provide any form of dual commercial licensing. All signatures are provided free of charge to the open-source community.

## 2. Build Environment & Verifiability

- **Fully Automated Builds:** All released versions are built automatically via GitHub Actions.
- **Public Source Code:** All source code for build artifacts is fully public. Any user can verify the generation process of the final artifacts through GitHub Actions build logs and source code.
- **Isolated Builds:** Every signing request is based on a clean CI environment, requiring no local compilation by developers.
- **Immutable Commits:** Signing requests are only made for specific Git Tags, ensuring strict correspondence between the signed version and the source code version.

## 3. Signing Approval Process

- **Manual Approval Mechanism:** Every production environment signing request must be manually approved by the project maintainer (CLARE) before the signing is executed.
- **No Automated Signing:** To ensure security, no automated signing rules (e.g., commit-triggered automation) are set up, preventing malicious code from being automatically signed due to credential leakage.
- **Unique Distribution Channel:** Signed binary files are published exclusively through the official GitHub Releases page.

## 4. Certificate Issuer

The code signing certificate for this project is provided by **CrCLARE Studio**.

*Statement: This certificate is a self-signed certificate generated and maintained by CrCLARE Studio. The trusted signing subject is CrCLARE Studio, but it is explicitly associated with the official repository of this open-source project.*

*Certificate Thumbprint (ID):* `24B6F02C01DE207A4AF55AFC8EA61BE3D420B431`

## 5. Verifying Signatures

Users can verify the signature status of downloaded files through the following methods:
1. Right-click the executable file (.exe) and select "Properties".
2. Switch to the "Digital Signatures" tab and confirm that the signature is valid.
3. Advanced users can use Windows `signtool` or PowerShell's `Get-AuthenticodeSignature` command for verification.

## 6. Security Policy

If you discover any anomalies related to signing, certificate leakage, or forged signatures, please immediately contact the maintainer via `contact@crclare.top`, or submit a GitHub Security Advisory.
(For detailed security policies, please refer to [SECURITY.md](./SECURITY.md))

## 7. License

This project is open-sourced under the [MIT License](./LICENSE). Anyone can freely use, modify, and distribute it under the terms of the license.

---
**Maintainer:** CLARE (CrCLARE Studio)
**Last Updated:** 2026-09-11
