import 'package:flutter/material.dart';
import 'package:progresspal/providers/streak_provider.dart';
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
        final tracks = provider.entries; // Get all tracks

        return AppBar(
          title: Row(
            children: [
              PopupMenuButton<String>(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (String newId) {
                  provider.selectTrack(newId);
                },
                itemBuilder: (BuildContext context) {
                  final sortedTracks = [...tracks]
                    ..sort((a, b) => b.date.compareTo(a.date)); // Oldest first

                  return sortedTracks.map((track) {
                    return PopupMenuItem<String>(
                      value: track.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(track.title),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final hasIncompleteGoals = track.goals.any(
                                (goal) => !goal.isCompleted,
                              );

                              // Step 1: Show initial warning/confirmation dialog
                              final initialConfirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Delete Track?'),
                                      content: Text(
                                        hasIncompleteGoals
                                            ? 'This track has incomplete goals. Do you really want to delete it?'
                                            : 'Are you sure you want to delete the track "${track.title}"? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: Text(
                                            'Continue',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (initialConfirm != true) return;

                              // Step 2: Require user to type track name
                              final controller = TextEditingController();
                              final finalConfirmed = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Type to Confirm'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'To prevent accidental deletion of the track, type its name for confirmation:\n\n"${track.title}"',
                                          ),
                                          SizedBox(height: 12),
                                          TextField(
                                            controller: controller,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Track name',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final input =
                                                controller.text.trim();
                                            if (input == track.title) {
                                              Navigator.pop(context, true);
                                            } else {
                                              Navigator.pop(context, false);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Track name did not match. Deletion cancelled.',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Confirm Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );

                              if (finalConfirmed == true) {
                                provider.deleteTrack(track.id);
                                Navigator.pop(context); // Close menu
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  children: [
                    Text(
                      selectedTrack.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Streak Display
            Consumer<StreakProvider>(
              builder: (context, streakProvider, child) {
                final streak = streakProvider.streak;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '🔥 ${streak.currentStreak}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '🏆 ${streak.highestStreak}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Settings Icon
            IconButton(
              icon: Icon(Icons.settings),
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
