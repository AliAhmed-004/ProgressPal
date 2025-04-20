import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get currentTheme {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  void setTheme(AppThemeMode mode) {
    _themeMode = mode;
    Hive.box('settings').put('themeMode', mode.index); // save preference
    notifyListeners();
  }

  void _loadTheme() {
    final index = Hive.box('settings').get('themeMode', defaultValue: 0);
    _themeMode = AppThemeMode.values[index];
  }
}
