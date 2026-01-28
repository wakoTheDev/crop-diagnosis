import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/theme/app_theme.dart';
import '../../data/models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../home/home_screen.dart';
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
  final List<String> _attachedAudioFiles = [];
  final List<String> _attachedFiles = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }
  
  void _loadInitialMessages() {
    // Add welcome message
    setState(() {
      _messages.add(
        Message(
          id: '1',
          text: 'Hello! I\'m your AI farming assistant. How can I help you today? You can:\n\n📸 Send a photo of your crop\n💬 Ask farming questions\n🌤️ Check weather forecasts\n💰 View market prices',
          isUser: false,
          timestamp: DateTime.now(),
          messageType: MessageType.text,
        ),
      );
    });
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
  
  void _sendMessage(String text) {
    // Only send if there's text or attachments
    if (text.trim().isEmpty && _attachedImages.isEmpty && _attachedAudioFiles.isEmpty && _attachedFiles.isEmpty) return;
    
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
          messageType: _attachedImages.isNotEmpty ? MessageType.image : MessageType.text,
          imageUrl: _attachedImages.isNotEmpty ? _attachedImages.first : null,
          attachedImages: List.from(_attachedImages),
          attachedAudioFiles: List.from(_attachedAudioFiles),
          attachedFiles: List.from(_attachedFiles),
        ),
      );
      _isTyping = true;
      // Clear all inputs
      _attachedImages.clear();
      _attachedAudioFiles.clear();
      _attachedFiles.clear();
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: _attachedImages.isNotEmpty 
                  ? 'I received your message with attachments. Let me analyze that for you...'
                  : 'I understand you\'re asking about "$text". Let me help you with that...',
              isUser: false,
              timestamp: DateTime.now(),
              messageType: MessageType.text,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
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
              child: Icon(Icons.smart_toy, color: AppTheme.primaryColor),
            ),
             SizedBox(width: 12),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'agridoc',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
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
            child: ListView.builder(
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
}
