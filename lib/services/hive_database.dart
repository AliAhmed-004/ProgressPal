import 'package:hive_flutter/adapters.dart';

import '../models/goal.dart';
import '../models/streak_model.dart';
import '../models/track_entry.dart';

class HiveDatabase {
  static const String trackBoxName = 'trackBox';
  static const String streakBoxName = 'streakBox';

  // Initializes Hive, registers adapters, and opens boxes
  Future<void> initHive() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(TrackEntryAdapter());
    Hive.registerAdapter(StreakModelAdapter());

    // Open Boxes
    await Hive.openBox<TrackEntry>(trackBoxName);
    await Hive.openBox<StreakModel>(streakBoxName);

    _ensureDefaultTrack();
  }

  void _ensureDefaultTrack() {
    if (!Hive.isBoxOpen(trackBoxName)) {
      throw Exception(
        'trackBox is not open. Ensure it is opened before calling _ensureDefaultTrack.',
      );
    }

    final box = Hive.box<TrackEntry>(trackBoxName);
    if (box.isEmpty) {
      final defaultTrack = TrackEntry(
        id: 'default',
        title: 'Explore ProgressPal',
        goals: [
          Goal(title: 'Add your first goal!', isCompleted: false),
          Goal(title: 'Check off a completed goal', isCompleted: false),
          Goal(title: 'Create a new track', isCompleted: false),
        ],
        date: DateTime.now(),
      );

      box.put(defaultTrack.id, defaultTrack);
    }
  }

  // Getter for the trackBox
  Box<TrackEntry> get _box => Hive.box<TrackEntry>(trackBoxName);

  // CRUD Operations
  Future<void> addEntry(TrackEntry entry) async {
    final box = Hive.box<TrackEntry>(trackBoxName);
    await box.put(entry.id, entry);
  }

  List<TrackEntry> getEntries() {
    final box = Hive.box<TrackEntry>(trackBoxName);
    return box.values.toList();
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> updateEntryGoals(TrackEntry updatedEntry) async {
    final box = Hive.box<TrackEntry>(trackBoxName);

    // Retrieve the existing entry (if it exists)
    final existingEntry = box.get(updatedEntry.id);

    if (existingEntry != null) {
      // Modify the existing entry fields
      existingEntry.goals = updatedEntry.goals;

      // Save the updated entry back to the box
      await box.put(existingEntry.id, existingEntry);
    } else {
      // Handle the case where the entry does not exist
      throw Exception('Entry with id ${updatedEntry.id} does not exist.');
    }
  }
}
