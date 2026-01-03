# 🚀 Quick Start Commands

## Essential Flutter Commands

### Setup
```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Clean build files
flutter clean

# Upgrade dependencies
flutter pub upgrade
```

### Running
```bash
# Run app (debug mode)
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run with specific flavor
flutter run --flavor production

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Quit: Press 'q' in terminal
```

### Building
```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (Mac only)
flutter build ios --release

# Build web
flutter build web
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Code Quality
```bash
# Format code
flutter format .

# Fix issues
dart fix --apply

# Generate code (for models)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Git Commands

```bash
# Initialize repository
git init
git add .
git commit -m "Initial commit"

# Create feature branch
git checkout -b feature/chat-interface

# Stage and commit changes
git add .
git commit -m "Add chat interface"

# Push to remote
git push origin feature/chat-interface

# Pull latest changes
git pull origin main

# View status
git status

# View commit history
git log --oneline
```

---

## Firebase Commands

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init

# Deploy functions
firebase deploy --only functions

# Deploy hosting
firebase deploy --only hosting
```

---

## Android Specific

```bash
# Navigate to android directory
cd android

# Clean gradle
./gradlew clean

# Build release APK
./gradlew assembleRelease

# Install on device
./gradlew installDebug

# Back to root
cd ..
```

---

## iOS Specific (Mac only)

```bash
# Navigate to ios directory
cd ios

# Install pods
pod install

# Update pods
pod update

# Clean pods
pod deintegrate
rm Podfile.lock
pod install

# Back to root
cd ..
```

---

## VS Code Shortcuts

### General
- `Ctrl/Cmd + Shift + P` - Command palette
- `Ctrl/Cmd + P` - Quick file open
- `Ctrl/Cmd + ,` - Settings
- `F5` - Start debugging

### Editing
- `Ctrl/Cmd + /` - Toggle comment
- `Alt + Up/Down` - Move line up/down
- `Shift + Alt + Up/Down` - Copy line up/down
- `Ctrl/Cmd + D` - Select next occurrence
- `Ctrl/Cmd + Shift + L` - Select all occurrences

### Flutter Specific
- `Ctrl/Cmd + Shift + F5` - Hot restart
- Type `stless` + Tab - Create StatelessWidget
- Type `stful` + Tab - Create StatefulWidget
- `Ctrl/Cmd + .` - Quick fix

---

## Package Management

```bash
# Add package
flutter pub add package_name

# Add dev package
flutter pub add --dev package_name

# Remove package
flutter pub remove package_name

# Search packages
flutter pub search package_name

# Show outdated packages
flutter pub outdated

# Get specific version
flutter pub add package_name:^1.0.0
```

---

## Device Management

```bash
# List connected devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Screen mirroring (scrcpy)
scrcpy
```

---

## Debugging

```bash
# Run with verbose logging
flutter run -v

# Run with debugging
flutter run --debug

# Run with profile mode
flutter run --profile

# Run with release mode
flutter run --release

# Show performance overlay
# Press 'P' in terminal while app is running

# Show widget inspector
# Press 'I' in terminal while app is running

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## Database

```bash
# View SQLite database (Android)
adb pull /data/data/com.cropdiagnostic.app/databases/crop_diagnostic.db
sqlite3 crop_diagnostic.db

# Hive boxes location
# Android: /data/data/com.cropdiagnostic.app/app_flutter/
# iOS: Library/Application Support/
```

---

## Performance

```bash
# Profile performance
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Check memory usage
flutter run --profile
# Then use DevTools
```

---

## Useful Aliases (Add to .bashrc or .zshrc)

```bash
# Flutter shortcuts
alias fr='flutter run'
alias frd='flutter run --debug'
alias frr='flutter run --release'
alias fb='flutter build'
alias ft='flutter test'
alias fc='flutter clean'
alias fpg='flutter pub get'
alias fpu='flutter pub upgrade'
alias fa='flutter analyze'
alias ff='flutter format .'

# Git shortcuts
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'
alias gco='git checkout'
alias gbl='git branch -l'

# Project shortcuts
alias crop='cd ~/Desktop/crop'
```

---

## Environment Variables

Create `.env` file:
```env
API_KEY=your_api_key
BASE_URL=https://api.cropdiagnostic.app
WEATHER_API_KEY=your_weather_key
GOOGLE_MAPS_API_KEY=your_maps_key
```

Load in Dart:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: ".env");
String apiKey = dotenv.env['API_KEY'] ?? '';
```

---

## Common Issues & Fixes

### Issue: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Issue: "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```

### Issue: "Package conflicts"
```bash
flutter pub cache repair
flutter pub get
```

### Issue: "Hot reload not working"
```bash
# Press 'R' for hot restart
# Or restart the app completely
```

---

## Helpful Resources

- **Flutter Docs:** https://docs.flutter.dev
- **Pub.dev:** https://pub.dev (Package repository)
- **DartPad:** https://dartpad.dev (Online Dart editor)
- **Flutter DevTools:** Built-in debugging tools
- **Stack Overflow:** Tag: flutter
- **Flutter Discord:** Community support

---

## Project-Specific Commands

```bash
# Run with development flavor
flutter run --flavor dev

# Run with production flavor
flutter run --flavor prod

# Generate app icon
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Generate translations
flutter gen-l10n
```

---

**Tip:** Bookmark this file for quick reference! 📚

**Pro Tip:** Use `flutter --help` or `flutter <command> --help` for detailed information on any command.
