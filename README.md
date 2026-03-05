<div align="center">
  <img src="NotchNotes.png" alt="NotchNotes Logo" width="128" />
  <h1>NotchNotes</h1>
  <p>A rich text editor that lives in your Mac's notch.</p>

  ![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
  ![License](https://img.shields.io/badge/license-MIT-blue)
</div>

---

## Overview

NotchNotes turns the notch on your MacBook into something actually useful. Push your cursor to the top of the screen, and a panel drops down with your pinned notes.

> **Requires a MacBook with a notch** (MacBook Pro 2021 and later, MacBook Air M2 and later) running macOS Sonoma 14+.

## Install

**Option 1 — Download (easiest)**

Go to the [Releases](../../releases/latest) page, download `NotchNotes.zip`, unzip it, and drag `NotchNotes.app` into your Applications folder.

Since the app is ad-hoc signed (not notarized), macOS will block it on first open. To get around that:

```
Right-click NotchNotes.app → Open → Open anyway
```

Or run this once in Terminal:
```bash
xattr -rd com.apple.quarantine /Applications/NotchNotes.app
```

**Option 2 — One-liner**

```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/NotchNotes/main/install.sh | bash
```

This downloads the latest release and handles the quarantine flag automatically. Replace `YOUR_USERNAME` with your GitHub username.

## Build from Source

You'll need Xcode 15+ and a MacBook with Apple Silicon (the build script targets `arm64`).

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NotchNotes.git
   cd NotchNotes
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```
   This compiles the app, ad-hoc signs it, and produces `NotchNotes.zip` in the project root.

3. Unzip it and drag `NotchNotes.app` into Applications.

## License

MIT — see [LICENSE](LICENSE).
