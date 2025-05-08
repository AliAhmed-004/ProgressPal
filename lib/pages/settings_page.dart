import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Theme", style: TextStyle(fontSize: 18)),
                  DropdownButton<AppThemeMode>(
                    value: context.watch<ThemeProvider>().themeMode,
                    items:
                        AppThemeMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(
                              mode.toString().split('.').last.toUpperCase(),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<ThemeProvider>().setTheme(value);
                      }
                    },
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
