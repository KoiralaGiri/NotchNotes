<div align="center">
  <img src="NotchNotes.png" alt="NotchNotes Logo" width="128" />
  <h1>NotchNotes</h1>
  <p>A rich text editor that lives in your Mac's notch.</p>
</div>

---

## Overview

NotchNotes is a rich text editor that lives in your Mac's notch. Push your cursor to the top of the screen and the panel drops down.

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
