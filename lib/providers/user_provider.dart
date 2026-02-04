import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/user_model.dart';
import '../core/services/logger_service.dart'; 

class UserProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  AppSettings _settings = AppSettings();

  static const String _userBox = 'user_profile';
  static const String _settingsBox = 'app_settings';

  UserProfile? get currentUser => _currentUser;
  AppSettings get settings => _settings;
  String get currentUserId => _currentUser?.id ?? 'currentUser';

  UserProvider() {
    _loadData();
  }

  /// Load user data and settings from Hive
  Future<void> _loadData() async {
    try {
      final userBox = await Hive.openBox(_userBox);
      final settingsBox = await Hive.openBox(_settingsBox);

      if (userBox.isNotEmpty) {
        _currentUser = UserProfile.fromJson(
          Map<String, dynamic>.from(userBox.get('profile')),
        );
      } else {
        // Create default user
        _currentUser = UserProfile(
          username: 'Farmer User',
          //email: 'farmer@crop.app',
          bio: 'Passionate about sustainable farming',
        );
        await _saveUser();
      }

      if (settingsBox.isNotEmpty) {
        _settings = AppSettings.fromJson(
          Map<String, dynamic>.from(settingsBox.get('settings')),
        );
      } else {
        await _saveSettings();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      logger.error(
        'Failed to load user data from SharedPreferences',
        tag: 'UserProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save user profile
  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final userBox = await Hive.openBox(_userBox);
      await userBox.put('profile', _currentUser!.toJson());
    }
  }

  /// Save app settings
  Future<void> _saveSettings() async {
    final settingsBox = await Hive.openBox(_settingsBox);
    await settingsBox.put('settings', _settings.toJson());
  }

  /// Update user profile
  Future<void> updateProfile({
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        username: username,
        // email: email,
        avatarUrl: avatarUrl,
        bio: bio,
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Add community to user's list
  Future<void> joinCommunity(String communityId) async {
    if (_currentUser != null && !_currentUser!.communityIds.contains(communityId)) {
      _currentUser = _currentUser!.copyWith(
        communityIds: [..._currentUser!.communityIds, communityId],
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Remove community from user's list
  Future<void> leaveCommunity(String communityId) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        communityIds: _currentUser!.communityIds.where((id) => id != communityId).toList(),
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Add group to user's list
  Future<void> joinGroupUser(String groupId) async {
    if (_currentUser != null && !_currentUser!.groupIds.contains(groupId)) {
      _currentUser = _currentUser!.copyWith(
        groupIds: [..._currentUser!.groupIds, groupId],
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Remove group from user's list
  Future<void> leaveGroup(String groupId) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        groupIds: _currentUser!.groupIds.where((id) => id != groupId).toList(),
      );
      await _saveUser();
      notifyListeners();
    }
  }

  /// Update app settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle sound
  Future<void> toggleSound(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    await _saveSettings();
    notifyListeners();
  }

  /// Change theme
  Future<void> changeTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _saveSettings();
    notifyListeners();
  }

  /// Change language
  Future<void> changeLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _saveSettings();
    notifyListeners();
  }

  /// Update message text size
  Future<void> updateTextSize(int size) async {
    _settings = _settings.copyWith(messageTextSize: size);
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle auto download images
  Future<void> toggleAutoDownloadImages(bool value) async {
    _settings = _settings.copyWith(autoDownloadImages: value);
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle auto download audio
  Future<void> toggleAutoDownloadAudio(bool value) async {
    _settings = _settings.copyWith(autoDownloadAudio: value);
    await _saveSettings();
    notifyListeners();
  }
}
