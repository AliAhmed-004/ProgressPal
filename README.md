# 🎯 ProgressPal

**Learn by doing. Prove it by reflecting.**

ProgressPal isn't just another to-do list. It's a learning companion that helps you build skills through deliberate practice and reflection.

## 🧠 The Problem

Most productivity apps let you mindlessly check boxes. But research shows that **active recall and reflection** are key to actually retaining what you learn. Simply marking tasks "done" doesn't build lasting knowledge.

## ✨ The Solution

ProgressPal requires you to **write what you learned** before completing a goal. This simple friction:

- Forces you to reflect on your progress
- Reinforces memory through active recall
- Creates a personal learning journal
- Proves to yourself that you actually learned something

## 🔥 Features

### 📚 Track-Based Learning
Organize your learning into **Tracks** (e.g., "Learn Python", "Guitar Practice", "Read More Books"). Each track contains goals that build on each other.

### ✍️ Reflection-First Completion
To mark a goal complete, you must answer: *"So, what have you learned?"* — turning passive checkbox-ticking into active learning.

### 🏆 Streak System
Stay motivated with daily streaks. Complete at least one goal per day to keep your streak alive. Your current and highest streaks are always visible.

### 🤖 AI-Powered Goal Generation
Stuck on what to learn next? Use the built-in AI assistant to generate small, actionable goals tailored to your track. One free generation per day.

### 📅 Weekly Progress Calendar
Visualize your consistency with a weekly calendar showing which days you completed goals — and what you accomplished on each day.

### ⏱️ Pomodoro Timer
Built-in focus timer with preset durations (25min, 50min) or custom times. Includes vibration and sound alerts when your session ends.

### 🌙 Dark Mode
Full support for light, dark, and system themes.

### 🔒 Privacy-First
All your data stays on your device. No account required. No tracking. No analytics.

## 📱 Screenshots

*Coming soon*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x recommended)
- Android Studio / VS Code with Flutter extensions
- Firebase project (for push notifications)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/progresspal.git
   cd progresspal
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a Firebase project
   - Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. Add your Gemini API key:
   - Create `lib/secrets/secrets.dart`:
     ```dart
     const String GEMINI_API_KEY = 'your-api-key-here';
     ```

5. Run the app:
   ```bash
   flutter run
   ```

## 🛠️ Built With

- **Flutter** - Cross-platform UI framework
- **Hive** - Lightweight local database
- **Provider** - State management
- **Firebase** - Push notifications
- **Google Generative AI** - AI goal generation
- **Flutter Local Notifications** - Streak reminders

## 📖 How It Works

1. **Create a Track** — Define what you want to learn (e.g., "Learn Spanish")
2. **Add Goals** — Break it into small, achievable tasks (or let AI suggest them)
3. **Do the Work** — Actually practice/study/learn
4. **Reflect & Complete** — Write what you learned to mark it done
5. **Build Streaks** — Stay consistent and watch your progress grow

## 🎯 Why ProgressPal?

| Regular To-Do Apps | ProgressPal |
|-------------------|-------------|
| ✅ Mindless checking | ✍️ Intentional reflection |
| 📋 Task lists | 📚 Learning tracks |
| ❌ No accountability | 🔥 Streak motivation |
| 🤷 Generic goals | 🤖 AI-tailored suggestions |
| ☁️ Cloud-dependent | 📱 100% offline |

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is open source. See the LICENSE file for details.

## 📬 Contact

Have questions or feedback? Email: ali.the.ahmed18@gmail.com

---

**Stop checking boxes. Start learning.**

[Download on Google Play](https://play.google.com/store/apps/details?id=com.spudbyte.progresspal)