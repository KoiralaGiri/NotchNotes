<div align="center">
  <h1>NotchNotes</h1>
  <p>A rich text editor that lives in your Mac's notch.</p>

  ![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)
  ![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
  ![License](https://img.shields.io/badge/license-MIT-blue)
</div>

---

NotchNotes turns the notch on your MacBook into something useful Push your cursor to the top of the screen, and a panel drops down with your pinned notes.

> **Requires a MacBook with a notch** (MacBook Pro 2021 and later, MacBook Air M2 and later) running macOS Sonoma 14+. Can't figure out how to make it work on other Macs without notches for now. I'm working on a collaboration feature for now, but haven't thought about implementing on other Mac types yet.

Also, just so everyone knows, this is like extermely basic. My friend and I just wanted somewhere for us to store our notes without having to go back to the desktop. By notes, I mean stickies. The notch kinda has no use for anything, so we thought why not stick it in the top of the screen. There are a ton of bugs where it doesn't recognize when you're hovering over it when other apps are open, so I'm working on that.

## Install

**Option 1 — Releases**

Go to the [Releases](../../releases/latest) page, download `NotchNotes.zip`, unzip it, and drag `NotchNotes.app` into your Applications folder.

Since the app is not signed by Apple, Macs will block it on first open. To get around that:

```
Right-click NotchNotes.app → Open → Open anyway
```

Or run this once in Terminal:
```bash
xattr -rd com.apple.quarantine /Applications/NotchNotes.app
```

**Option 2**

```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/NotchNotes/main/install.sh | bash
```

This downloads the latest release and handles installing unknown applications automatically.

## Build from Source

You'll need Xcode 15+ and a MacBook with Apple Silicon.

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NotchNotes.git
   cd NotchNotes
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```
   This compiles the app and signs it, and makes the `NotchNotes.zip`.

3. Unzip it open the `NotchNotes.app`.

## License

MIT — see [LICENSE](LICENSE).
