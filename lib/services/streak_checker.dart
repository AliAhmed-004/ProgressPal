import 'package:hive/hive.dart';

class StreakChecker {
  Future<bool> hasCompletedGoalsTodayFromHive() async {
    final box = await Hive.openBox('streakBox');
    final completedDates = box.get('completedDates') as Map;

    final today = DateTime.now();
    final todayDate =
        DateTime(today.year, today.month, today.day).toIso8601String();

    final goalsToday = completedDates[todayDate];
    return goalsToday != null && goalsToday.isNotEmpty;
  }
}
