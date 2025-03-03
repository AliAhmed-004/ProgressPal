import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:progresspal/models/streak_model.dart';

import '../models/goal.dart';
import '../services/hive_database.dart';

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

          // Do NOT update `lastUpdated` here. Only reset streak.
          // Optional: Clear invalid dates if necessary
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

    // ✅ Check if today already exists in the map BEFORE adding the goal
    bool isNewStreakDay = !_streak.completedDates.containsKey(today);

    // Add goal to today's list
    _streak.completedDates.putIfAbsent(today, () => []);
    _streak.completedDates[today]!.add(completedGoal);

    if (_streak.lastUpdated != null) {
      final lastDate = DateTime(
        _streak.lastUpdated!.year,
        _streak.lastUpdated!.month,
        _streak.lastUpdated!.day,
      );

      if (today.difference(lastDate).inDays == 1 && isNewStreakDay) {
        // ✅ Increment streak for consecutive days (only on first goal of the day)
        _streak.currentStreak++;
      } else if (today.difference(lastDate).inDays > 1) {
        // ✅ Reset streak if there's a gap in days
        _streak.currentStreak = 1;
      }
    } else {
      // ✅ First streak entry
      _streak.currentStreak = 1;
    }

    // ✅ Update highest streak if needed
    if (_streak.currentStreak > _streak.highestStreak) {
      _streak.highestStreak = _streak.currentStreak;
    }

    // ✅ Update lastUpdated
    _streak.lastUpdated = today;

    // ✅ Save changes to Hive
    _streak.save();
    notifyListeners();

    print("Current Streak: ${_streak.currentStreak}");
    print("Completed Goals: ${_streak.completedDates[today]!}");
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
}
