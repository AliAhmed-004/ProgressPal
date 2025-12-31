import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/streak_provider.dart';

/// A widget that wraps the streak display and shows confetti falling from it
/// across the entire screen using an Overlay.
/// Automatically listens to StreakProvider for streak changes.
class StreakCelebrationWidget extends StatefulWidget {
  final Widget child;

  const StreakCelebrationWidget({super.key, required this.child});

  @override
  State<StreakCelebrationWidget> createState() =>
      _StreakCelebrationWidgetState();
}

class _StreakCelebrationWidgetState extends State<StreakCelebrationWidget> {
  final GlobalKey _streakKey = GlobalKey();
  int? _previousStreak;
  OverlayEntry? _overlayEntry;
  bool _isShowingConfetti = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize previous streak on first call
    _previousStreak ??= context.read<StreakProvider>().streak.currentStreak;
  }

  void _onStreakChanged(int currentStreak) {
    // Check if streak has incremented
    if (_previousStreak != null &&
        currentStreak > _previousStreak! &&
        currentStreak > 0) {
      // Defer celebration to after build phase completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _celebrate();
      });
    }
    _previousStreak = currentStreak;
  }

  void _celebrate() {
    // Prevent multiple overlays
    if (_isShowingConfetti) return;

    _showConfettiOverlay();
  }

  void _showConfettiOverlay() {
    // Get the position of the streak widget
    final RenderBox? renderBox =
        _streakKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Calculate center position of the streak widget
    final centerX = position.dx + size.width / 2;

    _isShowingConfetti = true;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _ConfettiOverlay(
            startX: centerX,
            startY: position.dy + size.height,
            onComplete: _removeOverlay,
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry!.dispose();
      _overlayEntry = null;
    }
    _isShowingConfetti = false;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<StreakProvider, int>(
      selector: (_, provider) => provider.streak.currentStreak,
      builder: (context, currentStreak, child) {
        // Trigger celebration check when streak changes
        _onStreakChanged(currentStreak);
        return child!;
      },
      child: KeyedSubtree(key: _streakKey, child: widget.child),
    );
  }
}

/// Overlay widget that shows confetti falling from a specific position
class _ConfettiOverlay extends StatefulWidget {
  final double startX;
  final double startY;
  final VoidCallback onComplete;

  const _ConfettiOverlay({
    required this.startX,
    required this.startY,
    required this.onComplete,
  });

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );

    // Start confetti immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });

    // Remove overlay after animation completes
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Custom path for smaller confetti particles
  Path _drawSmallStar(Size size) {
    final path = Path();
    final numPoints = 5;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / numPoints) - (pi / 2);
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                left: widget.startX - 10,
                top: widget.startY,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // Downward (90 degrees)
                  blastDirectionality: BlastDirectionality.directional,
                  shouldLoop: false,
                  emissionFrequency: 0.4,
                  numberOfParticles: 12,
                  maxBlastForce: 25,
                  minBlastForce: 10,
                  gravity: 0.2,
                  particleDrag: 0.02,
                  minimumSize: const Size(3, 3),
                  maximumSize: const Size(8, 8),
                  createParticlePath: _drawSmallStar,
                  colors: const [
                    Colors.orange,
                    Colors.red,
                    Colors.yellow,
                    Colors.amber,
                    Colors.deepOrange,
                    Color(0xFFFFD700), // Gold
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
