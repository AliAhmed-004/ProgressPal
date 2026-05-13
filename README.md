# 🎯 ProgressPal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D3.7.0-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.0-blue)](https://dart.dev)

> **Learn by doing. Prove it by reflecting.**
>
> ProgressPal is a cross-platform learning companion that combines deliberate practice with reflective learning. Unlike traditional to-do apps, ProgressPal requires you to articulate what you've learned before completing a goal—turning passive task-checking into active knowledge retention.

## 📚 Table of Contents

- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Development](#-development)
- [Contributing](#-contributing)
- [License](#-license)

## 🧠 The Problem

Research in cognitive psychology confirms that **active recall and spaced repetition** are the most effective learning techniques. Yet most productivity apps treat learning like a checkbox—complete, done, move on.

This approach has critical flaws:
- ❌ No incentive for deep understanding
- ❌ No accountability for actual learning
- ❌ No personal record of progress
- ❌ Easy to mistake activity for achievement

## ✨ The Solution

ProgressPal introduces intentional friction into your learning workflow:

1. **Reflection-First Completion** — Before marking a goal complete, answer: *"What have you learned?"*
2. **Learning Journaling** — Build a personal record of insights and breakthroughs
3. **Streak Motivation** — Stay consistent with daily streaks and social accountability
4. **AI-Powered Guidance** — Generate actionable, personalized learning goals

The result? **Better retention, faster skill building, and proof of your progress.**

## 🔥 Key Features

### 📚 Track-Based Learning System
Organize learning into logical tracks (e.g., "Master Python", "Conversational Spanish", "Guitar Fundamentals"). Each track contains goals that build on each other, creating a curriculum for your self-directed learning.

### ✍️ Reflection-First Goal Completion
Mark goals complete only after reflecting on what you learned. This one-sentence requirement:
- Forces cognitive engagement with material
- Creates a searchable learning journal
- Proves you actually absorbed the knowledge

### 🏆 Streak System
Build daily streaks by completing at least one goal per day. Features:
- Current and lifetime streak tracking
- Daily reminders via push notifications
- Gamified motivation system
- Visual progress indicators

### 🤖 AI-Powered Goal Generation
Stuck on what to learn next? Use the built-in Gemini AI to generate small, actionable goals tailored to your learning track:
- Context-aware suggestions
- Helps break down complex topics
- One free generation per day

### 📅 Weekly Progress Calendar
Visualize learning consistency with a calendar showing:
- Days completed vs missed
- What you accomplished each day
- Weekly streaks at a glance

### ⏱️ Pomodoro Timer
Built-in focus timer for deep work:
- Preset durations (25/50 minutes)
- Custom timer support
- Haptic and audio feedback
- Session tracking

### 🎨 Full Theme Support
- Light and dark modes
- System preference detection
- Customizable UI themes

### 🔒 100% Privacy-First
- All data stored locally on device
- No accounts or sign-ups required
- Zero tracking or analytics
- No cloud dependencies

## 📱 Screenshots

*Coming soon — [screenshots showing the app interface]*

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **UI Framework** | Flutter 3.7+ |
| **State Management** | Provider |
| **Local Database** | Hive |
| **AI Integration** | Google Generative AI (Gemini) |
| **Notifications** | Firebase Cloud Messaging + Flutter Local Notifications |
| **Monetization** | Google Mobile Ads |
| **Code Generation** | build_runner, json_serializable |

**Supported Platforms:**
- Android 5.0+ (API 21)
- iOS 11.0+

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration (generated)
│
├── pages/                             # Full-screen views
│   ├── home_page.dart                 # Main learning dashboard
│   ├── insights_page.dart             # Analytics and progress
│   ├── pomodoro_page.dart             # Focus timer
│   ├── settings_page.dart             # User preferences
│   ├── onboarding_page.dart           # First-run experience
│   └── privacy_policy_page.dart       # Legal
│
├── components/                        # Reusable UI widgets
│   ├── custom_appbar.dart
│   ├── custom_weekly_calendar.dart
│   ├── contribution_heatmap.dart
│   ├── generate_goals_button.dart
│   └── ...
│
├── providers/                         # State management (Provider)
│   ├── theme_provider.dart            # Theme state
│   ├── track_provider.dart            # Learning tracks data
│   └── streak_provider.dart           # Streak calculations
│
├── services/                          # Business logic
│   ├── hive_database.dart             # Local storage
│   ├── firebase_service.dart          # Firebase integration
│   ├── noti_service.dart              # Push notifications
│   ├── celebration_service.dart       # Gamification
│   ├── ad_service.dart                # Ad management
│   ├── share_image_service.dart       # Screenshot sharing
│   └── ...
│
├── models/                            # Data models
│   ├── goal.dart
│   ├── track_entry.dart
│   └── streak_model.dart
│
├── themes/                            # UI theming
│   └── themes.dart
│
├── gemini/                            # AI integration
│   └── gemini_helper.dart
│
└── secrets/                           # API keys (NOT in git)
    └── secrets.dart.example           # Template
```

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** 3.7.0 or higher ([install](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0 or higher (comes with Flutter)
- **Git** for cloning

### Quick Setup

#### 1. Clone and Install Dependencies
```bash
git clone https://github.com/yourusername/progresspal.git
cd progresspal
flutter pub get
```

#### 2. Configure API Keys
Create `lib/secrets/secrets.dart` with your API keys:

```dart
const String GEMINI_API_KEY = 'your-gemini-api-key-here';
```

**Get your Gemini API Key:**
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy and paste into `secrets.dart`

#### 3. (Optional) Configure Firebase
For push notifications and streak reminders, set up Firebase:

**For Android:**
1. Create a [Firebase project](https://console.firebase.google.com)
2. Add Android app to your Firebase project
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

**For iOS:**
1. Add iOS app to your Firebase project
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`

#### 4. Run the App
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

**List available devices:**
```bash
flutter devices
```

## 💻 Development

### Setup Development Environment

#### 1. Install Flutter (if not done)
```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Generate Code (for models and serialization)
```bash
flutter pub run build_runner build
```

#### 4. Code Quality

**Format Code:**
```bash
flutter format lib/ test/
```

**Static Analysis:**
```bash
flutter analyze
```

**Run Tests:**
```bash
flutter test
```

### Key Classes and Architecture

#### State Management (Provider)
- `ThemeProvider` — Manages light/dark theme state
- `TrackProvider` — Manages learning tracks and goals
- `StreakProvider` — Calculates and tracks daily streaks

#### Core Services
- `HiveDatabase` — Local data persistence with Hive
- `NotiService` — Manages all notifications
- `FirebaseService` — Firebase integration (messaging, analytics)
- `GeminiGoalGenerator` — AI goal suggestion engine

#### Data Models
Models use `@HiveType()` decorators for local storage and `@JsonSerializable()` for serialization.

After modifying models, regenerate:
```bash
flutter pub run build_runner build
```

### Development Tips

- **Hot Reload** (`r` in terminal) — Reload code changes without restarting
- **Hot Restart** (`R`) — Full restart of the app
- **DevTools** — `flutter pub global run devtools` for UI inspection
- **Logs** — `flutter logs` to view debug output
- **Debugging** — Use `debugPrint()` for console output

## 🤝 Contributing

We welcome contributions! Whether it's bug reports, feature suggestions, or code—your help makes ProgressPal better.

### How to Contribute

1. **Fork** the repository
2. **Create a branch** (`git checkout -b feature/amazing-feature`)
3. **Commit changes** (`git commit -m 'Add amazing feature'`)
4. **Push to branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

For detailed guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

### Reporting Bugs

When reporting bugs, include:
- Clear description and reproduction steps
- Expected vs actual behavior
- Screenshots/videos if applicable
- Your environment (Flutter version, device, OS)

## 📋 Roadmap

- [ ] Export learning journal as PDF
- [ ] Social sharing and accountability partners
- [ ] Spaced repetition system
- [ ] Learning analytics dashboard
- [ ] Offline sync for cloud backup
- [ ] Widget support for home screen
- [ ] Web version
- [ ] Multi-language support

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

The MIT License is permissive, allowing you to:
- ✅ Use commercially
- ✅ Modify and distribute
- ✅ Use privately

Just include the original license and copyright notice.

## 🙏 Acknowledgments

- Inspired by research on [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) and [active recall](https://en.wikipedia.org/wiki/Active_recall)
- Built with [Flutter](https://flutter.dev), [Provider](https://pub.dev/packages/provider), and [Hive](https://pub.dev/packages/hive)
- AI features powered by [Google Generative AI](https://ai.google.dev/)

## 📧 Contact & Support

**Questions or feedback?**
- 📧 Email: ali.the.ahmed18@gmail.com
- 🐛 [Open an Issue](https://github.com/yourusername/progresspal/issues)
- 💡 [Start a Discussion](https://github.com/yourusername/progresspal/discussions)

---

<div align="center">

### **Stop checking boxes. Start learning.**

[⬇️ Download on Google Play](https://play.google.com/store/apps/details?id=com.spudbyte.progresspal)

Made with ❤️ for learners everywhere

</div>