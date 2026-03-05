#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Building NotchNotes..."

# 1. Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
rm -f NotchNotes.zip

# 2. Build the app using xcodebuild
echo "🔨 Compiling via Xcode..."
xcodebuild \
  -project NotchNotes.xcodeproj \
  -scheme NotchNotes \
  -configuration Release \
  -arch arm64 \
  -derivedDataPath build \
  clean build | grep -E "error:|warning:|SUCCEEDED|FAILED" || true

# Check if the build actually succeeded
if [ ! -d "build/Build/Products/Release/NotchNotes.app" ]; then
    echo "❌ Build failed. Check the logs above."
    exit 1
fi

echo "✅ App compiled successfully!"

# 3. Code Signing (Ad-hoc)
echo "🔐 Ad-hoc code signing the app..."
codesign --force --deep --sign - "build/Build/Products/Release/NotchNotes.app"

# 4. Package into a Zip
echo "📦 Packaging..."
cd build/Build/Products/Release
# We zip it to preserve the app bundle structure and permissions
zip -qyr ../../../../NotchNotes.zip NotchNotes.app
cd - > /dev/null

echo "🎉 Done! You can find the freshly built app at: ./NotchNotes.zip"
echo "You can host this file in your GitHub Releases!"
