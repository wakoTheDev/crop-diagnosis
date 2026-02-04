import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import '../../core/theme/app_theme.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../market/market_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  final List<String> _attachedImages = [];
  final List<XFile> _attachedImageFiles = []; // Store XFile objects for web compatibility
  final List<String> _attachedAudioFiles = [];
  final List<String> _attachedFiles = [];
  final AIService _aiService = AIService();
  String? _currentLocation;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      // Location is optional, continue without it
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _sendMessage(String text) async {
    // Only send if there's text or attachments
    if (text.trim().isEmpty && _attachedImages.isEmpty && _attachedAudioFiles.isEmpty && _attachedFiles.isEmpty) return;
    
    // Create user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      messageType: _attachedImages.isNotEmpty ? MessageType.image : MessageType.text,
      imageUrl: _attachedImages.isNotEmpty ? _attachedImages.first : null,
      attachedImages: List.from(_attachedImages),
      attachedAudioFiles: List.from(_attachedAudioFiles),
      attachedFiles: List.from(_attachedFiles),
    );

    // Save all attachment paths before clearing
    final imagePaths = List<String>.from(_attachedImages);
    final imageFiles = List<XFile>.from(_attachedImageFiles);
    final audioPaths = List<String>.from(_attachedAudioFiles);
    final filePaths = List<String>.from(_attachedFiles);
    
    logger.debug(
      'Sending message with ${imagePaths.length} images, ${audioPaths.length} audio files, ${filePaths.length} other files',
      tag: 'ChatScreen',
    );
    logger.debug('Message text: "${text.substring(0, text.length > 50 ? 50 : text.length)}${text.length > 50 ? "..." : ""}"', tag: 'ChatScreen');
    
    if (imagePaths.isNotEmpty) {
      for (var i = 0; i < imagePaths.length; i++) {
        if (!kIsWeb) {
          final exists = File(imagePaths[i]).existsSync();
          logger.debug(
            'Image $i: ${imagePaths[i].split('/').last} (exists: $exists)',
            tag: 'ChatScreen',
          );
        } else {
          logger.debug('Image $i: ${imagePaths[i]}', tag: 'ChatScreen');
        }
      }
    }
    
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      // Clear all inputs
      _attachedImages.clear();
      _attachedImageFiles.clear();
      _attachedAudioFiles.clear();
      _attachedFiles.clear();
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Prepare message text for AI
    String messageForAI = text.trim();
    
    // If there are attachments but no text, provide context
    if (messageForAI.isEmpty) {
      if (imagePaths.isNotEmpty) {
        messageForAI = 'Please analyze these images.';
      } else if (audioPaths.isNotEmpty) {
        messageForAI = 'I have attached audio files.';
      } else if (filePaths.isNotEmpty) {
        messageForAI = 'I have attached files.';
      }
    }
    
    // Get AI response
    try {
      final response = await _aiService.generateResponse(
        userMessage: messageForAI,
        conversationHistory: _messages,
        imagePaths: imagePaths.isNotEmpty ? imagePaths : null,
        imageFiles: imageFiles.isNotEmpty ? imageFiles : null,
        location: _currentLocation,
      );

      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
              messageType: MessageType.text,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Sorry, I encountered an error processing your request. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
              messageType: MessageType.text,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _attachedImages.add(image.path);
          _attachedImageFiles.add(image); // Store XFile for web compatibility
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  
  void _removeAttachedImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
      _attachedImageFiles.removeAt(index);
    });
  }
  
  void _removeAttachedAudio(int index) {
    setState(() {
      _attachedAudioFiles.removeAt(index);
    });
  }
  
  void _removeAttachedFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }
  
  void _showImageSourceDialog() {
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chatBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.agriculture, color: AppTheme.primaryColor),
            ),
             SizedBox(width: 12),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farming AI Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Organic solutions first',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'market':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketScreen(),
                    ),
                  );
                  break;
                case 'community':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityScreen(),
                    ),
                  );
                  break;
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'market',
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Market Prices'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'community',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Community'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryLight,
                            child: Icon(
                              Icons.agriculture,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Farming AI Assistant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'I can help with:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHelpItem(Icons.coronavirus_outlined, 'Sick crops & diseases'),
                          _buildHelpItem(Icons.bug_report_outlined, 'Pest & insect problems'),
                          _buildHelpItem(Icons.local_florist_outlined, 'Plant health & growth'),
                          _buildHelpItem(Icons.eco_outlined, 'Organic farming solutions'),
                          _buildHelpItem(Icons.location_on_outlined, 'Location-based advice'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.photo_camera, color: Colors.green, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Take a photo or describe your issue to get started',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return ChatBubble(
                          message: Message(
                            id: 'typing',
                            text: 'Typing...',
                            isUser: false,
                            timestamp: DateTime.now(),
                            messageType: MessageType.text,
                          ),
                          isTyping: true,
                        );
                      }
                      
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onImagePressed: () => _pickImage(ImageSource.gallery),
            onCameraPressed: _showImageSourceDialog,
            onVoicePressed: _isRecording ? _stopRecording : _startRecording,
            attachedImages: _attachedImages,
            attachedAudioFiles: _attachedAudioFiles,
            attachedFiles: _attachedFiles,
            onRemoveImage: _removeAttachedImage,
            onRemoveAudio: _removeAttachedAudio,
            onRemoveFile: _removeAttachedFile,
          ),
        ],
      ),
    );
  }
  
  Future<void> _startRecording() async {
    try {
      // Check and request permission
      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${directory.path}/$fileName';
        
        // Start recording
        await _audioRecorder.start(
          const RecordConfig(),
          path: filePath,
        );
        
        setState(() {
          _isRecording = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎤 Recording... Tap again to stop'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      // Stop recording
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
      });
      
      if (path != null && File(path).existsSync()) {
        setState(() {
          _attachedAudioFiles.add(path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Audio recorded. Click send to share'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
