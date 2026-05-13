# Development Setup Guide

This guide walks you through setting up ProgressPal for local development.

## System Requirements

- **Flutter SDK:** 3.7.0 or higher
- **Dart SDK:** 3.0 or higher (included with Flutter)
- **Android Studio** (for Android development)
  - Android SDK 21+
  - Android Build Tools
  - Android Emulator (optional)
- **Xcode** 13+ (for iOS development on macOS)
- **Git** for version control
- **2GB+ disk space** for dependencies

### Platform-Specific Requirements

#### macOS
```bash
# Check your setup
flutter doctor

# Install Xcode command line tools if needed
xcode-select --install
```

#### Windows
- Visual Studio 2019+ or Visual Studio Build Tools
- Windows 10 SDK
- Minimum 2GB RAM

#### Linux
```bash
# Required packages (Ubuntu/Debian)
sudo apt-get install -y \
  git \
  curl \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev
```

## Step 1: Install Flutter

### Option A: Install from Source (Recommended)

```bash
# Clone Flutter repository
git clone https://github.com/flutter/flutter.git -b stable
cd flutter
export PATH="$PATH:`pwd`/bin"

# Verify installation
flutter doctor
```

### Option B: Download Binary
Visit https://flutter.dev/docs/get-started/install

## Step 2: Clone Repository

```bash
git clone https://github.com/yourusername/progresspal.git
cd progresspal
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

This will:
- Download all Dart/Flutter packages
- Install platform-specific dependencies
- Generate necessary files

## Step 4: Configure Secrets

### Create Secrets File

Create `lib/secrets/secrets.dart`:

```dart
/// API Keys for ProgressPal
/// DO NOT commit this file to version control

const String GEMINI_API_KEY = 'your-api-key-here';
```

### Get Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click "Create API Key"
3. Copy the key
4. Paste into `lib/secrets/secrets.dart`

## Step 5: Generate Code

Models use code generation. Generate them:

```bash
flutter pub run build_runner build
```

Or watch for changes:

```bash
flutter pub run build_runner watch
```

## Step 6: (Optional) Setup Firebase

Firebase is optional for development (notifications won't work without it).

### For Android

1. Create a [Firebase project](https://console.firebase.google.com)
2. Add Android app:
   - Package name: `com.spudbyte.progresspal`
   - SHA-1: Get from `./gradlew signingReport` in android/
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

### For iOS

1. In Firebase Console, add iOS app
   - Bundle ID: `com.spudbyte.progresspal`
2. Download `GoogleService-Info.plist`
3. Add to Xcode:
   - Open `ios/Runner.xcworkspace`
   - Drag plist file into Runner
   - Check "Copy items if needed"

## Step 7: Run the App

### List Available Devices

```bash
flutter devices
```

### Run on Android

```bash
# Via Android Emulator
flutter run

# Via connected device
flutter run -d <device-id>

# Release mode
flutter run --release
```

### Run on iOS (macOS only)

```bash
# Get iOS dependencies
cd ios
pod install
cd ..

# Run on simulator
flutter run -d iPhone

# Run on physical device
flutter run -d <device-id>
```

### Run on Web (experimental)

```bash
flutter run -d chrome
```

## Development Workflow

### Hot Reload

During development, hot reload saves time:

```bash
# Start dev server
flutter run

# In terminal, press:
# 'r' - hot reload (fast reload of code)
# 'R' - hot restart (full app restart)
# 'q' - quit
```

### Code Analysis

Check for errors and warnings:

```bash
flutter analyze
```

### Code Formatting

Keep code formatted consistently:

```bash
# Format all code
flutter format lib/ test/

# Format specific file
flutter format lib/main.dart
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

### View Logs

```bash
# See all logs
flutter logs

# Filtered logs
flutter logs --grep "ProgressPal"
```

## Debugging

### Enable Debug Prints

The app uses `debugPrint()` for console output:

```bash
flutter run
# Look for [INIT SERVICES] prefixed logs
```

### Use DevTools

Interactive debugging and widget inspection:

```bash
# Install if needed
flutter pub global activate devtools

# Launch DevTools
devtools

# Or via Flutter
flutter pub global run devtools
```

Then connect your running app to DevTools.

### Android Studio Debugger

1. Open project in Android Studio
2. Set breakpoints in code
3. Run with debugging:
   ```bash
   flutter run --debug
   ```

## Troubleshooting

### Flutter Doctor Issues

```bash
# Full doctor output
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses
```

### Build Issues

```bash
# Clean build
flutter clean

# Get latest dependencies
flutter pub get
flutter pub upgrade

# Rebuild
flutter pub run build_runner clean
flutter pub run build_runner build
```

### iOS Pod Issues

```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
```

### Gemini API Errors

- Verify API key in `lib/secrets/secrets.dart`
- Check API quota at [Google Cloud Console](https://console.cloud.google.com)
- Ensure Generative Language API is enabled

### Firebase Issues

- Verify credentials in `google-services.json`
- Check Firebase console for errors
- Ensure Firebase project matches app package name

## VS Code Setup

### Recommended Extensions

- **Flutter** (Dart Code)
- **Dart** (Dart Code)
- **Flutter Widget Snippets** (Alex Chmara)
- **Awesome Flutter Snippets** (Nash)
- **Error Lens** (Alexander)

### Launch Configuration (.vscode/launch.json)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "console": "integratedTerminal"
    }
  ]
}
```

## Android Studio Setup

### Recommended Plugins

- Flutter
- Dart
- Android Neon

### Run Configurations

1. Run → Edit Configurations
2. Create new "Flutter" configuration
3. Select entry point: `lib/main.dart`

## Next Steps

- Read [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
- Explore the [project structure](README.md#-project-structure)
- Check [CHANGELOG.md](CHANGELOG.md) for recent updates
- Browse existing issues for contribution ideas

## Getting Help

- 📖 [Flutter Documentation](https://flutter.dev/docs)
- 🐛 [GitHub Issues](https://github.com/yourusername/progresspal/issues)
- 💬 [GitHub Discussions](https://github.com/yourusername/progresspal/discussions)
- 🤖 Stack Overflow (tag: flutter)

Happy coding! 🚀
