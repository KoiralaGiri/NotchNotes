<div align="center">
  <img src="NotchNotes.png" alt="NotchNotes Logo" width="128" />
  <h1>NotchNotes</h1>
  <p>A rich text editor that lives in your Mac's notch.</p>
</div>

---

## Overview

NotchNotes turns the notch on your MacBook into something actually useful. Push your cursor to the top of the screen, and a panel drops down with your pinned notes — then disappears when you're done.

### Features
- **Hover to Open** — push your cursor to the top of the screen and the panel drops down automatically
- **Rich Text** — bold, italic, underline, strikethrough, font sizes, text colors, highlights, all of it
- **Multiple Pinned Notes** — pin more than one note and switch between them right from the panel
- **Auto-sizing** — the panel grows with your content, up to about 80% of your screen height
- **Fullscreen friendly** — works even when another app is in fullscreen
- **Auto-save** — saves locally as you type, nothing gets lost

## Install

Open Terminal and run:

```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/NotchNotes/main/install.sh | bash
```

*(Replace `YOUR_USERNAME` with your GitHub username once you've pushed the repo. The script downloads the latest release and drops it into your Applications folder.)*

## Build from Source

If you'd rather build it yourself:

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NotchNotes.git
   cd NotchNotes
   ```
2. Run the build script:
   ```bash
   ./build.sh
   ```
   *(Compiles the app and spits out a `NotchNotes.zip` in your current directory.)*

3. Unzip it and drag `NotchNotes.app` into Applications.

## License

MIT
