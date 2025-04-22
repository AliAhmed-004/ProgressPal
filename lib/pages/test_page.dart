import 'package:flutter/material.dart';
import 'package:progresspal/providers/track_provider.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => addTracksAndGoals(context),
                child: Text("Add Goals and tracks"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTracksAndGoals(BuildContext context) async {
    final trackProvider = Provider.of<TrackProvider>(context, listen: false);

    for (int i = 1; i <= 100; i++) {
      final trackId = await trackProvider.addTrack("Track $i");
      final track = trackProvider.tracks.firstWhere((t) => t.id == trackId);

      // Add goals manually to this specific track
      for (int j = 1; j <= 100; j++) {
        track.goals.add(Goal(title: "Goal $j of Track $i"));
      }

      // Save changes to Hive
      await track.save();
    }

    // Update the UI after bulk changes
    trackProvider.notifyListeners();
  }
}
