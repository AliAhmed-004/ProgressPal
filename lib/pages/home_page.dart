import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:progresspal/components/custom_appbar.dart';
import 'package:progresspal/components/custom_weekly_calendar.dart';
import 'package:progresspal/components/generated_goals_dialog.dart';
import 'package:progresspal/gemini/gemini_helper.dart';
import 'package:progresspal/models/track_entry.dart';
import 'package:progresspal/pages/pomodoro_page.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:progresspal/providers/track_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  // bool _isAdLoaded = false;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    // _loadBannerAd();
    _scheduleReminders();
  }

  // Load the banner ad
  // void _loadBannerAd() {
  //   _bannerAd = BannerAd(
  //     adUnitId: "ca-app-pub-3940256099942544/6300978111", // Test banner ad ID
  //     // AdService.bannerAdUnitId,
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (ad) {
  //         print("Ad Loaded!");
  //         setState(() {
  //           _isAdLoaded = true; // Set the ad loaded state
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         print("Failed to load ad: ${error.code} - ${error.message}");
  //         ad.dispose();
  //         setState(() {
  //           _isAdLoaded = false; // Set the ad loaded state to false
  //         });
  //       },
  //     ),
  //   )..load();
  // }

  // check and schedule the reminders
  void _scheduleReminders() {
    final streakProvider = Provider.of<StreakProvider>(context, listen: false);

    if (!streakProvider.hasCompletedGoalsToday() &&
        streakProvider.streak.currentStreak > 0) {
      streakProvider.checkAndScheduleStreakNotification();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose(); // Dispose of the ad when the widget is disposed
  }

  @override
  Widget build(BuildContext context) {
    final streakProvider = Provider.of<StreakProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);
    // final tracks = trackProvider.tracks;
    final selectedTrack = trackProvider.selectedTrack;

    return Scaffold(
      appBar: CustomAppbar(),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        overlayColor: Colors.black,
        overlayOpacity: 0.3,
        spacing: 10,
        children: [
          SpeedDialChild(
            label: "New Track",
            child: Icon(Icons.add_rounded),
            onTap: () => showAddTrackDialog(context),
          ),
          SpeedDialChild(
            label: "Pomodoro",
            child: Icon(Icons.timer_rounded),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PomodoroScreen()),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Weekly Calendar
            CustomWeeklyCalendar(),

            // Circular Progress Indicator
            buildCircularProgress(selectedTrack, context),

            buildGoalsList(selectedTrack, trackProvider, streakProvider),

            // if (_isAdLoaded) buildAdWidget(),
          ],
        ),
      ),
    );
  }

  /* 
    ==================
    | HELPER METHODS |
    ==================
  */
  SizedBox buildAdWidget() {
    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget buildGoalsList(
    TrackEntry track,
    TrackProvider trackProvider,
    StreakProvider streakProvider,
  ) {
    if (trackProvider.tracks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('There is no Track created'),
          SizedBox(height: 8),
          Text(
            "Add one by pressing the blue button below, and then the '+' button",
          ),
        ],
      );
    } else if (track.goals.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('No Goals Added to Current Track'),
          SizedBox(height: 8),
          Text("Press the '+' button above to add one"),
        ],
      );
    }
    return Expanded(
      child: ReorderableListView.builder(
        padding: EdgeInsets.only(bottom: 20),
        buildDefaultDragHandles: false,
        onReorderStart: (index) {
          setState(() => _draggingIndex = index);
        },
        onReorderEnd: (_) {
          setState(() => _draggingIndex = null);
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          trackProvider.reorderGoal(oldIndex, newIndex);
        },
        itemCount: track.goals.length,
        itemBuilder: (context, index) {
          final goal = track.goals[index];
          return Container(
            key: ValueKey(goal),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _draggingIndex == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                  ),
                  Checkbox(
                    value: goal.isCompleted,
                    onChanged: (value) {
                      if (!goal.isCompleted) {
                        showAddDescriptionDialog(context, index);
                      } else {
                        trackProvider.toggleGoalCompletion(
                          index,
                          "",
                          streakProvider,
                        );
                      }
                    },
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        decoration:
                            goal.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      softWrap: true,
                    ),
                  ),
                  IconButton(
                    icon: Text('Edit', style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      final controller = TextEditingController(
                        text: goal.title,
                      );
                      final shouldSave = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text("Rename Goal"),
                              content: TextField(
                                controller: controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: "Enter new goal title",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text("Save"),
                                ),
                              ],
                            ),
                      );

                      if (shouldSave == true) {
                        final newTitle = controller.text.trim();
                        if (newTitle.isNotEmpty && newTitle != goal.title) {
                          goal.title = newTitle;
                          track.save(); // Save the modified TrackEntry to Hive
                          trackProvider.trackNotifyListeners();
                        }
                      }
                    },
                  ),
                ],
              ),

              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  goal.description.isNotEmpty
                      ? "What you learnt: ${goal.description}"
                      : "No description added",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              trailing: IconButton(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Delete Goal?'),
                          content: Text(
                            'Are you sure you want to delete this goal? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (shouldDelete == true) {
                    trackProvider.deleteGoal(index);
                  }
                },
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              ),
            ),
          );
        },
      ),
    );
  }

  Padding buildCircularProgress(TrackEntry track, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: track.completionPercentage / 100,
                        ),
                        duration: Duration(
                          milliseconds: 700,
                        ), // Smooth animation
                        curve: Curves.easeOut, // Eases out smoothly
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value, // Animated progress
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                            strokeWidth: 6,
                          );
                        },
                      ),
                      Center(
                        child: Text(
                          "${track.completionPercentage.toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "Your Progress",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          addGoalsButton(context),
        ],
      ),
    );
  }

  Widget addGoalsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () async {
        final formKey = GlobalKey<FormState>();
        final TextEditingController controller = TextEditingController();

        String? newGoal = await showDialog<String>(
          context: context,
          barrierDismissible: false, // Prevents closing on outside tap
          builder: (context) {
            return AlertDialog(
              title: Text('Add Goal'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter goal title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Goal title is required';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, controller.text.trim());
                    }
                    // Else: stays open and shows error
                  },
                  child: Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    showGeneratedGoals();
                  },
                  child: Text('Generate Goals'),
                ),
              ],
            );
          },
        );

        if (newGoal != null && newGoal.trim().isNotEmpty) {
          Provider.of<TrackProvider>(context, listen: false).addGoal(newGoal);
        }
      },
    );
  }

  // Show the "add description" dialog box
  void showAddDescriptionDialog(BuildContext context, int index) {
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              label: Text("So, what have you learned?"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty) {
                  final streakProvider = Provider.of<StreakProvider>(
                    context,
                    listen: false,
                  );

                  // Toggle the completion
                  Provider.of<TrackProvider>(
                    context,
                    listen: false,
                  ).toggleGoalCompletion(
                    index,
                    descriptionController.text,
                    streakProvider,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Description Added')),
                  );
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // Show the "add new track" dialog box
  void showAddTrackDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Track'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Track Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final newTrackId = await Provider.of<TrackProvider>(
                    context,
                    listen: false,
                  ).addTrack(titleController.text);
                  Provider.of<TrackProvider>(context, listen: false)
                      .selectedTrackId = newTrackId;
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showGeneratedGoals() async {
    GeminiGoalGenerator goalGenerator = GeminiGoalGenerator();

    TrackEntry currentTrack =
        Provider.of<TrackProvider>(context, listen: false).selectedTrack;
    List<String> existingGoals =
        currentTrack.goals.map((goal) => goal.title).toList();

    // Close the 'Add Goal' dialog
    Navigator.pop(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Generating goals..."),
              ],
            ),
          ),
    );

    try {
      List<String> goals = await goalGenerator.generateGoals(
        currentTrack.title,
        existingGoals,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show results
      showDialog(
        context: context,
        builder: (_) => GeneratedGoalsDialog(goals: goals),
      );
    } on SocketException catch (_) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your Wi-Fi."),
        ),
      );
    } on GenerativeAIException catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (e.message.contains('503')) {
        _showError(
          "The AI model is currently overloaded. Please try again in a few moments.",
        );
      } else {
        _showError("AI generation failed: ${e.message}");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to generate goals: $e")));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
