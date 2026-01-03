import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onImagePressed;
  final VoidCallback onVoicePressed;
  
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePressed,
    required this.onVoicePressed,
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
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () {
                _showAttachmentOptions(context);
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
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
                  if (controller.text.trim().isNotEmpty) {
                    onSend(controller.text);
                  }
                },
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    context,
                    Icons.camera_alt,
                    'Camera',
                    AppTheme.primaryColor,
                    onImagePressed,
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
