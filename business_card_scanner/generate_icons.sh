#!/bin/bash

echo "Generating app icons for Business Card Scanner..."
echo

echo "Step 1: Getting dependencies..."
flutter pub get

echo
echo "Step 2: Generating launcher icons..."
flutter pub run flutter_launcher_icons

echo
echo "Icon generation completed!"
echo
echo "The following icons have been generated:"
echo "- Android: Various mipmap folders in android/app/src/main/res/"
echo "- iOS: Assets.xcassets/AppIcon.appiconset/"
echo "- Web: web/icons/"
echo "- Windows: windows/runner/resources/"
echo "- macOS: macos/Runner/Assets.xcassets/AppIcon.appiconset/"
echo 