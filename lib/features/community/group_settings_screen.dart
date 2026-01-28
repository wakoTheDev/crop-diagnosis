import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/community_model.dart';
import '../../providers/community_provider.dart';

class GroupSettingsScreen extends StatefulWidget {
  final Group group;

  const GroupSettingsScreen({super.key, required this.group});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // TODO: Upload image and get URL
        // For now, just use the local path
        await Provider.of<CommunityProvider>(context, listen: false).updateGroup(
          groupId: widget.group.id,
          imageUrl: image.path,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group icon updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
      return;
    }

    await Provider.of<CommunityProvider>(context, listen: false).updateGroup(
      groupId: widget.group.id,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<CommunityProvider>(context, listen: false).deleteGroup(widget.group.id);
      if (mounted) {
        Navigator.pop(context); // Close settings
        Navigator.pop(context); // Close chat screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group deleted')),
        );
      }
    }
  }

  void _shareInviteLink() {
    Clipboard.setData(ClipboardData(text: widget.group.inviteLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied to clipboard')),
    );
  }

  void _showAddMemberDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'User ID or Username',
            hintText: 'Enter user ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await Provider.of<CommunityProvider>(context, listen: false)
                    .addMemberToGroup(widget.group.id, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member added')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          final group = provider.getGroupById(widget.group.id);
          if (group == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members (${group.memberIds.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.memberIds.length,
                    itemBuilder: (context, index) {
                      final memberId = group.memberIds[index];
                      final isAdmin = group.adminIds.contains(memberId);
                      final isCreator = memberId == group.createdBy;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(memberId[0].toUpperCase()),
                        ),
                        title: Text(memberId),
                        subtitle: isAdmin ? const Text('Admin') : null,
                        trailing: !isCreator
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () async {
                                  await provider.removeMemberFromGroup(widget.group.id, memberId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Removed $memberId')),
                                    );
                                  }
                                },
                              )
                            : const Icon(Icons.star, color: AppTheme.primaryColor),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Group Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Group Icon
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: widget.group.imageUrl.isNotEmpty
                      ? NetworkImage(widget.group.imageUrl)
                      : null,
                  child: widget.group.imageUrl.isEmpty
                      ? const Icon(Icons.group, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Group Name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Invite Link
          Card(
            child: ListTile(
              leading: const Icon(Icons.link, color: AppTheme.primaryColor),
              title: const Text('Share Invite Link'),
              subtitle: Text(
                widget.group.inviteLink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _shareInviteLink,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Members
          Card(
            child: ListTile(
              leading: const Icon(Icons.people, color: AppTheme.primaryColor),
              title: const Text('Members'),
              subtitle: Text('${widget.group.memberIds.length} members'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showMembersList,
            ),
          ),
          const SizedBox(height: 8),

          // Add Member
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add, color: AppTheme.primaryColor),
              title: const Text('Add Member'),
              onTap: _showAddMemberDialog,
            ),
          ),
          const SizedBox(height: 24),

          // Delete Group
          ElevatedButton.icon(
            onPressed: _deleteGroup,
            icon: const Icon(Icons.delete),
            label: const Text('Delete Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
