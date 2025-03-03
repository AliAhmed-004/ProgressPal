import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light, // Set to light theme
      primary: Color(0xFF1565C0), // Deep Sky Blue
      onPrimary: Colors.white, // Text/Icon color on primary
      secondary: Color(0xFF82B1FF), // Light Blue Accent
      onSecondary: Colors.black, // Text/Icon color on secondary
      error: Color(0xFFD32F2F), // Red for errors
      onError: Colors.white, // Text/Icon color on error
      surface: Colors.white, // Surface color
      onSurface: Color(0xFF212121), // Text color on surface
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark, // Set to dark theme
      primary: Color(0xFF1E88E5), // Medium Blue
      onPrimary: Colors.white, // Text/Icon color on primary
      secondary: Color(0xFF4FC3F7), // Bright Cyan Accent
      onSecondary: Colors.black, // Text/Icon color on secondary
      error: Color(0xFFCF6679), // Pinkish-Red for errors
      onError: Colors.black, // Text/Icon color on error
      surface: Color(0xFF1E1E1E), // Slightly lighter surface color
      onSurface: Color(0xFFE3F2FD), // Light Blue Tint for text/icons on surface
    ),
  );
}
