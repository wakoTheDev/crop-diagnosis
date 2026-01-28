import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final settings = userProvider.settings;

          return ListView(
            children: [
              // Notifications Section
              _SectionHeader(title: 'Notifications'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications, color: AppTheme.primaryColor),
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive push notifications'),
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                        userProvider.toggleNotifications(value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                      title: const Text('Sound'),
                      subtitle: const Text('Play notification sounds'),
                      value: settings.soundEnabled,
                      onChanged: (value) {
                        userProvider.toggleSound(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Appearance Section
              _SectionHeader(title: 'Appearance'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette, color: AppTheme.primaryColor),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeLabel(settings.theme)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showThemeDialog(context, userProvider);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.text_fields, color: AppTheme.primaryColor),
                      title: const Text('Message Text Size'),
                      subtitle: Text('${settings.messageTextSize}pt'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showTextSizeDialog(context, userProvider);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Language Section
              _SectionHeader(title: 'Language'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                  title: const Text('App Language'),
                  subtitle: Text(_getLanguageLabel(settings.language)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog(context, userProvider);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Data & Storage Section
              _SectionHeader(title: 'Data & Storage'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.image, color: AppTheme.primaryColor),
                      title: const Text('Auto-download Images'),
                      subtitle: const Text('Download images automatically'),
                      value: settings.autoDownloadImages,
                      onChanged: (value) {
                        userProvider.toggleAutoDownloadImages(value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.audiotrack, color: AppTheme.primaryColor),
                      title: const Text('Auto-download Audio'),
                      subtitle: const Text('Download audio files automatically'),
                      value: settings.autoDownloadAudio,
                      onChanged: (value) {
                        userProvider.toggleAutoDownloadAudio(value);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.clear_all, color: AppTheme.primaryColor),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Free up storage space'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showClearCacheDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Privacy Section
              _SectionHeader(title: 'Privacy'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock, color: AppTheme.primaryColor),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Show privacy policy
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primaryColor),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Show terms
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System Default';
      default:
        return 'System Default';
    }
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'sw':
        return 'Swahili';
      case 'fr':
        return 'French';
      default:
        return 'English';
    }
  }

  void _showThemeDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: provider.settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.changeTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: provider.settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.changeTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('System Default'),
              value: 'system',
              groupValue: provider.settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.changeTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [12, 14, 16, 18].map((size) {
            return RadioListTile<int>(
              title: Text('${size}pt', style: TextStyle(fontSize: size.toDouble())),
              value: size,
              groupValue: provider.settings.messageTextSize,
              onChanged: (value) {
                if (value != null) {
                  provider.updateTextSize(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: provider.settings.language,
              onChanged: (value) {
                if (value != null) {
                  provider.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Swahili'),
              value: 'sw',
              groupValue: provider.settings.language,
              onChanged: (value) {
                if (value != null) {
                  provider.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('French'),
              value: 'fr',
              groupValue: provider.settings.language,
              onChanged: (value) {
                if (value != null) {
                  provider.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
