import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message_model.dart';
import 'logger_service.dart';

class AIService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  // OpenRouter API key loaded from .env file
  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

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
    List<XFile>? imageFiles,
    String? location,
  }) async {
    try {
      logger.debug(
        'Generating AI response',
        tag: 'AIService',
      );
      logger.debug(
        'User message: $userMessage, Images: ${imagePaths?.length ?? imageFiles?.length ?? 0}',
        tag: 'AIService',
      );
      
      final messages = await _buildMessages(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        imagePaths: imagePaths,
        imageFiles: imageFiles,
        location: location,
      );

      logger.debug(
        'Prepared ${messages.length} messages for API',
        tag: 'AIService',
      );
      if (messages.last['content'] is List) {
        logger.debug(
          'Multimodal message with ${(messages.last['content'] as List).length} content items',
          tag: 'AIService',
        );
      }

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
      logger.apiError(
        '/chat/completions',
        e,
        stackTrace: e.stackTrace,
      );
      if (e.response?.data != null) {
        logger.debug('Error response data: ${e.response?.data}', tag: 'AIService');
      }
      return _getErrorResponse(e);
    } catch (e, stackTrace) {
      logger.error(
        'Unexpected error in generateResponse',
        tag: 'AIService',
        error: e,
        stackTrace: stackTrace,
      );
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  /// Build messages array for the API with system prompt and conversation history
  Future<List<Map<String, dynamic>>> _buildMessages({
    required String userMessage,
    required List<Message> conversationHistory,
    List<String>? imagePaths,
    List<XFile>? imageFiles,
    String? location,
  }) async {
    final messages = <Map<String, dynamic>>[];

    // System prompt with farming expertise instructions
    messages.add({
      'role': 'system',
      'content': _getSystemPrompt(location),
    });

    // Add conversation history (last 10 messages for context)
    // Exclude the last message if it's a user message since we'll add it with images
    final recentHistory = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    // Only add history up to the second-to-last message to avoid duplicating
    // the current user message
    final historyToAdd = recentHistory.isNotEmpty && recentHistory.last.isUser
        ? recentHistory.sublist(0, recentHistory.length - 1)
        : recentHistory;

    for (final msg in historyToAdd) {
      if (msg.text.isNotEmpty && !msg.text.contains('Typing...')) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        });
      }
    }

    // Add current user message with images if provided
    if ((imagePaths != null && imagePaths.isNotEmpty) || (imageFiles != null && imageFiles.isNotEmpty)) {
      logger.debug(
        'Building multimodal message with ${imagePaths?.length ?? imageFiles?.length ?? 0} images',
        tag: 'AIService',
      );
      messages.add(await _buildMultimodalMessage(userMessage, imagePaths, imageFiles));
    } else {
      messages.add({
        'role': 'user',
        'content': userMessage,
      });
    }

    return messages;
  }

  /// Build multimodal message with text and images
  Future<Map<String, dynamic>> _buildMultimodalMessage(
    String text,
    List<String>? imagePaths,
    List<XFile>? imageFiles,
  ) async {
    final content = <Map<String, dynamic>>[];

    // Add text content first
    if (text.isNotEmpty) {
      content.add({
        'type': 'text',
        'text': text,
      });
    }

    // Handle web images using XFile
    if (kIsWeb && imageFiles != null) {
      for (final imageFile in imageFiles) {
        try {
          logger.debug('Processing web image: ${imageFile.name}', tag: 'AIService');
          
          final bytes = await imageFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          final mimeType = _getImageMimeType(imageFile.name);
          
          content.add({
            'type': 'image_url',
            'image_url': {
              'url': 'data:$mimeType;base64,$base64Image',
            },
          });
          
          logger.debug(
            'Web image encoded: ${imageFile.name} (${bytes.length} bytes)',
            tag: 'AIService',
          );
        } catch (e, stackTrace) {
          logger.error(
            'Failed to encode web image: ${imageFile.name}',
            tag: 'AIService',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    }
    // Handle mobile/desktop images using file paths
    else if (imagePaths != null) {
      for (final imagePath in imagePaths) {
        try {
          logger.debug('Processing image: ${imagePath.split('/').last}', tag: 'AIService');
          
          final imageData = _encodeImageToBase64(imagePath);
          if (imageData != null) {
            // Detect image MIME type from file extension
            final mimeType = _getImageMimeType(imagePath);
            
            content.add({
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$imageData',
              },
            });
            
            logger.debug(
              'Image encoded: ${imagePath.split('/').last}',
              tag: 'AIService',
            );
          } else {
            logger.warning(
              'Failed to encode image (data is null): ${imagePath.split('/').last}',
              tag: 'AIService',
            );
          }
        } catch (e, stackTrace) {
          logger.error(
            'Error encoding image: ${imagePath.split('/').last}',
            tag: 'AIService',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    }

    logger.debug(
      'Multimodal message built with ${content.length} content items',
      tag: 'AIService',
    );

    return {
      'role': 'user',
      'content': content,
    };
  }

  /// Get MIME type based on file extension
  String _getImageMimeType(String imagePath) {
    final extension = imagePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Encode image to base64 for API transmission
  String? _encodeImageToBase64(String imagePath) {
    try {
      if (kIsWeb) {
        // For web, the image picker returns the bytes directly as base64
        // We need to handle blob URLs differently
        logger.debug('Web platform: blob URL handling', tag: 'AIService');
        // On web, we can't read blob URLs directly in Dart
        // The image should be converted before this point
        // For now, return null and handle in the calling code
        return null;
      } else {
        final file = File(imagePath);
        if (!file.existsSync()) {
          logger.warning(
            'Image file does not exist: ${imagePath.split('/').last}',
            tag: 'AIService',
          );
          return null;
        }
        
        final bytes = file.readAsBytesSync();
        logger.debug(
          'Read image file: ${bytes.length} bytes',
          tag: 'AIService',
        );
        return base64Encode(bytes);
      }
    } catch (e, stackTrace) {
      logger.error(
        'Error reading image file',
        tag: 'AIService',
        error: e,
        stackTrace: stackTrace,
      );
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
