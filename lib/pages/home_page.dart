import 'package:flutter/material.dart';
import 'package:progresspal/components/custom_appbar.dart';
import 'package:progresspal/components/custom_weekly_calendar.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:progresspal/providers/track_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final streakProvider = Provider.of<StreakProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);
    final track = trackProvider.selectedTrack;

    return Scaffold(
      appBar: CustomAppbar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTrackDialog(context),
        child: Icon(Icons.add),
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

                  // Update the streak
                  //Provider.of<StreakProvider>(context, listen: false)
                  //    .updateStreak();

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
}
