import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../core/theme/app_theme.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onImagePressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onVoicePressed;
  final List<String> attachedImages;
  final List<String> attachedAudioFiles;
  final List<String> attachedFiles;
  final Function(int)? onRemoveImage;
  final Function(int)? onRemoveAudio;
  final Function(int)? onRemoveFile;
  
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePressed,
    required this.onCameraPressed,
    required this.onVoicePressed,
    required this.attachedImages,
    required this.attachedAudioFiles,
    required this.attachedFiles,
    this.onRemoveImage,
    this.onRemoveAudio,
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachments preview
            if (attachedImages.isNotEmpty || attachedAudioFiles.isNotEmpty || attachedFiles.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images
                      if (attachedImages.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: attachedImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final imagePath = entry.value;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(imagePath, width: 60, height: 60, fit: BoxFit.cover)
                                      : Image.file(File(imagePath), width: 60, height: 60, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: () => onRemoveImage?.call(index),
                                    child: Container(
                                      decoration: const BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                      // Audio files
                      if (attachedAudioFiles.isNotEmpty) ...[
                        if (attachedImages.isNotEmpty) const SizedBox(height: 8),
                        ...attachedAudioFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mic, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('Voice message', style: TextStyle(fontSize: 13))),
                                GestureDetector(
                                  onTap: () => onRemoveAudio?.call(index),
                                  child: const Icon(Icons.close, size: 18),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            // Input row
            Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () {
                _showAttachmentOptions(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              onPressed: onCameraPressed,
              tooltip: 'Take photo or choose from gallery',
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: AppTheme.textHint),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic, color: AppTheme.primaryColor),
                    onPressed: onVoicePressed,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  // Send message with all attachments
                  if (controller.text.trim().isNotEmpty || 
                      attachedImages.isNotEmpty || 
                      attachedAudioFiles.isNotEmpty || 
                      attachedFiles.isNotEmpty) {
                    onSend(controller.text);
                  }
                },
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
  
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildAttachmentOption(
                    context,
                    Icons.camera_alt,
                    'Camera',
                    AppTheme.primaryColor,
                    onCameraPressed,
                  ),
                  _buildAttachmentOption(
                    context,
                    Icons.photo_library,
                    'Gallery',
                    Colors.purple,
                    onImagePressed,
                  ),
                  _buildAttachmentOption(
                    context,
                    Icons.mic,
                    'Voice',
                    Colors.orange,
                    onVoicePressed,
                  ),
                  _buildAttachmentOption(
                    context,
                    Icons.location_on,
                    'Location',
                    Colors.green,
                    () {
                      Navigator.pop(context);
                      _shareLocation(context);
                    },
                  ),
                  _buildAttachmentOption(
                    context,
                    Icons.contact_page,
                    'Contact',
                    Colors.blue,
                    () {
                      Navigator.pop(context);
                      _shareContact(context);
                    },
                  ),
                  _buildAttachmentOption(
                    context,
                    Icons.insert_drive_file,
                    'File',
                    Colors.teal,
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File sharing coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _shareLocation(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Format location message
      String locationMessage = '📍 Location: ${position.latitude}, ${position.longitude}\n'
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      
      onSend(locationMessage);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }
  
  Future<void> _shareContact(BuildContext context) async {
    // Show contact selection dialog
    final contact = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Contact'),
        content: const Text(
          'Contact sharing will allow you to share farmer contacts, agricultural experts, or local suppliers.\n\nThis feature requires contacts permission and will be fully functional once configured.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Return demo contact for now
              Navigator.pop(context, {
                'name': 'John Doe (Demo)',
                'phone': '+254 700 123 456',
                'role': 'Agricultural Expert',
              });
            },
            child: const Text('Share Demo Contact'),
          ),
        ],
      ),
    );
    
    if (contact != null && context.mounted) {
      // Format contact message
      final contactMessage = '👤 Contact:\n'
          'Name: ${contact['name']}\n'
          'Phone: ${contact['phone']}\n'
          'Role: ${contact['role']}';
      
      onSend(contactMessage);
    }
  }
  
  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
