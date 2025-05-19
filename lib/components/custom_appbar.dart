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
              if (tracks.isNotEmpty)
                PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (String newId) {
                    provider.selectTrack(newId);
                  },
                  itemBuilder: (BuildContext context) {
                    final sortedTracks = [...tracks]..sort(
                      (a, b) => b.date.compareTo(a.date),
                    ); // Most recent first

                    return sortedTracks.map((track) {
                      return PopupMenuItem<String>(
                        value: track.id,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(track.title)),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (action) async {
                                if (action == 'rename') {
                                  final controller = TextEditingController(
                                    text: track.title,
                                  );
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text('Rename Track'),
                                          content: TextField(
                                            controller: controller,
                                            decoration: InputDecoration(
                                              labelText: 'New track name',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: Text('Save'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirmed == true &&
                                      controller.text.trim().isNotEmpty) {
                                    provider.updateTrackTitle(
                                      track.id,
                                      controller.text,
                                    );
                                    Navigator.pop(context);
                                  }
                                }

                                if (action == 'delete') {
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
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
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
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (finalConfirmed == true) {
                                    provider.deleteTrack(track.id);
                                    Future.microtask(() {
                                      Navigator.pop(context);
                                    });
                                  }
                                }
                              },
                              itemBuilder:
                                  (_) => [
                                    PopupMenuItem(
                                      value: 'rename',
                                      child: Text('Rename'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
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
                )
              else
                const Text('No track selected', style: TextStyle(fontSize: 16)),
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
