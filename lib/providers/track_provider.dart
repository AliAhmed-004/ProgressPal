import 'package:flutter/material.dart';
import 'package:progresspal/models/track_entry.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:progresspal/services/hive_database.dart';
import 'package:uuid/uuid.dart';

import '../models/goal.dart';

class TrackProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();
  List<TrackEntry> _tracks = [];
  String? _selectedTrackId;

  List<TrackEntry> get tracks => _tracks;
  String get selectedTrackId => _selectedTrackId ?? _tracks.first.id;

  // Setter for selectedTrackId
  set selectedTrackId(String? value) {
    _selectedTrackId = value;
    notifyListeners(); // Notify listeners when the value changes
  }

  TrackProvider() {
    loadEntries();
  }

  // Method to add a new goal to the selected track
  void addGoal(String goalTitle) {
    final track = _tracks.firstWhere((t) => t.id == _selectedTrackId);

    track.goals.add(Goal(title: goalTitle)); // Update goals list

    track.save(); // 🔥 Save updated TrackEntry to Hive
    notifyListeners();
  }

  // Getter for entries:
  List<TrackEntry> get entries => _tracks;

  // Load entries:
  Future<void> loadEntries() async {
    _tracks = _db.getEntries();
    if (_tracks.isNotEmpty) {
      _selectedTrackId = _tracks[0].id; // Default to first track
    }
    notifyListeners();
  }

  // Method to select a track
  void selectTrack(String id) {
    _selectedTrackId = id;
    notifyListeners();
  }

  // Getter for selected track
  TrackEntry get selectedTrack => _tracks.firstWhere(
    (track) => track.id == selectedTrackId,
    orElse:
        () =>
            _tracks.isNotEmpty
                ? _tracks.first
                : TrackEntry(
                  id: '',
                  title: '',
                  goals: [],
                  date: DateTime.now(),
                ),
  );

  // Add new progress entry:
  Future<String> addTrack(String title) async {
    // Create the Progress Entry
    final entry = TrackEntry(
      id: const Uuid().v4(),
      title: title,
      goals: [],
      date: DateTime.now(),
    );

    // Add the entry to the Hive database
    await _db.addEntry(entry);

    // Add the entry to the list of entries
    _tracks.add(entry);

    // Notify the listeners
    notifyListeners();

    // return the track's id
    return entry.id;
  }

  // Delete a Track Entry
  Future<void> deleteTrack(String id) async {
    // Delete the entry from the Hive database
    await _db.deleteEntry(id);

    // Remove the entry from the list
    _tracks.removeWhere((entry) => entry.id == id);

    // Notify the listeners
    notifyListeners();
  }

  // GOAL RELATED METHODS
  void deleteGoal(int index) {
    // Get the track for which the goal is to be deleted
    final track = _tracks.firstWhere((t) => t.id == _selectedTrackId);

    if (index >= 0 && index < track.goals.length) {
      // Remove the goal from the track
      track.goals.removeAt(index);

      // Save the updated track
      track.save();

      // Notify the listeners
      notifyListeners();
    }
  }

  // Toggle goal completion
  void toggleGoalCompletion(
    int index,
    String description,
    StreakProvider streakProvider,
  ) {
    final track = _tracks.firstWhere((t) => t.id == _selectedTrackId);

    if (index >= 0 && index < track.goals.length) {
      final goal = track.goals[index];
      goal.description = description;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Toggle completion status
      bool newStatus = !goal.isCompleted;
      setGoalCompletionStatus(goal, newStatus);

      // Update streak
      if (newStatus) {
        streakProvider.markGoalCompleted(goal, today);
      } else {
        streakProvider.unmarkGoalCompleted(goal, today);
      }

      // Save changes
      track.save();
      streakProvider.saveStreak();
      streakProvider.notifyListeners();
      notifyListeners();
    }
  }

  // Separate method to handle goal state updates
  void setGoalCompletionStatus(Goal goal, bool isCompleted) {
    goal.isCompleted = isCompleted;
  }
}
