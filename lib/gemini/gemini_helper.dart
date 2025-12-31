import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:progresspal/secrets/secrets.dart';

/// Exception thrown when Gemini API encounters an error
class GeminiApiException implements Exception {
  final String message;
  final String userMessage;
  final GeminiErrorType type;

  GeminiApiException({
    required this.message,
    required this.userMessage,
    required this.type,
  });

  @override
  String toString() => 'GeminiApiException: $message';
}

enum GeminiErrorType {
  invalidApiKey,
  expiredApiKey,
  quotaExceeded,
  serverOverloaded,
  networkError,
  unknown,
}

class GeminiGoalGenerator {
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: GEMINI_API_KEY,
  );

  // Cached validation state
  static bool? _isApiKeyValid;
  static String? _cachedErrorMessage;

  /// Returns true if API key is valid, false otherwise
  static bool get isApiKeyValid => _isApiKeyValid ?? true;

  /// Returns cached error message if API key validation failed
  static String? get cachedErrorMessage => _cachedErrorMessage;

  /// Validates the API key by making a lightweight request.
  /// Call this at app startup to cache the result.
  static Future<bool> validateApiKey() async {
    // If already validated, return cached result
    if (_isApiKeyValid != null) {
      return _isApiKeyValid!;
    }

    try {
      final testModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: GEMINI_API_KEY,
      );
      // Make a minimal request to validate the key
      await testModel.generateContent([Content.text('Hi')]);
      _isApiKeyValid = true;
      _cachedErrorMessage = null;
      return true;
    } on GenerativeAIException catch (e) {
      _isApiKeyValid = false;
      _cachedErrorMessage = _parseApiError(e).userMessage;
      return false;
    } catch (e) {
      // For network errors during validation, assume key might be valid
      // and let actual usage determine the result
      _isApiKeyValid = true;
      _cachedErrorMessage = null;
      return true;
    }
  }

  /// Resets the cached validation state (useful for retrying)
  static void resetValidation() {
    _isApiKeyValid = null;
    _cachedErrorMessage = null;
  }

  Future<List<String>> generateGoals(
    String trackTitle, [
    List<String>? existingGoals,
  ]) async {
    // Check cached validation first
    if (_isApiKeyValid == false) {
      throw GeminiApiException(
        message: _cachedErrorMessage ?? 'API key is invalid',
        userMessage:
            _cachedErrorMessage ??
            'The AI service is currently unavailable. Please try again later.',
        type: GeminiErrorType.invalidApiKey,
      );
    }

    final prompt = _buildPrompt(trackTitle, existingGoals);
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);
      final text = response.text ?? "";
      return _parseGoals(text);
    } on GenerativeAIException catch (e) {
      final exception = _parseApiError(e);
      // Update cached state if it's an API key issue
      if (exception.type == GeminiErrorType.invalidApiKey ||
          exception.type == GeminiErrorType.expiredApiKey ||
          exception.type == GeminiErrorType.quotaExceeded) {
        _isApiKeyValid = false;
        _cachedErrorMessage = exception.userMessage;
      }
      throw exception;
    }
  }

  static GeminiApiException _parseApiError(GenerativeAIException e) {
    final message = e.message.toLowerCase();

    if (message.contains('api key not valid') ||
        message.contains('invalid api key') ||
        message.contains('api_key_invalid')) {
      return GeminiApiException(
        message: e.message,
        userMessage:
            'The AI service is temporarily unavailable. Please try again later or contact support.',
        type: GeminiErrorType.invalidApiKey,
      );
    }

    if (message.contains('expired') || message.contains('api key expired')) {
      return GeminiApiException(
        message: e.message,
        userMessage:
            'The AI service is temporarily unavailable. Please try again later or contact support.',
        type: GeminiErrorType.expiredApiKey,
      );
    }

    if (message.contains('quota') ||
        message.contains('rate limit') ||
        message.contains('resource exhausted') ||
        message.contains('429')) {
      return GeminiApiException(
        message: e.message,
        userMessage:
            'AI usage limit reached. Please try again in a few minutes.',
        type: GeminiErrorType.quotaExceeded,
      );
    }

    if (message.contains('503') || message.contains('overloaded')) {
      return GeminiApiException(
        message: e.message,
        userMessage: 'The AI is overloaded. Please try again later.',
        type: GeminiErrorType.serverOverloaded,
      );
    }

    return GeminiApiException(
      message: e.message,
      userMessage: 'AI generation failed. Please try again.',
      type: GeminiErrorType.unknown,
    );
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
