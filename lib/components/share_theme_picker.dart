import 'package:flutter/material.dart';
import 'insights_share_card.dart';

/// A bottom sheet that allows users to pick a theme for their share image.
class ShareThemePicker extends StatefulWidget {
  final Function(ShareCardTheme) onThemeSelected;

  const ShareThemePicker({
    super.key,
    required this.onThemeSelected,
  });

  /// Shows the theme picker bottom sheet and returns the selected theme.
  static Future<ShareCardTheme?> show(BuildContext context) {
    return showModalBottomSheet<ShareCardTheme>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareThemePicker(
        onThemeSelected: (theme) => Navigator.pop(context, theme),
      ),
    );
  }

  @override
  State<ShareThemePicker> createState() => _ShareThemePickerState();
}

class _ShareThemePickerState extends State<ShareThemePicker> {
  ShareCardTheme _selectedTheme = ShareCardTheme.dark;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Share Your Progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a style for your share image',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 28),

            // Theme options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _ThemeOption(
                      label: 'Dark',
                      subtitle: 'Bold & Modern',
                      icon: Icons.dark_mode_rounded,
                      gradientColors: const [
                        Color(0xFF1A1A2E),
                        Color(0xFF0F3460),
                      ],
                      isSelected: _selectedTheme == ShareCardTheme.dark,
                      onTap: () =>
                          setState(() => _selectedTheme = ShareCardTheme.dark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ThemeOption(
                      label: 'Light',
                      subtitle: 'Clean & Minimal',
                      icon: Icons.light_mode_rounded,
                      gradientColors: const [
                        Color(0xFFF8FAFC),
                        Color(0xFFEEF2FF),
                      ],
                      isSelected: _selectedTheme == ShareCardTheme.light,
                      onTap: () =>
                          setState(() => _selectedTheme = ShareCardTheme.light),
                      isLight: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Share button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => widget.onThemeSelected(_selectedTheme),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text(
                    'Generate & Share',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// A single theme option card
class _ThemeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLight;

  const _ThemeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.isSelected,
    required this.onTap,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isLight ? Border.all(color: Colors.black12) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.05 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLight
                      ? Colors.black.withOpacity(0.05)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isLight ? const Color(0xFF1E293B) : Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLight ? const Color(0xFF1E293B) : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isLight
                      ? const Color(0xFF64748B)
                      : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
