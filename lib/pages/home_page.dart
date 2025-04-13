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
import 'package:progresspal/pages/testing_page.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:progresspal/providers/track_provider.dart';
import 'package:progresspal/services/ad_service.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _scheduleReminders();
  }

  // Load the banner ad
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      //TODO Replace with actual ad id
      adUnitId:
          "ca-app-pub-3940256099942544/6300978111", // Test banner ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("Ad Loaded!");
          setState(() {
            _isAdLoaded = true; // Set the ad loaded state
          });
        },
        onAdFailedToLoad: (ad, error) {
          print("Failed to load ad: ${error.code} - ${error.message}");
          ad.dispose();
          setState(() {
            _isAdLoaded = false; // Set the ad loaded state to false
          });
        },
      ),
    )..load();
  }

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
    final track = trackProvider.selectedTrack;

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
            child: Icon(Icons.bolt),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestingPage()),
                ),
          ),
          SpeedDialChild(
            child: Icon(Icons.add_rounded),
            onTap: () => showAddTrackDialog(context),
          ),
          SpeedDialChild(
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  addGoalsButton(context),
                ],
              ),
            ),

            // Checklist of Goals with Animated Checkboxes
            if (track.goals.isEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('No Goals Added to Current Track'),
                  SizedBox(height: 8),
                  Text("Press the '+' button above to add one"),
                ],
              ),

            Expanded(
              child: ListView.builder(
                itemCount: track.goals.length,
                itemBuilder: (context, index) {
                  final goal = track.goals[index];

                  return ListTile(
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        goal.description.isNotEmpty
                            ? "What you learnt: ${goal.description}"
                            : "No description added",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      goal.title,
                      style: TextStyle(
                        decoration:
                            goal.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        // Show confirmation dialog before deleting
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Goal?'),
                              content: Text(
                                'Are you sure you want to delete this goal? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      false,
                                    ); // Do not delete
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      true,
                                    ); // Confirm deletion
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          // If the user confirms, delete the goal
                          trackProvider.deleteGoal(index);
                        }
                      },
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    ),
                    leading: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Column(
                        children: [
                          Checkbox(
                            key: ValueKey(goal.isCompleted),
                            value: goal.isCompleted,
                            onChanged: (value) {
                              // toggle completion
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
                    ),
                  );
                },
              ),
            ),
            if (_isAdLoaded)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget addGoalsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () async {
        String? newGoal = await showDialog(
          context: context,
          builder: (context) {
            TextEditingController controller = TextEditingController();
            return AlertDialog(
              content: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Enter goal title'),
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
                    Navigator.pop(context, controller.text);
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
