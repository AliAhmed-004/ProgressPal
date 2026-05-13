# Contributing to ProgressPal

Thank you for your interest in contributing to ProgressPal! This document provides guidelines and instructions for contributing.

## 📋 Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful in all interactions.

## 🐛 Found a Bug?

If you discover a bug, please open an issue with:
- Clear description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Your environment (Flutter version, device/OS, etc.)

## 💡 Feature Suggestions

We welcome feature ideas! Please open an issue with:
- Clear description of the proposed feature
- Use cases and benefits
- Any mockups or examples (if applicable)

## 🔄 Pull Requests

### Before You Start
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Ensure you have Flutter SDK 3.7+ installed

### Setup Development Environment
```bash
flutter pub get
```

### While Developing
- Follow Dart [effective style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` to check for issues
- Keep commits focused and descriptive
- Add comments for complex logic

### Before Submitting PR
1. Test your changes: `flutter test`
2. Format code: `flutter format lib/ test/`
3. Run analysis: `flutter analyze`
4. Update README if needed
5. Add entry to CHANGELOG.md

### PR Requirements
- Clear title and description
- Link to related issues
- Screenshot/video if UI changes
- No breaking changes without discussion

## 📚 Project Structure

```
lib/
├── main.dart                 # App entry point
├── pages/                    # Full-screen widgets
├── components/               # Reusable UI widgets
├── providers/                # State management (Provider)
├── services/                 # Business logic & external services
├── models/                   # Data models
├── themes/                   # Theme configuration
├── gemini/                   # AI goal generation
└── secrets/                  # API keys (not in git)
```

## 🔐 Security

- Never commit API keys or sensitive data
- Use `lib/secrets/secrets.dart` for local keys
- Review [.gitignore](.gitignore) before committing

## 📝 Development Tips

### State Management
We use `Provider` for state management. Key providers:
- `ThemeProvider` - Theme switching
- `TrackProvider` - Track/goal data
- `StreakProvider` - Streak calculations

### Local Database
We use `Hive` for local storage:
- Models use `@HiveType()` and `@HiveField()` decorators
- Run `flutter pub run build_runner build` after model changes

### Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Place tests in `test/` directory

## 📞 Questions?

Feel free to open a discussion issue or reach out to the maintainers.

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.
