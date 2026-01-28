import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';

class AIService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  
  // OpenRouter API key - Replace with your actual key
  static const String _apiKey = 'YOUR_OPENROUTER_API_KEY';
  
  // Model optimized for vision and farming expertise
  static const String _model = 'anthropic/claude-3.5-sonnet';
  
  AIService() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://crop-diagnostic.app',
        'X-Title': 'Crop Diagnostic Assistant',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    );
  }

  /// Generate AI response with conversation history and multimodal support
  Future<String> generateResponse({
    required String userMessage,
    required List<Message> conversationHistory,
    List<String>? imagePaths,
    String? location,
  }) async {
    try {
      final messages = _buildMessages(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        imagePaths: imagePaths,
        location: location,
      );

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.message}');
        print('Response: ${e.response?.data}');
      }
      return _getErrorResponse(e);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  /// Build messages array for the API with system prompt and conversation history
  List<Map<String, dynamic>> _buildMessages({
    required String userMessage,
    required List<Message> conversationHistory,
    List<String>? imagePaths,
    String? location,
  }) {
    final messages = <Map<String, dynamic>>[];

    // System prompt with farming expertise instructions
    messages.add({
      'role': 'system',
      'content': _getSystemPrompt(location),
    });

    // Add conversation history (last 10 messages for context)
    final recentHistory = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    for (final msg in recentHistory) {
      if (msg.text.isNotEmpty && !msg.text.contains('Typing...')) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }

    // Add current user message with images if provided
    if (imagePaths != null && imagePaths.isNotEmpty) {
      messages.add(_buildMultimodalMessage(userMessage, imagePaths));
    } else {
      messages.add({
        'role': 'user',
        'content': userMessage,
      });
    }

    return messages;
  }

  /// Build multimodal message with text and images
  Map<String, dynamic> _buildMultimodalMessage(
    String text,
    List<String> imagePaths,
  ) {
    final content = <Map<String, dynamic>>[];

    // Add text content
    if (text.isNotEmpty) {
      content.add({
        'type': 'text',
        'text': text,
      });
    }

    // Add image contents
    for (final imagePath in imagePaths) {
      try {
        final imageData = _encodeImageToBase64(imagePath);
        if (imageData != null) {
          content.add({
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$imageData',
            },
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error encoding image: $e');
        }
      }
    }

    return {
      'role': 'user',
      'content': content,
    };
  }

  /// Encode image to base64 for API transmission
  String? _encodeImageToBase64(String imagePath) {
    try {
      if (kIsWeb) {
        // For web, the path is already a network URL
        return null; // We'll need to handle web images differently
      } else {
        final bytes = File(imagePath).readAsBytesSync();
        return base64Encode(bytes);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading image file: $e');
      }
      return null;
    }
  }

  /// Get comprehensive system prompt for farming assistant
  String _getSystemPrompt(String? location) {
    final locationContext = location != null
        ? '\n\nUser Location: $location\nConsider regional climate, common pests, and soil conditions for this area in your recommendations.'
        : '';

    return '''You are an expert agricultural advisor and crop diagnostic assistant specializing in helping farmers identify and solve pest, disease, and crop health issues. Your goal is to provide accurate, practical, and verified solutions.

CORE PRINCIPLES:
1. **Organic First**: Always prioritize organic and natural solutions as the primary recommendation
2. **Chemical as Alternative**: Provide chemical solutions only as secondary alternatives when necessary
3. **Evidence-Based**: All recommendations must be based on verified agricultural research and trusted sources
4. **Safety First**: Always include safety precautions for any chemical treatments
5. **Preventive Care**: Include preventive measures to avoid future occurrences

ANALYSIS APPROACH:
- When images are provided, carefully analyze visual symptoms (discoloration, spots, wilting, pest presence, etc.)
- Identify the specific crop or animal from the image if possible
- Diagnose the issue by correlating visual evidence with described symptoms
- Consider environmental factors (weather, season, location) that might contribute to the problem

RESPONSE STRUCTURE:
1. **Problem Identification**: Clearly state what you've identified (disease name, pest species, deficiency, etc.)
2. **Severity Assessment**: Indicate if it's mild, moderate, or severe
3. **Organic Solutions** (PRIMARY):
   - Natural remedies (neem oil, garlic spray, beneficial insects, etc.)
   - Cultural practices (crop rotation, proper spacing, mulching, etc.)
   - Biological controls
   - Organic certified products
4. **Chemical Solutions** (ALTERNATIVE):
   - Only when organic methods may be insufficient
   - Specific product recommendations with active ingredients
   - Safety precautions and protective equipment needed
   - Application timing and frequency
5. **Preventive Measures**: Steps to prevent recurrence
6. **Additional Tips**: Monitoring, when to seek professional help, etc.

CONSTRAINTS:
- Be concise but thorough
- Use simple language accessible to farmers
- Provide specific actionable steps
- Include timing for treatments (morning/evening, before/after rain, etc.)
- Mention expected results and timeframes
- If unsure, recommend consulting a local agricultural extension officer$locationContext

Remember: Your advice directly impacts farmers' livelihoods and food safety. Accuracy and practicality are paramount.''';
  }

  /// Generate user-friendly error messages
  String _getErrorResponse(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'The request timed out. Please check your internet connection and try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the AI service. Please check your internet connection.';
    } else if (e.response?.statusCode == 401) {
      return 'Authentication error. Please contact support.';
    } else if (e.response?.statusCode == 429) {
      return 'Too many requests. Please wait a moment and try again.';
    } else if (e.response?.statusCode == 500) {
      return 'The AI service is currently experiencing issues. Please try again later.';
    }
    return 'Sorry, I encountered an error. Please try again.';
  }
}
