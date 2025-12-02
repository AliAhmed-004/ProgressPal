import 'package:flutter/material.dart';

/// A GitHub-style contribution heatmap widget that visualizes activity over time.
///
/// Displays a grid where:
/// - Rows represent days of the week (Mon-Sun)
/// - Columns represent weeks
/// - Cell color intensity indicates activity level (goals completed)
class ContributionHeatmap extends StatelessWidget {
  /// Map of dates to goal counts. Keys should be normalized to midnight.
  final Map<DateTime, int> data;

  /// Number of weeks to display (default: 13 weeks ≈ 3 months)
  final int weeks;

  /// Base color for the heatmap intensity scale
  final Color baseColor;

  /// Callback when a day cell is tapped
  final void Function(DateTime date, int count)? onDayTap;

  /// Size of each cell in the grid
  final double cellSize;

  /// Spacing between cells
  final double cellSpacing;

  const ContributionHeatmap({
    super.key,
    required this.data,
    this.weeks = 13,
    this.baseColor = const Color(0xFF4CAF50), // Material Green
    this.onDayTap,
    this.cellSize = 14,
    this.cellSpacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final emptyColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main heatmap grid with horizontal scrolling
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // Start from the right (most recent)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels row
              _buildMonthLabels(context),
              const SizedBox(height: 4),

              // Heatmap grid with day labels
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day of week labels (Mon, Wed, Fri)
                  _buildDayLabels(context),
                  const SizedBox(width: 4),

                  // The actual heatmap grid
                  _buildHeatmapGrid(context, emptyColor),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Legend showing color scale
        _buildLegend(context, emptyColor),
      ],
    );
  }

  /// Builds the month labels that appear above the heatmap grid.
  Widget _buildMonthLabels(BuildContext context) {
    final today = DateTime.now();
    final startDate = _getStartDate(today);
    final months = <_MonthLabel>[];

    // Calculate which months appear in the grid and their positions
    DateTime currentDate = startDate;
    int currentWeek = 0;
    int? lastMonth;

    while (currentWeek < weeks) {
      if (lastMonth != currentDate.month) {
        months.add(
          _MonthLabel(
            name: _getMonthName(currentDate.month),
            weekIndex: currentWeek,
          ),
        );
        lastMonth = currentDate.month;
      }
      // Move to next week
      currentDate = currentDate.add(const Duration(days: 7));
      currentWeek++;
    }

    // Build the month label row
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          // Spacer for day labels column
          SizedBox(width: 28),
          // Month labels positioned at their respective weeks
          ...List.generate(weeks, (weekIndex) {
            final monthLabel = months.firstWhere(
              (m) => m.weekIndex == weekIndex,
              orElse: () => _MonthLabel(name: '', weekIndex: -1),
            );
            return SizedBox(
              width: cellSize + cellSpacing,
              child:
                  monthLabel.name.isNotEmpty
                      ? Text(
                        monthLabel.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      )
                      : null,
            );
          }),
        ],
      ),
    );
  }

  /// Builds the day of week labels (Mon, Wed, Fri) on the left side.
  Widget _buildDayLabels(BuildContext context) {
    // Only show Mon, Wed, Fri to save space (like GitHub)
    final labels = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

    return Column(
      children: List.generate(7, (index) {
        return Container(
          height: cellSize + cellSpacing,
          width: 24,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            labels[index],
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        );
      }),
    );
  }

  /// Builds the main heatmap grid of cells.
  Widget _buildHeatmapGrid(BuildContext context, Color emptyColor) {
    final today = DateTime.now();
    final startDate = _getStartDate(today);

    return Row(
      children: List.generate(weeks, (weekIndex) {
        return Column(
          children: List.generate(7, (dayIndex) {
            // Calculate the date for this cell
            final cellDate = startDate.add(
              Duration(days: (weekIndex * 7) + dayIndex),
            );

            // Don't show future dates
            if (cellDate.isAfter(today)) {
              return _buildCell(
                context,
                color: Colors.transparent,
                date: cellDate,
                count: 0,
                isFuture: true,
              );
            }

            // Get the goal count for this date
            final normalizedDate = _normalizeDate(cellDate);
            final count = data[normalizedDate] ?? 0;

            // Calculate color intensity based on count
            final color = _getColorForCount(count, emptyColor);

            return _buildCell(
              context,
              color: color,
              date: cellDate,
              count: count,
              isFuture: false,
            );
          }),
        );
      }),
    );
  }

  /// Builds an individual cell in the heatmap grid.
  Widget _buildCell(
    BuildContext context, {
    required Color color,
    required DateTime date,
    required int count,
    required bool isFuture,
  }) {
    return GestureDetector(
      onTap: isFuture ? null : () => onDayTap?.call(date, count),
      child: Tooltip(
        message:
            isFuture
                ? ''
                : '$count goal${count == 1 ? '' : 's'} on ${_formatDate(date)}',
        child: Container(
          width: cellSize,
          height: cellSize,
          margin: EdgeInsets.all(cellSpacing / 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  /// Builds the legend showing the color scale.
  Widget _buildLegend(BuildContext context, Color emptyColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 4),
        // Empty cell
        _buildLegendCell(emptyColor),
        // Level 1 (1 goal)
        _buildLegendCell(baseColor.withOpacity(0.25)),
        // Level 2 (2-3 goals)
        _buildLegendCell(baseColor.withOpacity(0.5)),
        // Level 3 (4-5 goals)
        _buildLegendCell(baseColor.withOpacity(0.75)),
        // Level 4 (6+ goals)
        _buildLegendCell(baseColor),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  /// Builds a single cell for the legend.
  Widget _buildLegendCell(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Calculates the start date for the heatmap grid.
  /// Returns the Monday of the first week to display.
  DateTime _getStartDate(DateTime today) {
    // Go back [weeks] weeks from today
    final daysBack = (weeks * 7) - 1;
    final startDate = today.subtract(Duration(days: daysBack));

    // Adjust to the nearest Monday (start of week)
    // DateTime weekday: 1 = Monday, 7 = Sunday
    final daysToSubtract = startDate.weekday - 1;
    return startDate.subtract(Duration(days: daysToSubtract));
  }

  /// Normalizes a DateTime to midnight (removes time component).
  /// This ensures consistent date matching in the data map.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the appropriate color for the given goal count.
  Color _getColorForCount(int count, Color emptyColor) {
    if (count == 0) return emptyColor;
    if (count == 1) return baseColor.withOpacity(0.25);
    if (count <= 3) return baseColor.withOpacity(0.5);
    if (count <= 5) return baseColor.withOpacity(0.75);
    return baseColor; // 6+ goals
  }

  /// Returns the abbreviated month name.
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Formats a date for display in tooltips.
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Helper class to store month label positions.
class _MonthLabel {
  final String name;
  final int weekIndex;

  _MonthLabel({required this.name, required this.weekIndex});
}
