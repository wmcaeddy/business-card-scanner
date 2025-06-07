# App Icon Setup for Business Card Scanner

## Overview
This document explains how the app icon has been configured using `assets/bcardv1.png` for both Android and iOS builds.

## What Was Done

### 1. Added Flutter Launcher Icons Package
- Added `flutter_launcher_icons: ^0.14.1` to `dev_dependencies` in `pubspec.yaml`
- Configured the package to use `assets/bcardv1.png` as the source image

### 2. Configuration in pubspec.yaml
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/bcardv1.png"
  min_sdk_android: 21
```

### 3. Generated Icons
The following icons were automatically generated:

#### Android Icons
- **Location**: `android/app/src/main/res/mipmap-*/`
- **Files**: `launcher_icon.png` in various densities (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
- **Manifest**: Already configured to use `@mipmap/launcher_icon`

#### iOS Icons
- **Location**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Files**: Complete set of iOS app icons in all required sizes:
  - Icon-App-1024x1024@1x.png (App Store)
  - Icon-App-60x60@2x.png, Icon-App-60x60@3x.png (iPhone App)
  - Icon-App-76x76@1x.png, Icon-App-76x76@2x.png (iPad App)
  - Icon-App-83.5x83.5@2x.png (iPad Pro App)
  - Various notification, settings, and spotlight icons
- **Configuration**: `Contents.json` automatically updated

## How to Regenerate Icons

If you need to update the icon in the future:

### Method 1: Using the provided scripts
- **Windows**: Run `generate_icons.bat`
- **macOS/Linux**: Run `chmod +x generate_icons.sh && ./generate_icons.sh`

### Method 2: Manual commands
```bash
cd business_card_scanner
flutter pub get
flutter pub run flutter_launcher_icons
```

## Icon Requirements

### Source Image Specifications
- **Current**: `assets/bcardv1.png`
- **Recommended size**: 1024x1024 pixels minimum
- **Format**: PNG with transparency support
- **Design**: Should work well at small sizes (20x20 to 1024x1024)

### Platform-Specific Notes

#### Android
- Icons are generated in multiple densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Uses adaptive icon format where supported
- Icon name: `launcher_icon`

#### iOS
- Generates complete icon set for all iOS devices and contexts
- Includes App Store icon (1024x1024)
- Supports iPhone, iPad, and various UI contexts (notifications, settings, etc.)

## Verification

To verify the icons are working:

1. **Android**: Build and install the APK - the icon should appear in the app drawer
2. **iOS**: Build and install on device/simulator - the icon should appear on the home screen

## Troubleshooting

If icons don't appear:
1. Clean and rebuild the project: `flutter clean && flutter pub get`
2. For iOS: Clean Xcode build folder (Product → Clean Build Folder)
3. For Android: Clean Gradle cache: `cd android && ./gradlew clean`
4. Regenerate icons using the commands above

## Files Modified/Created

- `pubspec.yaml` - Added flutter_launcher_icons dependency and configuration
- `android/app/src/main/res/mipmap-*/launcher_icon.png` - Android icons
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` - iOS icons and Contents.json
- `generate_icons.bat` - Windows script for regenerating icons
- `generate_icons.sh` - Unix script for regenerating icons
- `ICON_SETUP.md` - This documentation file 