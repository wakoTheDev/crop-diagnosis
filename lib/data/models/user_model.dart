import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final double? farmSize;
  final String? location;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.farmSize,
    this.location,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'farm_size': farmSize,
      'location': location,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      farmSize: json['farm_size']?.toDouble(),
      location: json['location'],
      preferredLanguage: json['preferred_language'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  User copyWith({
    String? name,
    String? phone,
    String? email,
    double? farmSize,
    String? location,
    String? preferredLanguage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      farmSize: farmSize ?? this.farmSize,
      location: location ?? this.location,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// User profile with avatar and social features
class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final String bio;
  final List<String> communityIds;
  final List<String> groupIds;

  UserProfile({
    String? id,
    required this.username,
    this.avatarUrl = '',
    this.bio = '',
    List<String>? communityIds,
    List<String>? groupIds,
  })  : id = id ?? _uuid.v4(),
        communityIds = communityIds ?? [],
        groupIds = groupIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'communityIds': communityIds,
      'groupIds': groupIds,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      communityIds: List<String>.from(json['communityIds'] ?? []),
      groupIds: List<String>.from(json['groupIds'] ?? []),
    );
  }

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
    List<String>? communityIds,
    List<String>? groupIds,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      communityIds: communityIds ?? this.communityIds,
      groupIds: groupIds ?? this.groupIds,
    );
  }
}

/// Application settings
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language;
  final String theme;
  final bool autoDownloadImages;
  final bool autoDownloadAudio;
  final int messageTextSize;

  AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.language = 'en',
    this.theme = 'system',
    this.autoDownloadImages = true,
    this.autoDownloadAudio = true,
    this.messageTextSize = 14,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
      'theme': theme,
      'autoDownloadImages': autoDownloadImages,
      'autoDownloadAudio': autoDownloadAudio,
      'messageTextSize': messageTextSize,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      autoDownloadImages: json['autoDownloadImages'] ?? true,
      autoDownloadAudio: json['autoDownloadAudio'] ?? true,
      messageTextSize: json['messageTextSize'] ?? 14,
    );
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
    String? theme,
    bool? autoDownloadImages,
    bool? autoDownloadAudio,
    int? messageTextSize,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoDownloadImages: autoDownloadImages ?? this.autoDownloadImages,
      autoDownloadAudio: autoDownloadAudio ?? this.autoDownloadAudio,
      messageTextSize: messageTextSize ?? this.messageTextSize,
    );
  }
}
