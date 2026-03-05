#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================================================================
# Notepad Installation Script (Curl to Bash)
# ==============================================================================

# Change these when you upload to your own repository!
REPO_OWNER="YOUR_USERNAME" 
REPO_NAME="NotchNotes"
APP_NAME="NotchNotes.app"
ZIP_NAME="NotchNotes.zip"

echo "========================================"
echo "🚀 Installing NotchNotes..."
echo "========================================"

# Temporary directory for downloading
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# 1. Download the latest release from GitHub
echo "📥 Downloading the latest release from GitHub..."

# Fetch the latest release API and extract the asset download URL
LATEST_URL=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" | grep "browser_download_url.*${ZIP_NAME}" | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "⚠️  No release found! Attempting to download from the main branch instead..."
    # Fallback to downloading a pre-built zip if hosted directly in the repo (not recommended for large files, but works as a fallback)
    LATEST_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/${ZIP_NAME}"
fi

# Download the zip
curl -L -o "$ZIP_NAME" "$LATEST_URL"

# 2. Extract the file
echo "📦 Extracting files..."
unzip -q "$ZIP_NAME"

# Check if the app was extracted
if [ ! -d "$APP_NAME" ]; then
    echo "❌ Failed to extract $APP_NAME! Something went wrong."
    exit 1
fi

# 3. Move to Applications folder
echo "🚚 Moving to /Applications..."

# Remove old version if it exists
if [ -d "/Applications/$APP_NAME" ]; then
    echo "   Removing old version..."
    rm -rf "/Applications/$APP_NAME"
fi

mv "$APP_NAME" /Applications/

# 4. Remove quarantine attribute (So macOS doesn't block it since we ad-hoc signed it)
echo "🔓 Bypassing macOS Gatekeeper for local ad-hoc install..."
xattr -rd com.apple.quarantine "/Applications/$APP_NAME" 2>/dev/null || true

# 5. Cleanup
echo "🧹 Cleaning up temporary files..."
cd ~
rm -rf "$TMP_DIR"

echo "========================================"
echo "🎉 NotchNotes installed successfully! 🎉"
echo "========================================"
echo "You can now open NotchNotes from your Launchpad or /Applications folder."
echo "Have fun taking notes exactly when you need them!"
