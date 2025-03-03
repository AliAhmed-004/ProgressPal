import 'package:hive/hive.dart';
import 'package:progresspal/models/goal.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 2)
class StreakModel extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int highestStreak;

  @HiveField(2)
  DateTime? lastUpdated;

  @HiveField(3)
  Map<DateTime, List<Goal>> completedDates;

  StreakModel({
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.lastUpdated,
    Map<DateTime, List<Goal>>? completedDates, // Nullable parameter
  }) : completedDates = completedDates ?? {}; // Mutable list initialization
}
