# Chronos Seal

**Time as the seal · Action as the key · Time itself guards originality**

---

[English](./README.md) | [简体中文](/zh/README.md)

---

[![Platform](https://img.shields.io/badge/platform-NW.js%20%7C%20RPG%20Maker%20MV%2FMZ-blue)](https://nwjs.io/)
[![C++](https://img.shields.io/badge/C%2B%2B-11-blue.svg)](https://isocpp.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.2-red.svg)](CHANGELOG.md)
[![Docs](https://img.shields.io/badge/docs-docs.crclare.top-blue)](https://docs.crclare.top)

---

**Use Case**: Indie games priced between ¥12 and ¥60, protecting the initial sales window.

**Core Philosophy**: Not pursuing absolute uncrackability, but ensuring the cracking cost > the game's price, economically deterring piracy.

**Preface**: This project is completely open-source and free (MIT License). RM developers are welcome to use it directly, and crackers are also welcome to attempt a crack and submit an Issue — the deeper you dig, the faster I patch, and the stronger this system becomes. Consider this my contribution of "Liberty" to the RM community.

## V2.2 Core Improvements

V2.2 is the **finalized version** of the Basic line. The code logic has been finalized after 13 rounds of revisions. After this update, Basic enters **maintenance mode**. Future focus will shift to the GUI graphical interface and the Pro cloud verification version.

- **CSDP Incremental Patch**: Only encrypts modified files. Players only need to download a few MB to complete the update. Solves the historical problem of "downloading several GB for every update" in RM games.
- **Independent Subkeys per File**: Derives unique keys for each file using the master key + relative file path. A single file key leak does not affect other files.
- **String Cipher Table**: Key tags no longer exist in plaintext within the binary.
- **Build Config Header**: Compile-time parameters are passed via generated config file instead of `-D` macros, eliminating command-line escaping issues.
- **Triple CI Verification**: Artifact existence / no plaintext leakage / key config compiled in. Any failure => Actions turns red directly.
- **Removed Hard Expiry Check**: The deadline parameter is deprecated; authors only need to fill in the game name and version number.
- **Lightweight Runtime Detection**: All detection mechanisms produce no behavioral differences, **never mistakenly affecting legitimate players**.

## MV / MZ Engine Protection Differences

V2.2 provides two routes for the two engine versions, due to objective differences in the underlying environments:

| Engine | Protection Route | Characteristics |
|:---|:---|:---|
| **RPG Maker MV** | Pure JS Lightweight Protection | Based on Node.js native crypto module. Zero environment dependency, one-click encryption, 100% compatibility. |
| **RPG Maker MZ** | C++ N-API Native Encryption Layer | Decryption payload sinks to native binary. Higher performance, stronger reverse-engineering threshold. Requires cloud compilation. |

Please be aware of this difference when choosing your engine. MV does not require cloud compilation; MZ requires GitHub Actions to generate a dedicated `.node`.

## Design Philosophy

Chronos Seal does not pursue absolute uncrackability—that doesn't exist in a client-side environment. It pursues: making the cost of cracking (time, technical threshold, maintenance burden) far exceed the value of the game itself, thereby economically deterring piracy.

- **Economic Game**: There is no absolute uncrackable local encryption. This solution aims to raise the cracking cost far beyond the game's price, protecting the "golden two weeks" of indie game launches.
- **Different Seeds**: The master seed of each author is unique. Crackers cannot use a universal tool to crack all games using Chronos Seal—they must reverse-engineer each game individually, which dismantles the feasibility of a "universal unpacking tool" from a cost model perspective.
- **Zero Trust, Zero Knowledge**: The tool author does not touch or store any user keys.
- **Fully Reversible**: Only the distribution package is encrypted, with zero modification to project files.
- **Never Mistakenly Affecting Legitimate Players**: All mechanisms are transparent to legitimate players, producing no risk of misjudgment.

## Features

- **Native Layer Trust Root**: Core decryption logic resides in the C++ compiled binary (`.node`). No keys in the JS layer; cannot be extracted via F12 console.
- **Complete Asset Encryption**: Encrypts entire asset files, no longer just the first 16 bytes like RM's built-in encryption.
- **Independent Subkeys per File**: Derived using master key + relative file path. A single file leak does not affect others.
- **Runtime Key Derivation**: Master key derived from version number + release date + derivation seed → HMAC-SHA256 chain derivation, stored in no file.
- **String Cipher Table**: Key tags do not appear in plaintext within the binary.
- **Asset Format with Magic Number**: File header contains `CHRNSLSE` magic number, allowing the JS layer to quickly determine if a file is encrypted.
- **HMAC Integrity Verification**: Each encrypted asset comes with an HMAC-SHA256 signature to prevent tampering (constant-time comparison, anti-timing attack).
- **CSDP Incremental Patch**: Only encrypts modified files; players only need to download a few MB incremental package.
- **Cloud Compilation**: No local compilation environment needed. [GitHub Actions](https://github.com/CLARE-XHL/Chronos-Builder-Template) generates your dedicated `.node` with one click.
- **No External Platform Dependency**: Works for Steam games, works for free games.

## Quick Links

| Link | Description |
|:---|:---|
| [📖 Full Documentation](https://docs.crclare.top) | VitePress documentation site (recommended to read first) |
| [📦 Main Repository](https://github.com/CLARE-XHL/Chronos-Seal) | Source code & Releases |
| [☁️ Template Repository](https://github.com/CLARE-XHL/Chronos-Builder-Template) | Cloud compilation entry |
| [📋 Releases](https://github.com/CLARE-XHL/Chronos-Seal/releases) | Download the latest distribution package |

## Known Limitations

- **The Basic line only provides "initial sales window protection"**, not "permanent uncrackability"—the inherent ceiling of client-side encryption exists.
- **V2.2 is the endpoint of the Basic line**. Unless security vulnerabilities are found, there will be no V2.3.
- The author does not promise immediate response, but will pay attention to community feedback.
- **`encrypt_config.json` and `author_secret.txt` are long-term credentials**. Once lost, the published game can no longer be updated. Please be sure to back them up offline.

## Feedback & Support

This version is a **finalized release without an author's testing environment**. If you encounter issues during use, feedback is welcome:

- **Submit an Issue**: Please attach engine version, OS, reproduction steps, and error screenshots.
- **Submit a PR**: **Only bug fixes are accepted**, no new feature requests.
- **Self-Modification**: The code is completely open; feel free to fork for your own use.

## License

This project is open-sourced under the MIT License. See the [LICENSE](LICENSE) file for details.

When using this software, please abide by the following conventions:

- ✅ Allowed: Integrate Chronos Seal into your commercial or free games, sell your game closed-source.
- ✅ Allowed: Modify the source code for your own projects.
- ✅ Allowed: Distribute under the terms of the MIT License.
- ❌ Strictly Prohibited: Selling the source code or compiled artifacts (`.node` files) of Chronos Seal as standalone commercial products.
- ❌ Strictly Prohibited: Selling the Chronos Seal itself after removing or hiding copyright notices.

**In simple terms: You can sell games that use Chronos Seal, but you cannot directly sell Chronos Seal itself.**

---

*This statement is a supplementary explanation to the MIT License and does not alter the authorization terms of the MIT License.*

## Acknowledgements

- [node-addon-api](https://github.com/nodejs/node-addon-api)
- [OpenSSL](https://www.openssl.org/)
- @JiuGeGe520 —— Helped discover initial vulnerabilities, driving the V1.1 ADS dual-storage solution.
- fux2 from Project 1 —— Pointed out the core misconception of the V1.x version, prompting a complete refactoring in V2.0.
- Singular_Photon from Project 1 —— Pointed out the fatal vulnerability in RM's native asset encryption, driving the sinking of asset decryption in V2.1.

## Contact

- Author: CLARE-XHL
- Project URL: [https://github.com/CLARE-XHL/Chronos-Seal](https://github.com/CLARE-XHL/Chronos-Seal)
- Documentation: [https://docs.crclare.top](https://docs.crclare.top)
- For code signing policy, see [CODE_SIGNING.md](./CODE_SIGNING.md)

⭐ If this project has been helpful to you, please give the main repository a Star!
