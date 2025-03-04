import 'package:flutter/material.dart';
import 'package:progresspal/providers/streak_provider.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';

class CustomWeeklyCalendar extends StatelessWidget {
  const CustomWeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the theme's color scheme and brightness
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 20,
        right: 20,
        bottom: 28.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? colorScheme
                      .surface // Dark mode uses surface color
                  : Colors.white, // Light mode uses pure white
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 8),
              color:
                  isDarkMode
                      ? Colors.white.withValues(
                        alpha: 0.2,
                      ) // White shadows for dark mode
                      : Colors.blueAccent.withValues(
                        alpha: 0.3,
                      ), // Light blue shadow
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Consumer<StreakProvider>(
          builder: (context, streakProvider, child) {
            final now = DateTime.now();
            final weekStart = now.subtract(
              Duration(days: now.weekday - 1),
            ); // Start of the week (Monday)
            final completedDates = streakProvider.streak.completedDates;

            return Column(
              children: [
                Text(
                  _getMonthName(now.month),
                  style: TextStyle(
                    height: 3,
                    letterSpacing: 2,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = weekStart.add(
                      Duration(days: index),
                    ); // Each day of the week

                    final isStreakContinued = completedDates.containsKey(
                      DateTime(day.year, day.month, day.day),
                    );

                    final isToday =
                        DateTime(now.year, now.month, now.day) ==
                        DateTime(day.year, day.month, day.day);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day name (e.g., "Mon")
                        Text(
                          _getWeekdayName(day.weekday),
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? colorScheme.onSurface
                                    : Colors
                                        .blueGrey, // Blue-grey for light mode
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Circular date container
                        GestureDetector(
                          onTap: () {
                            _showCompletedGoalsBottomSheet(
                              context,
                              completedDates[DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                  )] ??
                                  [],
                            );
                          },
                          child: Container(
                            width: 40, // Circular size
                            height: 40, // Circular size
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Ensures perfect circle
                              border: Border.all(
                                width: 2,
                                color:
                                    isToday
                                        ? (isStreakContinued
                                            ? Color(
                                              0xff1bfc9e,
                                            ) // Red for streak not completed
                                            : Color(
                                              0xffa70b0b,
                                            )) // Blue-green for for completed
                                        : colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                              ),
                              color:
                                  isStreakContinued
                                      ? (isDarkMode
                                          ? Color(
                                            0xffffc300,
                                          ) // Yellow for streak in dark mode
                                          : Color(
                                            0xff82b1ff,
                                          )) // Light blue for streak in light mode
                                      : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${day.day}", // Numeric day
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isStreakContinued
                                        ? (isDarkMode
                                            ? Colors.black
                                            : Colors.white)
                                        : colorScheme
                                            .onSurface, // Default text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return monthNames[month - 1]; // Subtract 1 because months are 1-based.
  }

  void _showCompletedGoalsBottomSheet(
    BuildContext context,
    List<Goal> completedGoals,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Completed Goals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (completedGoals.isEmpty)
                Expanded(
                  child: Text(
                    "No goals completed on this day.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else
                ...completedGoals.map(
                  (goal) => ListTile(
                    title: Text(goal.title, style: TextStyle(fontSize: 16)),
                    subtitle:
                        goal.description.isNotEmpty
                            ? Text(goal.description)
                            : null,
                    leading: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
