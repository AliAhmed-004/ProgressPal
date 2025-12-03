import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/contribution_heatmap.dart';
import '../models/goal.dart';
import '../providers/track_provider.dart';
import '../providers/streak_provider.dart';

/// The Insights page displays a learning journal with:
/// - A contribution heatmap showing goal completion over time
/// - Summary statistics about user progress
/// - (Future) Timeline of completed goals with reflections
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Contribution Heatmap
              _buildHeatmapSection(context),

              const SizedBox(height: 24),

              // Section: Stats Summary
              _buildStatsSummarySection(context),

              const SizedBox(height: 24),

              // Section: Recent Reflections (placeholder for future)
              _buildRecentReflectionsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the contribution heatmap section.
  Widget _buildHeatmapSection(BuildContext context) {
    return Consumer2<TrackProvider, StreakProvider>(
      builder: (context, trackProvider, streakProvider, child) {
        // Aggregate completed goals by date from StreakProvider
        final heatmapData = _aggregateGoalsByDate(streakProvider);

        return _SectionCard(
          title: 'Activity',
          icon: Icons.grid_view_rounded,
          child: ContributionHeatmap(
            data: heatmapData,
            // Uses default 15 weeks, centered on current week
            baseColor: Theme.of(context).colorScheme.primary,
            onDayTap: (date, count) {
              _showDayDetails(context, date, count, streakProvider);
            },
          ),
        );
      },
    );
  }

  /// Builds the stats summary section.
  Widget _buildStatsSummarySection(BuildContext context) {
    return Consumer2<TrackProvider, StreakProvider>(
      builder: (context, trackProvider, streakProvider, child) {
        final stats = _calculateStats(trackProvider, streakProvider);

        return _SectionCard(
          title: 'Summary',
          icon: Icons.bar_chart_rounded,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatTile(
                icon: Icons.check_circle_outline_rounded,
                label: 'Goals Completed',
                value: stats.totalCompleted.toString(),
                color: Colors.green,
              ),
              _StatTile(
                icon: Icons.folder_outlined,
                label: 'Active Tracks',
                value: stats.totalTracks.toString(),
                color: Colors.blue,
              ),
              _StatTile(
                icon: Icons.local_fire_department_rounded,
                label: 'Current Streak',
                value: '${stats.currentStreak} days',
                color: Colors.orange,
              ),
              _StatTile(
                icon: Icons.emoji_events_outlined,
                label: 'Highest Streak',
                value: '${stats.highestStreak} days',
                color: Colors.amber,
              ),
              _StatTile(
                icon: Icons.edit_note_rounded,
                label: 'Reflections',
                value: stats.totalReflections.toString(),
                color: Colors.purple,
              ),
              _StatTile(
                icon: Icons.trending_up_rounded,
                label: 'This Week',
                value: stats.goalsThisWeek.toString(),
                color: Colors.teal,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the recent reflections section (placeholder for future).
  Widget _buildRecentReflectionsSection(BuildContext context) {
    return Consumer<TrackProvider>(
      builder: (context, trackProvider, child) {
        final recentGoals = _getRecentCompletedGoals(trackProvider, limit: 5);

        if (recentGoals.isEmpty) {
          return _SectionCard(
            title: 'Recent Reflections',
            icon: Icons.history_rounded,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No reflections yet',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete goals to see your learning journey',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _SectionCard(
          title: 'Recent Reflections',
          icon: Icons.history_rounded,
          child: Column(
            children:
                recentGoals.map((item) {
                  return _ReflectionTile(
                    goal: item.goal,
                    trackTitle: item.trackTitle,
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  /// Aggregates all completed goals by date for the heatmap.
  /// Returns a map of normalized dates to goal counts.
  /// Uses StreakProvider's completedDates which is the source of truth.
  Map<DateTime, int> _aggregateGoalsByDate(StreakProvider streakProvider) {
    final Map<DateTime, int> data = {};

    // StreakProvider stores completed goals in a Map<DateTime, List<Goal>>
    for (final entry in streakProvider.streak.completedDates.entries) {
      final date = entry.key;
      final goals = entry.value;

      // Normalize date to midnight (should already be, but ensure consistency)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Count the goals for this date
      data[normalizedDate] = goals.length;
    }

    return data;
  }

  /// Calculates summary statistics from track and streak data.
  _Stats _calculateStats(
    TrackProvider trackProvider,
    StreakProvider streakProvider,
  ) {
    int totalCompleted = 0;
    int totalReflections = 0;
    int goalsThisWeek = 0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    for (final track in trackProvider.entries) {
      for (final goal in track.goals) {
        if (goal.isCompleted) {
          totalCompleted++;

          // Count reflections (goals with non-empty descriptions)
          if (goal.description.isNotEmpty) {
            totalReflections++;
          }

          // Count goals completed this week
          if (goal.completedOn != null && goal.completedOn!.isAfter(weekAgo)) {
            goalsThisWeek++;
          }
        }
      }
    }

    return _Stats(
      totalCompleted: totalCompleted,
      totalTracks: trackProvider.entries.length,
      currentStreak: streakProvider.streak.currentStreak,
      highestStreak: streakProvider.streak.highestStreak,
      totalReflections: totalReflections,
      goalsThisWeek: goalsThisWeek,
    );
  }

  /// Gets the most recent completed goals with their track titles.
  List<_GoalWithTrack> _getRecentCompletedGoals(
    TrackProvider trackProvider, {
    int limit = 5,
  }) {
    final List<_GoalWithTrack> completedGoals = [];

    // Collect all completed goals with their track info
    for (final track in trackProvider.entries) {
      for (final goal in track.goals) {
        if (goal.isCompleted && goal.completedOn != null) {
          completedGoals.add(
            _GoalWithTrack(goal: goal, trackTitle: track.title),
          );
        }
      }
    }

    // Sort by completion date (most recent first)
    completedGoals.sort((a, b) {
      return b.goal.completedOn!.compareTo(a.goal.completedOn!);
    });

    // Return limited number
    return completedGoals.take(limit).toList();
  }

  /// Shows a bottom sheet with details for a specific day.
  void _showDayDetails(
    BuildContext context,
    DateTime date,
    int count,
    StreakProvider streakProvider,
  ) {
    // Get goals completed on this specific date from StreakProvider
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final goalsOnDay =
        streakProvider.streak.completedDates[normalizedDate] ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final dateStr = _formatDate(date);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count goal${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Goals list
                if (goalsOnDay.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text('No goals completed on this day'),
                    ),
                  )
                else
                  ...goalsOnDay.map((goal) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                      title: Text(goal.title),
                      subtitle:
                          goal.description.isNotEmpty
                              ? Text(
                                '"${goal.description}"',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                              : null,
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// A card wrapper for each section on the insights page.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section content
          child,
        ],
      ),
    );
  }
}

/// A single stat tile showing a metric with icon.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tile showing a single reflection entry.
class _ReflectionTile extends StatelessWidget {
  final Goal goal;
  final String trackTitle;

  const _ReflectionTile({required this.goal, required this.trackTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal title and track
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Track name and date
          Row(
            children: [
              Text(
                trackTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (goal.completedOn != null) ...[
                Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  _formatRelativeDate(goal.completedOn!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),

          // Reflection text
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${goal.description}"',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a date as a relative string (e.g., "Today", "Yesterday", "3 days ago").
  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }
}

/// Helper class to hold aggregated stats.
class _Stats {
  final int totalCompleted;
  final int totalTracks;
  final int currentStreak;
  final int highestStreak;
  final int totalReflections;
  final int goalsThisWeek;

  _Stats({
    required this.totalCompleted,
    required this.totalTracks,
    required this.currentStreak,
    required this.highestStreak,
    required this.totalReflections,
    required this.goalsThisWeek,
  });
}

/// Helper class to associate a goal with its track title.
class _GoalWithTrack {
  final Goal goal;
  final String trackTitle;

  _GoalWithTrack({required this.goal, required this.trackTitle});
}
