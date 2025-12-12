import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:progresspal/secrets/secrets.dart';

class GeminiGoalGenerator {
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: GEMINI_API_KEY);

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
        "You're helping a user create a list of 5 **small, actionable** goals for a track titled '$trackTitle'.\n"
        "Each goal should represent the **smallest possible task** a user can complete in one sitting — something that would take a couple hours at most.\n"
        "Avoid broad or multi-step goals. Break down bigger ideas into their simplest parts.\n"
        "Each goal must be short, specific, and written as a heading — no descriptions.\n"
        "Respond with only a bullet list of 5 goals. No extra text.";

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
