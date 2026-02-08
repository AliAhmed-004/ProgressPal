import 'package:flutter/material.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:progresspal/services/celebration_service.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';
import '../providers/track_provider.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<TrackProvider>(
      builder: (context, provider, child) {
        final selectedTrack = provider.selectedTrack;

        return AppBar(
          title: Text(
            selectedTrack.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          actions: [
            // Streak Display with Celebration
            Consumer<StreakProvider>(
              builder: (context, streakProvider, child) {
                final streak = streakProvider.streak;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      StreakCelebrationWidget(
                        child: Text(
                          '🔥 ${streak.currentStreak}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '🏆 ${streak.highestStreak}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Settings Icon
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
