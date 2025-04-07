// import 'package:flutter/material.dart';
import 'package:progresspal/gemini/gemini_helper.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  final generator = GeminiGoalGenerator();

  final goals = await generator.generateGoals("poop", [
    'go to bathroom',
    'sit down',
  ]);

  print("Generated goals:");
  for (var goal in goals) {
    print("- $goal");
  }
}
