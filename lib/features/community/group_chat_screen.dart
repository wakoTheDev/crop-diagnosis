import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/firebase_messaging_service.dart';
import '../../data/models/community_model.dart';
import '../../providers/community_provider.dart';
import 'group_settings_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _messageFocusNode = FocusNode();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  bool _isRecording = false;
  bool _showScrollToBottom = false;
  bool _isUserScrolling = false;
  final List<MessageAttachment> _pendingAttachments = [];
  GroupMessage? _replyingTo;
  List<Map<String, dynamic>> _groupMembers = []; // Real members from Firebase
  bool _showMentionSuggestions = false;
  String _currentMentionQuery = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
    _scrollController.addListener(_scrollListener);
    _messageController.addListener(_textFieldListener);
  }

  Future<void> _loadGroupData() async {
    try {
      // Load real admin status
      final isAdmin = await _messagingService.isCurrentUserAdmin(widget.group.id);
      setState(() {
        _isAdmin = isAdmin;
      });

      // Listen to members changes
      _messagingService.streamGroupMembers(widget.group.id).listen((members) {
        setState(() {
          _groupMembers = members;
        });
      });
    } catch (e) {
      // Firebase is not initialized
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _groupMembers = [];
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _showScrollToBottom = (maxScroll - currentScroll) > 100;
        _isUserScrolling = (maxScroll - currentScroll) > 50;
      });
    }
  }

  void _textFieldListener() {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;
    
    // Check for @ mentions
    if (cursorPosition > 0 && text.substring(0, cursorPosition).contains('@')) {
      final lastAtIndex = text.substring(0, cursorPosition).lastIndexOf('@');
      final query = text.substring(lastAtIndex + 1, cursorPosition);
      
      if (!query.contains(' ')) {
        setState(() {
          _showMentionSuggestions = true;
          _currentMentionQuery = query.toLowerCase();
        });
      } else {
        setState(() => _showMentionSuggestions = false);
      }
    } else {
      setState(() => _showMentionSuggestions = false);
    }
  }

  void _insertMention(String name) {
    final text = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;
    final lastAtIndex = text.substring(0, cursorPosition).lastIndexOf('@');
    
    final newText = text.substring(0, lastAtIndex) + '@$name ' + text.substring(cursorPosition);
    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: lastAtIndex + name.length + 2),
    );
    
    setState(() => _showMentionSuggestions = false);
  }

  List<String> _extractMentions(String text) {
    final mentions = <String>[];
    final regex = RegExp(r'@(\w+(?:\s+\w+)*)');
    final matches = regex.allMatches(text);
    
    for (var match in matches) {
      final mention = match.group(1);
      if (mention != null) {
        // Check if mention matches any real member
        final matchingMember = _groupMembers.firstWhere(
          (m) => m['name'] == mention,
          orElse: () => {},
        );
        if (matchingMember.isNotEmpty) {
          mentions.add(mention);
        }
      }
    }
    
    return mentions;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _pendingAttachments.addAll(
            pickedFiles.map(
              (file) => MessageAttachment(
                type: 'image',
                path: file.path,
                name: file.name,
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _pendingAttachments.add(
            MessageAttachment(
              type: 'audio',
              path: path,
              name: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
            ),
          );
          _isRecording = false;
        });
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() => _isRecording = true);
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _pendingAttachments.removeAt(index);
    });
  }

  void _setReply(GroupMessage message) {
    setState(() {
      _replyingTo = message;
    });
    _messageFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    final mentions = _extractMentions(text);
    final mentionedIds = mentions.map((name) {
      final member = _groupMembers.firstWhere(
        (m) => m['name'] == name,
        orElse: () => {'id': ''},
      );
      return member['id'] as String;
    }).where((id) => id.isNotEmpty).toList();

    try {
      // Send via Firebase for real-time sync
      await _messagingService.sendMessage(
        groupId: widget.group.id,
        text: text,
        attachments: _pendingAttachments.isNotEmpty ? _pendingAttachments : null,
        replyToMessageId: _replyingTo?.id,
        replyToText: _replyingTo?.text,
        replyToSenderName: _replyingTo?.senderName,
        mentionedUserNames: mentions,
        mentionedUserIds: mentionedIds,
      );

      _messageController.clear();
      setState(() {
        _pendingAttachments.clear();
        _replyingTo = null;
      });

      Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom(animate: false));
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        final isFirebaseError = errorMessage.contains('Firebase') || 
                               errorMessage.contains('firestore') ||
                               errorMessage.toLowerCase().contains('not initialized');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFirebaseError 
                  ? 'Firebase is not enabled. Please initialize Firebase to send messages.'
                  : 'Failed to send message: $e'
            ),
            backgroundColor: isFirebaseError ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  bool _isAdminUser() {
    return _isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chatBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_isAdminUser())
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.admin_panel_settings, size: 16, color: Colors.amber),
                  ),
              ],
            ),
            Text(
              '${widget.group.memberIds.length} members',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  if (_isAdminUser()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupSettingsScreen(group: widget.group),
                      ),
                    );
                  }
                  break;
                case 'info':
                  _showGroupInfo();
                  break;
                case 'members':
                  _showMembers();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_isAdminUser())
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text('Manage Group'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'members',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('View Members'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Group Info'),
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
            child: Stack(
              children: [
                StreamBuilder<List<GroupMessage>>(
                  stream: _messagingService.streamMessages(widget.group.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final errorMessage = snapshot.error.toString();
                      final isFirebaseError = errorMessage.contains('Firebase') || 
                                             errorMessage.contains('firestore') ||
                                             errorMessage.toLowerCase().contains('not initialized');
                      
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFirebaseError ? Icons.cloud_off : Icons.error_outline,
                              size: 64,
                              color: isFirebaseError ? Colors.orange[400] : Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFirebaseError 
                                  ? 'Firebase Not Enabled' 
                                  : 'Error loading messages',
                              style: TextStyle(
                                fontSize: 18,
                                color: isFirebaseError ? Colors.orange[600] : Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                isFirebaseError
                                    ? 'Group chat requires Firebase to be enabled.\nPlease initialize Firebase in main.dart to use this feature.'
                                    : snapshot.error.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (isFirebaseError) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Go Back'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Auto-scroll on new message
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients && !_isUserScrolling) {
                        _scrollToBottom();
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final currentUserId = _messagingService.currentUserId;
                        final isCurrentUser = message.senderId == currentUserId;
                        final showSender = index == 0 ||
                            messages[index - 1].senderId != message.senderId;

                        return _MessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                          showSender: showSender,
                          onReply: () => _setReply(message),
                        );
                      },
                    );
                  },
                ),
                if (_showScrollToBottom)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: () => _scrollToBottom(),
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(Icons.arrow_downward, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // Mention suggestions
          if (_showMentionSuggestions) _buildMentionSuggestions(),
          // Reply preview
          if (_replyingTo != null) _buildReplyPreview(),
          // Pending attachments
          if (_pendingAttachments.isNotEmpty) _buildAttachmentsPreview(),
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMentionSuggestions() {
    final filtered = _groupMembers
        .where((member) => member['name']
            .toString()
            .toLowerCase()
            .contains(_currentMentionQuery.toLowerCase()))
        .take(5)
        .toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final member = filtered[index];
          final name = member['name'].toString();
          final isAdmin = member['isAdmin'] == true;
          
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                name[0],
                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
              ),
            ),
            title: Row(
              children: [
                Text(name, style: const TextStyle(fontSize: 14)),
                if (isAdmin) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 12, color: AppTheme.primaryColor),
                ],
              ],
            ),
            onTap: () => _insertMention(name),
          );
        },
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.2),
        border: Border(
          top: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          left: BorderSide(color: AppTheme.primaryColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${_replyingTo!.senderName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsPreview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _pendingAttachments.length,
          itemBuilder: (context, index) {
            final attachment = _pendingAttachments[index];
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: attachment.type == 'image'
                        ? Image.file(File(attachment.path), fit: BoxFit.cover)
                        : Container(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.audiotrack,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickImages,
            color: AppTheme.primaryColor,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Type a message... (use @ to mention)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: _toggleRecording,
            onLongPressUp: () {
              if (_isRecording) _toggleRecording();
            },
            child: Container(
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.description),
            const SizedBox(height: 16),
            Text(
              'Members: ${widget.group.memberIds.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${widget.group.createdAt.toString().split(' ')[0]}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Admins: ${widget.group.adminIds.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMembers() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _groupMembers.length,
                itemBuilder: (context, index) {
                  final member = _groupMembers[index];
                  final memberName = member['name']?.toString() ?? 'Unknown';
                  final isAdmin = member['isAdmin'] == true;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                    title: Text(memberName),
                    trailing: isAdmin
                        ? const Chip(
                            label: Text('Admin', style: TextStyle(fontSize: 10)),
                            backgroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final GroupMessage message;
  final bool isCurrentUser;
  final bool showSender;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.showSender,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: const Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    onReply();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    // Copy to clipboard
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser && showSender)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppTheme.sentMessageBg
                    : AppTheme.receivedMessageBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (message.replyToMessageId != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.replyToSenderName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            message.replyToText ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Attachments
                  if (message.attachments.isNotEmpty) ...[
                    ...message.attachments.map((attachment) {
                      if (attachment.type == 'image') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(attachment.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else if (attachment.type == 'audio') {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.audiotrack,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  attachment.name ?? 'Audio',
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                  // Text message with mentions highlighted
                  if (message.text.isNotEmpty)
                    _buildMessageText(message.text, message.mentionedUserNames),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (message.mentionedUserNames.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.alternate_email,
                          size: 10,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(String text, List<String> mentions) {
    if (mentions.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 14));
    }

    final spans = <TextSpan>[];
    var currentIndex = 0;

    for (final mention in mentions) {
      final mentionPattern = '@$mention';
      final index = text.indexOf(mentionPattern, currentIndex);
      
      if (index != -1) {
        // Add text before mention
        if (index > currentIndex) {
          spans.add(TextSpan(text: text.substring(currentIndex, index)));
        }
        
        // Add mention with styling
        spans.add(
          TextSpan(
            text: mentionPattern,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              backgroundColor: Color(0xFFE8F5E9),
            ),
          ),
        );
        
        currentIndex = index + mentionPattern.length;
      }
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: spans,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
