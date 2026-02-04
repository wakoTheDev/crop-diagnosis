import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/community_model.dart';
import '../core/services/logger_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<Community> _communities = [];
  List<Group> _groups = [];
  List<Announcement> _announcements = [];
  final Map<String, List<GroupMessage>> _groupMessages = {}; // groupId -> messages

  static const String _communitiesBox = 'communities';
  static const String _groupsBox = 'groups';
  static const String _announcementsBox = 'announcements';
  static const String _messagesBox = 'group_messages';

  List<Community> get communities => _communities;
  List<Group> get groups => _groups;
  List<Announcement> get announcements => _announcements;

  CommunityProvider() {
    _loadData();
  }

  /// Load data from Hive
  Future<void> _loadData() async {
    try {
      final communitiesBox = await Hive.openBox(_communitiesBox);
      final groupsBox = await Hive.openBox(_groupsBox);
      final announcementsBox = await Hive.openBox(_announcementsBox);
      final messagesBox = await Hive.openBox(_messagesBox);

      _communities = communitiesBox.values
          .map((e) => Community.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _groups = groupsBox.values
          .map((e) => Group.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _announcements = announcementsBox.values
          .map((e) => Announcement.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Load messages for each group
      for (var entry in messagesBox.toMap().entries) {
        final groupId = entry.key as String;
        final messagesList = (entry.value as List)
            .map((e) => GroupMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _groupMessages[groupId] = messagesList;
      }

      // Add sample data if empty
      if (_communities.isEmpty) {
        _addSampleData();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      logger.error(
        'Failed to load community data',
        tag: 'CommunityProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Add sample communities for demonstration
  void _addSampleData() {
    final community1 = Community(
      name: 'Crop Farmers Network',
      description: 'A community for crop farmers to share knowledge and experiences',
      createdBy: 'admin',
      memberIds: ['user1', 'user2', 'user3'],
    );

    final community2 = Community(
      name: 'Agricultural Innovation Hub',
      description: 'Exploring new technologies and methods in agriculture',
      createdBy: 'admin',
      memberIds: ['user1', 'user4'],
    );

    _communities = [community1, community2];

    // Add sample groups
    final group1 = Group(
      communityId: community1.id,
      name: 'Maize Growing Tips',
      description: 'Share and discuss maize cultivation techniques',
      createdBy: 'admin',
      memberIds: ['user1', 'user2', 'user3'],
    );

    final group2 = Group(
      communityId: community1.id,
      name: 'Pest Management',
      description: 'Discuss pest control strategies',
      createdBy: 'admin',
      memberIds: ['user1', 'user2'],
    );

    final group3 = Group(
      communityId: community2.id,
      name: 'Smart Farming',
      description: 'Technology in modern agriculture',
      createdBy: 'admin',
      memberIds: ['user1', 'user4'],
    );

    _groups = [group1, group2, group3];

    // Update community group IDs
    _communities[0] = community1.copyWith(groupIds: [group1.id, group2.id]);
    _communities[1] = community2.copyWith(groupIds: [group3.id]);

    // Add sample announcements
    _announcements = [
      Announcement(
        communityId: community1.id,
        title: 'Welcome to Crop Farmers Network!',
        content: 'Thank you for joining our community. Share your experiences and learn from others.',
        createdBy: 'admin',
        createdByName: 'Admin',
      ),
      Announcement(
        communityId: community2.id,
        title: 'Monthly Webinar',
        content: 'Join us for a webinar on AI in agriculture next Friday at 3 PM.',
        createdBy: 'admin',
        createdByName: 'Admin',
      ),
    ];

    // Add sample messages
    _groupMessages[group1.id] = [
      GroupMessage(
        groupId: group1.id,
        senderId: 'user1',
        senderName: 'John Farmer',
        text: 'What is the best time to plant maize?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GroupMessage(
        groupId: group1.id,
        senderId: 'user2',
        senderName: 'Mary Green',
        text: 'Early spring is ideal, around March to April depending on your region.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _saveAllData();
  }

  /// Save all data to Hive
  Future<void> _saveAllData() async {
    final communitiesBox = await Hive.openBox(_communitiesBox);
    final groupsBox = await Hive.openBox(_groupsBox);
    final announcementsBox = await Hive.openBox(_announcementsBox);
    final messagesBox = await Hive.openBox(_messagesBox);

    await communitiesBox.clear();
    await groupsBox.clear();
    await announcementsBox.clear();

    for (var community in _communities) {
      await communitiesBox.put(community.id, community.toJson());
    }

    for (var group in _groups) {
      await groupsBox.put(group.id, group.toJson());
    }

    for (var announcement in _announcements) {
      await announcementsBox.put(announcement.id, announcement.toJson());
    }

    for (var entry in _groupMessages.entries) {
      await messagesBox.put(
        entry.key,
        entry.value.map((m) => m.toJson()).toList(),
      );
    }
  }

  /// Get groups for a specific community
  List<Group> getGroupsForCommunity(String communityId) {
    return _groups.where((g) => g.communityId == communityId).toList();
  }

  /// Get announcements for a specific community
  List<Announcement> getAnnouncementsForCommunity(String communityId) {
    return _announcements
        .where((a) => a.communityId == communityId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get messages for a specific group (sorted by time)
  List<GroupMessage> getMessagesForGroup(String groupId) {
    final messages = _groupMessages[groupId] ?? [];
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Create a new community
  Future<void> createCommunity({
    required String name,
    required String description,
    required String createdBy,
    String imageUrl = '',
  }) async {
    final community = Community(
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdBy: createdBy,
      memberIds: [createdBy],
    );

    _communities.add(community);
    await _saveAllData();
    notifyListeners();
  }

  /// Create a new group in a community
  Future<void> createGroup({
    required String communityId,
    required String name,
    required String description,
    required String createdBy,
    String imageUrl = '',
  }) async {
    final group = Group(
      communityId: communityId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      createdBy: createdBy,
      memberIds: [createdBy],
    );

    _groups.add(group);

    // Update community's group list
    final communityIndex = _communities.indexWhere((c) => c.id == communityId);
    if (communityIndex != -1) {
      final community = _communities[communityIndex];
      final updatedGroupIds = [...community.groupIds, group.id];
      _communities[communityIndex] = community.copyWith(groupIds: updatedGroupIds);
    }

    await _saveAllData();
    notifyListeners();
  }

  /// Create an announcement in a community
  Future<void> createAnnouncement({
    required String communityId,
    required String title,
    required String content,
    required String createdBy,
    required String createdByName,
  }) async {
    final announcement = Announcement(
      communityId: communityId,
      title: title,
      content: content,
      createdBy: createdBy,
      createdByName: createdByName,
    );

    _announcements.add(announcement);
    await _saveAllData();
    notifyListeners();
  }

  /// Send a message to a group
  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String text,
    List<MessageAttachment>? attachments,
  }) async {
    final message = GroupMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      attachments: attachments,
    );

    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }

    _groupMessages[groupId]!.add(message);
    await _saveAllData();
    notifyListeners();
  }

  /// Join a community
  Future<void> joinCommunity(String communityId, String userId) async {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final community = _communities[index];
      if (!community.memberIds.contains(userId)) {
        _communities[index] = community.copyWith(
          memberIds: [...community.memberIds, userId],
        );
        await _saveAllData();
        notifyListeners();
      }
    }
  }

  /// Join a group
  Future<void> joinGroup(String groupId, String userId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      if (!group.memberIds.contains(userId)) {
        _groups[index] = group.copyWith(
          memberIds: [...group.memberIds, userId],
        );
        await _saveAllData();
        notifyListeners();
      }
    }
  }

  /// Get a community by ID
  Community? getCommunityById(String id) {
    try {
      return _communities.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a group by ID
  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add member to group
  Future<void> addMemberToGroup(String groupId, String userId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      if (!group.memberIds.contains(userId)) {
        _groups[index] = group.copyWith(
          memberIds: [...group.memberIds, userId],
        );
        await _saveAllData();
        notifyListeners();
      }
    }
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      final updatedMembers = group.memberIds.where((id) => id != userId).toList();
      _groups[index] = group.copyWith(memberIds: updatedMembers);
      await _saveAllData();
      notifyListeners();
    }
  }

  /// Update group details (name, description, image)
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? imageUrl,
  }) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index] = _groups[index].copyWith(
        name: name,
        description: description,
        imageUrl: imageUrl,
      );
      await _saveAllData();
      notifyListeners();
    }
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    final group = getGroupById(groupId);
    if (group != null) {
      // Remove from community's group list
      final communityIndex = _communities.indexWhere((c) => c.id == group.communityId);
      if (communityIndex != -1) {
        final community = _communities[communityIndex];
        final updatedGroupIds = community.groupIds.where((id) => id != groupId).toList();
        _communities[communityIndex] = community.copyWith(groupIds: updatedGroupIds);
      }

      // Remove group
      _groups.removeWhere((g) => g.id == groupId);

      // Remove group messages
      _groupMessages.remove(groupId);

      await _saveAllData();
      notifyListeners();
    }
  }

  /// Remove group from community (community admin action)
  Future<void> removeGroupFromCommunity(String communityId, String groupId) async {
    await deleteGroup(groupId);
  }

  /// Request to add group to community
  Future<void> requestGroupJoinCommunity(String communityId, String groupId) async {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final community = _communities[index];
      if (!community.pendingGroupRequests.contains(groupId)) {
        _communities[index] = community.copyWith(
          pendingGroupRequests: [...community.pendingGroupRequests, groupId],
        );
        await _saveAllData();
        notifyListeners();
      }
    }
  }

  /// Approve group join request
  Future<void> approveGroupRequest(String communityId, String groupId) async {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final community = _communities[index];
      final updatedRequests = community.pendingGroupRequests.where((id) => id != groupId).toList();
      final updatedGroupIds = [...community.groupIds];
      if (!updatedGroupIds.contains(groupId)) {
        updatedGroupIds.add(groupId);
      }

      _communities[index] = community.copyWith(
        pendingGroupRequests: updatedRequests,
        groupIds: updatedGroupIds,
      );
      await _saveAllData();
      notifyListeners();
    }
  }

  /// Reject group join request
  Future<void> rejectGroupRequest(String communityId, String groupId) async {
    final index = _communities.indexWhere((c) => c.id == communityId);
    if (index != -1) {
      final community = _communities[index];
      final updatedRequests = community.pendingGroupRequests.where((id) => id != groupId).toList();
      _communities[index] = community.copyWith(pendingGroupRequests: updatedRequests);
      await _saveAllData();
      notifyListeners();
    }
  }

  /// Check if user is group admin
  bool isGroupAdmin(String groupId, String userId) {
    final group = getGroupById(groupId);
    return group?.adminIds.contains(userId) ?? false;
  }

  /// Check if user is community admin
  bool isCommunityAdmin(String communityId, String userId) {
    final community = getCommunityById(communityId);
    return community?.adminIds.contains(userId) ?? false;
  }
}
