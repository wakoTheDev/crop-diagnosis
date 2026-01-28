import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Represents a community that can contain multiple groups
class Community {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<String> groupIds;
  final List<String> pendingGroupRequests; // Group IDs waiting for approval
  final List<String> adminIds; // Users who can manage the community

  Community({
    String? id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    List<String>? groupIds,
    List<String>? pendingGroupRequests,
    List<String>? adminIds,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        memberIds = memberIds ?? [],
        groupIds = groupIds ?? [],
        pendingGroupRequests = pendingGroupRequests ?? [],
        adminIds = adminIds ?? [createdBy ?? 'admin'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'groupIds': groupIds,
      'pendingGroupRequests': pendingGroupRequests,
      'adminIds': adminIds,
    };
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      memberIds: List<String>.from(json['memberIds'] ?? []),
      groupIds: List<String>.from(json['groupIds'] ?? []),
      pendingGroupRequests: List<String>.from(json['pendingGroupRequests'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
    );
  }

  Community copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? memberIds,
    List<String>? groupIds,
    List<String>? pendingGroupRequests,
    List<String>? adminIds,
  }) {
    return Community(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy,
      createdAt: createdAt,
      memberIds: memberIds ?? this.memberIds,
      groupIds: groupIds ?? this.groupIds,
      pendingGroupRequests: pendingGroupRequests ?? this.pendingGroupRequests,
      adminIds: adminIds ?? this.adminIds,
    );
  }
}

/// Represents a group within a community
class Group {
  final String id;
  final String communityId;
  final String name;
  final String description;
  final String imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<String> adminIds; // Users who can manage the group
  final String inviteLink; // Shareable link to join group

  Group({
    String? id,
    required this.communityId,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    List<String>? adminIds,
    String? inviteLink,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        memberIds = memberIds ?? [],
        adminIds = adminIds ?? [createdBy ?? 'admin'],
        inviteLink = inviteLink ?? 'crop://group/${id ?? _uuid.v4()}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'adminIds': adminIds,
      'inviteLink': inviteLink,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      communityId: json['communityId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      memberIds: List<String>.from(json['memberIds'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
      inviteLink: json['inviteLink'] ?? 'crop://group/${json['id']}',
    );
  }

  Group copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? memberIds,
    List<String>? adminIds,
  }) {
    return Group(
      id: id,
      communityId: communityId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy,
      createdAt: createdAt,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      inviteLink: inviteLink,
    );
  }
}

/// Represents an announcement in a community (visible to all members)
class Announcement {
  final String id;
  final String communityId;
  final String title;
  final String content;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;

  Announcement({
    String? id,
    required this.communityId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdByName,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      communityId: json['communityId'],
      title: json['title'],
      content: json['content'],
      createdBy: json['createdBy'],
      createdByName: json['createdByName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Represents an attachment in a group message
class MessageAttachment {
  final String type; // 'image', 'audio', 'file'
  final String path; // Local file path or URL
  final String? name; // File name for files

  MessageAttachment({
    required this.type,
    required this.path,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'path': path,
      'name': name,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      type: json['type'],
      path: json['path'],
      name: json['name'],
    );
  }
}

/// Represents a message in a group chat
class GroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String text;
  final List<MessageAttachment> attachments;
  final DateTime timestamp;
  final bool isRead;

  GroupMessage({
    String? id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.text,
    List<MessageAttachment>? attachments,
    DateTime? timestamp,
    this.isRead = false,
  })  : id = id ?? _uuid.v4(),
        attachments = attachments ?? [],
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      groupId: json['groupId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      text: json['text'],
      attachments: (json['attachments'] as List?)
          ?.map((a) => MessageAttachment.fromJson(a))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  GroupMessage copyWith({
    bool? isRead,
  }) {
    return GroupMessage(
      id: id,
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      attachments: attachments,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
