import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../data/models/message_model.dart';
import '../../core/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isTyping;
  
  const ChatBubble({
    super.key,
    required this.message,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/app_logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? AppTheme.sentMessageBg 
                        : AppTheme.receivedMessageBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUser 
                          ? const Radius.circular(18) 
                          : const Radius.circular(4),
                      bottomRight: message.isUser 
                          ? const Radius.circular(4) 
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display all attached images
                      if (message.attachedImages.isNotEmpty)
                        _buildAttachedImages(),
                      // Display all attached audio files
                      if (message.attachedAudioFiles.isNotEmpty)
                        _buildAttachedAudio(),
                      // Display text if present
                      if (!isTyping && message.text.isNotEmpty) ...[
                        if (message.attachedImages.isNotEmpty || message.attachedAudioFiles.isNotEmpty)
                          const SizedBox(height: 8),
                        Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (isTyping)
                        _buildTypingIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAttachedImages() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.attachedImages.map((imagePath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: kIsWeb
                ? Image.network(imagePath, fit: BoxFit.cover)
                : Image.file(File(imagePath), fit: BoxFit.cover),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildAttachedAudio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: message.attachedAudioFiles.map((audioPath) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text('Voice message', style: TextStyle(fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }
  
  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.textHint,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
