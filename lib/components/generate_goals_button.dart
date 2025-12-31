import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../gemini/gemini_helper.dart';
import '../providers/track_provider.dart';
import 'generated_goals_dialog.dart';

class AISectionCollapsed extends StatefulWidget {
  const AISectionCollapsed({super.key});

  @override
  State<AISectionCollapsed> createState() => _AISectionCollapsedState();
}

class _AISectionCollapsedState extends State<AISectionCollapsed> {
  bool _isGenerating = false;

  bool get canUseAI {
    final box = Hive.box('settings');
    final lastUsedMillis = box.get('last_free_ai_use') as int?;
    final today = DateTime.now().toLocal();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return lastUsedMillis == null ||
        DateTime.fromMillisecondsSinceEpoch(lastUsedMillis) != todayOnly;
  }

  void _setLastUsedNow() {
    final box = Hive.box('settings');
    final now = DateTime.now().toLocal();
    final todayOnly = DateTime(now.year, now.month, now.day);
    box.put('last_free_ai_use', todayOnly.millisecondsSinceEpoch);
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _generateGoals(BuildContext context) async {
    if (!mounted) return;

    setState(() => _isGenerating = true);
    final goalGenerator = GeminiGoalGenerator();
    final currentTrack =
        Provider.of<TrackProvider>(context, listen: false).selectedTrack;
    final existingGoals = currentTrack.goals.map((goal) => goal.title).toList();

    // Show loading dialog
    if (mounted) {
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
    }

    try {
      final goals = await goalGenerator.generateGoals(
        currentTrack.title,
        existingGoals,
      );

      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Show the generated goals dialog
      await showDialog(
        context: context,
        builder: (_) => GeneratedGoalsDialog(goals: goals),
      );

      // Only count the daily use *after* successful generation and showing
      _setLastUsedNow();
    } on SocketException catch (_) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showFallbackDialog("No internet connection.");
      }
    } on GeminiApiException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showFallbackDialog(e.userMessage);
      }
    } on GenerativeAIException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        if (e.message.contains('503')) {
          _showFallbackDialog("The AI is overloaded. Please try again later.");
        } else {
          _showFallbackDialog("AI generation failed. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showFallbackDialog("Something went wrong. Please try again.");
      }
    }

    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  void _showFallbackDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowed = canUseAI;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: const [
          Icon(Icons.auto_awesome, size: 20),
          SizedBox(width: 8),
          Text("Use AI to generate goals", style: TextStyle(fontSize: 14)),
        ],
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        Text(
          allowed
              ? "You have 1 free AI generation today."
              : "You've used your free generation. Come back tomorrow!",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.flash_on),
          label: Text(_isGenerating ? "Generating..." : "Generate Goals"),
          onPressed:
              allowed && !_isGenerating ? () => _generateGoals(context) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
