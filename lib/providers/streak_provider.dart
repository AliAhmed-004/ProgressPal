import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:progresspal/models/streak_model.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/goal.dart';
import '../services/hive_database.dart';
import '../services/noti_service.dart';

class StreakProvider extends ChangeNotifier {
  StreakModel _streak = StreakModel();

  StreakModel get streak => _streak;

  Future<void> loadStreak() async {
    final box = Hive.box<StreakModel>(HiveDatabase.streakBoxName);

    if (box.isNotEmpty) {
      // Load the streak
      _streak = box.getAt(0)!;

      // Handle streak reset logic
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_streak.lastUpdated != null) {
        final lastDate = DateTime(
          _streak.lastUpdated!.year,
          _streak.lastUpdated!.month,
          _streak.lastUpdated!.day,
        );

        final difference = today.difference(lastDate).inDays;

        if (difference > 1) {
          // Reset streak if there has been a gap of more than 1 day
          _streak.currentStreak = 0;
          _streak.lastUpdated = today.subtract(const Duration(days: 1));
          _streak.completedDates.removeWhere((date, goals) {
            return date.isAfter(lastDate) && date.isBefore(today);
          });
        }
      }
    } else {
      // Initialize a new streak if none exists
      _streak = StreakModel();
      await box.add(_streak);
    }

    notifyListeners(); // Notify UI about changes
  }

  void updateStreak(Goal completedGoal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ✅ Check if today is a new streak day BEFORE adding the goal

    if (_streak.lastUpdated != null) {
      final lastDate = DateTime(
        _streak.lastUpdated!.year,
        _streak.lastUpdated!.month,
        _streak.lastUpdated!.day,
      );

      if (today.difference(lastDate).inDays == 1) {
        // ✅ Increment streak for consecutive days (only once per day)
        _streak.currentStreak++;

        // ✅ Update lastUpdated
        _streak.lastUpdated = today;
      } else if (today.difference(lastDate).inDays > 1) {
        // ✅ Reset streak if there's a gap in days
        _streak.currentStreak = 0;
      }
    } else {
      // ✅ Ensure first streak entry starts at 1
      _streak.currentStreak = 1;
    }

    // ✅ Update highest streak if needed
    if (_streak.currentStreak > _streak.highestStreak) {
      _streak.highestStreak = _streak.currentStreak;
    }

    // ✅ Save changes to Hive
    _streak.save();
    notifyListeners();
  }

  // Mark a goal as completed
  void markGoalCompleted(Goal goal, DateTime today) {
    streak.completedDates.putIfAbsent(today, () => []);
    streak.completedDates[today]!.add(goal);

    if (streak.lastUpdated == null || streak.lastUpdated != today) {
      updateStreak(goal);
    }

    streak.lastUpdated = today;

    // cancel notifications for today
    NotiService().cancelAllNotifications();

    // Schedule tomorrow's reminder (if streak is still > 0)
    if (streak.currentStreak > 0) {
      final tomorrow = tz.TZDateTime.now(tz.local).add(Duration(days: 1));
      final scheduledDate = tz.TZDateTime(
        tz.local,
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        19, // 7 PM
        0,
      );

      NotiService().scheduleNotification(
        title: 'Keep it going!',
        body:
            'Don\'t forget to complete a goal today to keep your streak alive 🔥',
        scheduledDate: scheduledDate,
      );
    }
  }

  // Unmark a goal as completed
  void unmarkGoalCompleted(Goal goal, DateTime today) {
    streak.completedDates[today]?.removeWhere((g) => g.title == goal.title);

    if (streak.completedDates[today]?.isEmpty ?? true) {
      streak.completedDates.remove(today);

      if (streak.lastUpdated == today) {
        decrementStreak();

        final previousDates = streak.completedDates.keys.toList();
        previousDates.sort(); // Ensure they're sorted in ascending order

        if (previousDates.isNotEmpty) {
          streak.lastUpdated = previousDates.last;
        } else {
          streak.lastUpdated = null;
          streak.currentStreak = 0; // Reset streak fully
        }
      }
    }
  }

  void saveStreak() {
    _streak.save();
  }

  void decrementStreak() {
    if (streak.currentStreak > 0) {
      streak.currentStreak--;
      saveStreak();
      notifyListeners();
    }
  }

  void checkAndScheduleStreakNotification() {
    if (!hasCompletedGoalsToday() && _streak.currentStreak > 0) {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        19, // 7 PM
        0,
      );

      if (scheduledDate.isAfter(now)) {
        NotiService().scheduleNotification(
          title: 'Your streak is in danger!',
          body: 'Complete a goal to improve and keep the streak alive!',
          scheduledDate: scheduledDate,
        );
      }
    }
  }

  bool hasCompletedGoalsToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final goalsToday = _streak.completedDates[todayDate];
    return goalsToday != null && goalsToday.isNotEmpty;
  }
}
