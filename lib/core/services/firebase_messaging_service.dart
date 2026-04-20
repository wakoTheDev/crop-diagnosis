import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/community_model.dart';
import 'logger_service.dart';

class FirebaseMessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
  
  // Get current user display name
  String get currentUserName => _auth.currentUser?.displayName ?? 'User';

  // Send message to group
  Future<void> sendMessage({
    required String groupId,
    required String text,
    List<MessageAttachment>? attachments,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
    List<String>? mentionedUserIds,
    List<String>? mentionedUserNames,
  }) async {
    try {
      final messageData = {
        'groupId': groupId,
        'senderId': currentUserId,
        'senderName': currentUserName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'replyToMessageId': replyToMessageId,
        'replyToText': replyToText,
        'replyToSenderName': replyToSenderName,
        'mentionedUserIds': mentionedUserIds ?? [],
        'mentionedUserNames': mentionedUserNames ?? [],
        'attachments': attachments?.map((a) => {
          'type': a.type,
          'path': a.path,
          'name': a.name,
        }).toList() ?? [],
      };

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add(messageData);

      logger.info('Message sent successfully to group $groupId', tag: 'FirebaseMessaging');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to send message',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Stream messages for a group (real-time)
  Stream<List<GroupMessage>> streamMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GroupMessage(
          id: doc.id,
          groupId: data['groupId'] ?? groupId,
          senderId: data['senderId'] ?? '',
          senderName: data['senderName'] ?? 'Unknown',
          text: data['text'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: data['isRead'] ?? false,
          replyToMessageId: data['replyToMessageId'],
          replyToText: data['replyToText'],
          replyToSenderName: data['replyToSenderName'],
          mentionedUserIds: List<String>.from(data['mentionedUserIds'] ?? []),
          mentionedUserNames: List<String>.from(data['mentionedUserNames'] ?? []),
          attachments: (data['attachments'] as List?)
              ?.map((a) => MessageAttachment(
                    type: a['type'] ?? '',
                    path: a['path'] ?? '',
                    name: a['name'],
                  ))
              .toList(),
        );
      }).toList();
    });
  }

  // Get group members (real-time)
  Stream<List<Map<String, dynamic>>> streamGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return [];
      
      final memberIds = List<String>.from(doc.data()?['memberIds'] ?? []);
      final members = <Map<String, dynamic>>[];

      for (final memberId in memberIds) {
        try {
          final userDoc = await _firestore.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            members.add({
              'id': memberId,
              'name': userDoc.data()?['displayName'] ?? 'User',
              'isAdmin': (doc.data()?['adminIds'] as List?)?.contains(memberId) ?? false,
            });
          }
        } catch (e) {
          logger.warning('Failed to fetch user $memberId', tag: 'FirebaseMessaging');
        }
      }

      return members;
    });
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (!doc.exists) return false;
      
      final adminIds = List<String>.from(doc.data()?['adminIds'] ?? []);
      return adminIds.contains(currentUserId);
    } catch (e) {
      return false;
    }
  }

  // Update group info (admin only)
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('groups').doc(groupId).update(updates);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update group',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Add member to group
  Future<void> addMember(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      logger.error(
        'Failed to add member',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Remove member from group (admin only)
  Future<void> removeMember(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e, stackTrace) {
      logger.error(
        'Failed to remove member',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Make user admin (admin only)
  Future<void> makeAdmin(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'adminIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      logger.error(
        'Failed to make admin',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Remove admin privileges (admin only)
  Future<void> removeAdmin(String groupId, String userId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'adminIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e, stackTrace) {
      logger.error(
        'Failed to remove admin',
        tag: 'FirebaseMessaging',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
