import 'package:hive/hive.dart';

import 'goal.dart';

part 'track_entry.g.dart';

@HiveType(typeId: 0)
class TrackEntry extends HiveObject {
  @HiveField(0)
  final String id; // Unique ID

  @HiveField(1)
  final String title; // What the user is tracking

  @HiveField(2)
  List<Goal> goals = [
    Goal(title: "This is a demo goal. Add new from the '+' button above."),
  ];

  @HiveField(4)
  final DateTime date; // Progress date

  TrackEntry({
    required this.id,
    required this.title,
    required this.goals,
    required this.date,
  });

  double get completionPercentage {
    if (goals.isEmpty) return 0;
    int completedCount = goals.where((goal) => goal.isCompleted).length;
    return (completedCount / goals.length) * 100;
  }
}
