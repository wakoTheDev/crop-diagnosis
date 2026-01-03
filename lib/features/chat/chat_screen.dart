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
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
          messageType: MessageType.text,
        ),
      );
      _isTyping = true;
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
              text: 'I understand you\'re asking about "$text". Let me help you with that...',
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
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Image sent for diagnosis',
              isUser: true,
              timestamp: DateTime.now(),
              messageType: MessageType.image,
              imageUrl: image.path,
            ),
          );
          _isTyping = true;
        });
        
        _scrollToBottom();
        
        // Simulate diagnosis
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _messages.add(
                Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: '🔍 Analysis Complete!\n\n'
                      'Disease: Early Blight\n'
                      'Confidence: 92%\n'
                      'Severity: Medium\n\n'
                      '💊 Treatment:\n'
                      '1. Remove affected leaves\n'
                      '2. Apply fungicide (Copper-based)\n'
                      '3. Improve air circulation\n\n'
                      'Would you like more details?',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
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
                    'AI Assistant',
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
            onImagePressed: _showImageSourceDialog,
            onVoicePressed: _isRecording ? _stopRecording : _startRecording,
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
        final file = File(path);
        final fileSize = await file.length();
        final fileSizeKB = (fileSize / 1024).toStringAsFixed(1);
        
        // Add voice message to chat
        setState(() {
          _messages.add(
            Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: '🎤 Voice message ($fileSizeKB KB)',
              isUser: true,
              timestamp: DateTime.now(),
              messageType: MessageType.text,
            ),
          );
          _isTyping = true;
        });
        
        _scrollToBottom();
        
        // Simulate AI response for voice message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _messages.add(
                Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: '🎧 I received your voice message. Voice transcription will be available soon!',
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Voice message sent'),
              duration: Duration(seconds: 1),
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
