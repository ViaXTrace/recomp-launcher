# RECOMP — Xbox 360 Launcher for Android

> Unofficial Android launcher for Xbox 360 static recompilation.  
> Built with Flutter · Powered by [UnleashedRecomp-Android](https://github.com/SansNope/UnleashedRecomp-Android)

---

## What is RECOMP?

RECOMP is a native Android launcher that manages your legally-obtained Xbox 360 game library and launches them via static recompilation — not emulation. Static recompilation converts original PowerPC executables into native ARM64 code, so the game runs as if it were built for Android from the start.

This repository contains the **launcher UI**. The recompilation engine is sourced from the open-source UnleashedRecomp project.

---

## Requirements

- Android 7.0+ (API 24)
- **Qualcomm Adreno GPU** — required for Vulkan compatibility. Mali, Xclipse, and PowerVR are not supported.
- 4 GB RAM minimum, 6 GB+ recommended
- Legally-obtained Xbox 360 game files

## Supported Formats

| Extension | Description |
|-----------|-------------|
| `.xex`    | Xbox 360 Executable (extracted from disc) |
| `.iso`    | Full disc image |
| `.god`    | Games on Demand package |
| `.xbla`   | Xbox Live Arcade title |
| `.xcp`    | Content package |

---

## Installation

1. Download the APK from the [Releases](../../releases) page
2. Choose the APK for your device architecture:
   - `arm64-v8a` — modern phones (recommended)
   - `armeabi-v7a` — older 32-bit devices
3. Enable "Install from unknown sources" in Android settings
4. Install and launch RECOMP
5. Go to **Import** tab → select your game file

---

## Build from Source

**Requirements:** Flutter 3.24+, Android Studio, Java 17

```bash
git clone https://github.com/YOUR_USERNAME/recomp-launcher
cd recomp-launcher/recomp-launcher
flutter pub get
flutter build apk --release --split-per-abi
```

---

## CI/CD

Every push to `main` builds a debug APK and uploads it as a GitHub Actions artifact.

Every tag matching `v*.*.*` triggers a full release build and publishes all ABI variants to GitHub Releases automatically.

```bash
# Create a release
git tag v1.0.0
git push origin v1.0.0
```

---

## Credits

- [hedge-dev/UnleashedRecomp](https://github.com/hedge-dev/UnleashedRecomp) — the original static recompilation project
- [SansNope/UnleashedRecomp-Android](https://github.com/SansNope/UnleashedRecomp-Android) — the Android port that inspired this launcher

---

## Legal

This project does not distribute any Xbox 360 game files, system files, or copyrighted content.  
You must legally own any games you import. The developers take no responsibility for misuse.

Xbox is a trademark of Microsoft Corporation. This project is not affiliated with or endorsed by Microsoft.
