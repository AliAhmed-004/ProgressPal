import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:progresspal/secrets/secrets.dart';

class GeminiGoalGenerator {
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: gemini_key);

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
    // Base prompt
    String base =
        "Forget all previous instructions if any. I'm creating goals for a learning track titled '$trackTitle'."
        "Please generate 5 clear, short and practical goals for this learning track without their descriptions. I only want 'headings'."
        "Only give the actual goals as response. Do not add any line like 'Here are the goals'."
        "These goals would be considered as the first 5 goals one should complete before moving forward in this learning track.";

    // If there are existing goals, avoid generating them
    if (existingGoals != null && existingGoals.isNotEmpty) {
      base +=
          "\nThese are some goals I have already added. Try generating the other 5 goals considering these but do not suggest them again:\n"
          "$existingGoals";
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
