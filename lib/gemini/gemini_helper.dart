import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:progresspal/secrets/secrets.dart';

class GeminiGoalGenerator {
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: gemini_api);

  Future<List<String>> generateGoals(
    String trackTitle, [
    List<String>? existingGoals,
  ]) async {
    final prompt = _buildPrompt(trackTitle, existingGoals);

    final content = [Content.text(prompt)];

    final response = await model.generateContent(content);

    final text = response.text ?? "";

    return _parseGoals(text);
  }

String _buildPrompt(String trackTitle, List<String>? existingGoals) {
  // Base instructions
  String base =
      "You're helping to create a chronological list of learning goals for a track titled '$trackTitle'. "
      "Each goal should be short, clear, and practical — written as a concise heading, without descriptions. "
      "Only provide 5 new goals as a bullet list, no introduction or explanation.";

  // If there are existing goals, treat them as completed
  if (existingGoals != null && existingGoals.isNotEmpty) {
    base +=
        "\nThe following goals have already been completed in this track:\n"
        "${existingGoals.map((g) => '- $g').join('\n')}"
        "\nNow, please generate the *next 5 goals* that logically follow in the learning path. "
        "Make sure they are different from the completed ones and continue the learning progression naturally.";
  } else {
    base +=
        "\nThis is a new track, so please generate the first 5 beginner-friendly goals to get started.";
  }

  return base;
}

  List<String> _parseGoals(String rawText) {
    final lines =
        rawText
            .split('\n')
            .map((line) => line.replaceAll(RegExp(r'^[-*\d.\s]+'), '').trim())
            .where((line) => line.isNotEmpty)
            .toList();

    return lines;
  }
}
