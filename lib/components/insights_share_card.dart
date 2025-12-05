import 'package:flutter/material.dart';

/// Theme options for the shareable insights card
enum ShareCardTheme { light, dark }

/// A beautifully designed card that displays user insights for sharing.
/// Sized for social media (1080 x 1350 - Instagram portrait).
class InsightsShareCard extends StatelessWidget {
  final int totalGoalsCompleted;
  final int currentStreak;
  final int longestStreak;
  final int goalsThisWeek;
  final List<TrackSummary> topTracks;
  final DateTime? generatedAt;
  final ShareCardTheme theme;

  const InsightsShareCard({
    super.key,
    required this.totalGoalsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.goalsThisWeek,
    required this.topTracks,
    this.generatedAt,
    this.theme = ShareCardTheme.dark,
  });

  // Color scheme based on theme
  _ShareCardColors get _colors => theme == ShareCardTheme.dark
      ? _ShareCardColors.dark()
      : _ShareCardColors.light();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1350,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colors.gradientColors,
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundDecoration(),
          Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 56),
                _buildStatsRow(),
                const SizedBox(height: 56),
                _buildTracksSection(),
                const SizedBox(height: 40),
                _buildWeeklyHighlight(),
                const Spacer(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CirclePatternPainter(color: _colors.decorationColor),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _colors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: theme == ShareCardTheme.light
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.insights_rounded,
                color: theme == ShareCardTheme.dark
                    ? Colors.white
                    : _colors.accentPurple,
                size: 48,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'ProgressPal',
              style: TextStyle(
                color: _colors.primaryText,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'My Learning Journey',
          style: TextStyle(
            color: _colors.secondaryText,
            fontSize: 32,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            value: totalGoalsCompleted.toString(),
            label: 'Goals\nCompleted',
            iconColor: _colors.accentGreen,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            value: currentStreak.toString(),
            label: 'Day\nStreak',
            iconColor: _colors.accentOrange,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events_rounded,
            value: longestStreak.toString(),
            label: 'Best\nStreak',
            iconColor: _colors.accentYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: _colors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _colors.cardBorder,
          width: 1.5,
        ),
        boxShadow: theme == ShareCardTheme.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              color: _colors.primaryText,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _colors.secondaryText,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksSection() {
    if (topTracks.isEmpty) {
      return _buildEmptyTracksPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              color: _colors.secondaryText,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Top Learning Tracks',
              style: TextStyle(
                color: _colors.secondaryText,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...topTracks.take(3).map((track) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTrackItem(track),
            )),
      ],
    );
  }

  Widget _buildEmptyTracksPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: _colors.tertiaryText,
            size: 40,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start your journey!',
                  style: TextStyle(
                    color: _colors.secondaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create tracks and complete goals to see them here',
                  style: TextStyle(
                    color: _colors.tertiaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(TrackSummary track) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.cardBorder),
        boxShadow: theme == ShareCardTheme.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  track.color,
                  track.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                track.name.isNotEmpty ? track.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: TextStyle(
                    color: _colors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${track.completedGoals} goal${track.completedGoals == 1 ? '' : 's'} completed',
                  style: TextStyle(
                    color: _colors.tertiaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _colors.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${track.completedGoals}',
              style: TextStyle(
                color: _colors.accentGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHighlight() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _colors.accentPurple.withOpacity(0.15),
            _colors.accentGreen.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _colors.accentPurple.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colors.accentPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: _colors.accentPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week',
                  style: TextStyle(
                    color: _colors.tertiaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWeeklyMessage(),
                  style: TextStyle(
                    color: _colors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$goalsThisWeek',
            style: TextStyle(
              color: _colors.accentPurple,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeeklyMessage() {
    if (goalsThisWeek == 0) {
      return 'Ready to start fresh!';
    } else if (goalsThisWeek == 1) {
      return 'goal completed';
    } else if (goalsThisWeek < 5) {
      return 'goals completed';
    } else if (goalsThisWeek < 10) {
      return 'goals - Great momentum!';
    } else {
      return 'goals - On fire! 🔥';
    }
  }

  Widget _buildFooter() {
    final date = generatedAt ?? DateTime.now();
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: _colors.tertiaryText,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: TextStyle(
                  color: _colors.tertiaryText,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: _colors.tertiaryText,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Made with ProgressPal',
                style: TextStyle(
                  color: _colors.tertiaryText,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Color scheme helper class for theming
class _ShareCardColors {
  final List<Color> gradientColors;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color cardBackground;
  final Color cardBorder;
  final Color decorationColor;
  final Color accentGreen;
  final Color accentOrange;
  final Color accentYellow;
  final Color accentPurple;

  _ShareCardColors({
    required this.gradientColors,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.cardBackground,
    required this.cardBorder,
    required this.decorationColor,
    required this.accentGreen,
    required this.accentOrange,
    required this.accentYellow,
    required this.accentPurple,
  });

  factory _ShareCardColors.dark() {
    return _ShareCardColors(
      gradientColors: const [
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
        Color(0xFF0F3460),
      ],
      primaryText: Colors.white,
      secondaryText: Colors.white.withOpacity(0.85),
      tertiaryText: Colors.white.withOpacity(0.55),
      cardBackground: Colors.white.withOpacity(0.08),
      cardBorder: Colors.white.withOpacity(0.12),
      decorationColor: Colors.white.withOpacity(0.03),
      accentGreen: const Color(0xFF4ADE80),
      accentOrange: const Color(0xFFFB923C),
      accentYellow: const Color(0xFFFACC15),
      accentPurple: const Color(0xFFA78BFA),
    );
  }

  factory _ShareCardColors.light() {
    return _ShareCardColors(
      gradientColors: const [
        Color(0xFFF8FAFC),
        Color(0xFFEEF2FF),
        Color(0xFFFDF4FF),
      ],
      primaryText: const Color(0xFF1E293B),
      secondaryText: const Color(0xFF475569),
      tertiaryText: const Color(0xFF94A3B8),
      cardBackground: Colors.white,
      cardBorder: const Color(0xFFE2E8F0),
      decorationColor: const Color(0xFF8B5CF6).withOpacity(0.06),
      accentGreen: const Color(0xFF22C55E),
      accentOrange: const Color(0xFFF97316),
      accentYellow: const Color(0xFFEAB308),
      accentPurple: const Color(0xFF8B5CF6),
    );
  }
}

/// Background pattern painter for decorative circles
class _CirclePatternPainter extends CustomPainter {
  final Color color;

  _CirclePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles at various positions
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      180,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.45),
      120,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.88),
      220,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.75),
      80,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePatternPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Data model for track summary in the share card
class TrackSummary {
  final String name;
  final int completedGoals;
  final Color color;

  const TrackSummary({
    required this.name,
    required this.completedGoals,
    required this.color,
  });
}
