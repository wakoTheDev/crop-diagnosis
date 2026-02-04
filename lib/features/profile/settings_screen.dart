import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
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
              const _SectionHeader(title: 'Notifications'),
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
              const _SectionHeader(title: 'Appearance'),
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
              const _SectionHeader(title: 'Language'),
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
              const _SectionHeader(title: 'Data & Storage'),
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
              const _SectionHeader(title: 'Privacy'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock, color: AppTheme.primaryColor),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showPrivacyPolicyDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primaryColor),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showTermsOfServiceDialog(context);
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
            onPressed: () async {
              try {
                // Clear cache box
                final cacheBox = await Hive.openBox(AppConstants.cacheBox);
                await cacheBox.clear();
                
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to clear cache: $e')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'Last updated: February 4, 2026\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, including:\n'
            '• Account information (name, email, phone number)\n'
            '• Profile information\n'
            '• Messages and content you share\n'
            '• Images and files you upload for crop diagnosis\n\n'
            '2. How We Use Your Information\n'
            'We use the information we collect to:\n'
            '• Provide and improve our services\n'
            '• Process crop diagnosis requests\n'
            '• Facilitate marketplace transactions\n'
            '• Send notifications and updates\n'
            '• Ensure security and prevent fraud\n\n'
            '3. Data Sharing\n'
            'We do not sell your personal information. We may share your data with:\n'
            '• AI service providers for crop diagnosis\n'
            '• Payment processors for marketplace transactions\n'
            '• Service providers who assist our operations\n\n'
            '4. Data Security\n'
            'We implement appropriate security measures to protect your information. '
            'However, no method of transmission over the internet is 100% secure.\n\n'
            '5. Your Rights\n'
            'You have the right to:\n'
            '• Access your personal data\n'
            '• Request data deletion\n'
            '• Opt-out of notifications\n'
            '• Update your information\n\n'
            '6. Contact Us\n'
            'For privacy concerns, contact us at: support@cropdiagnostic.com',
            style: TextStyle(fontSize: 14),
          ),
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

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            'Last updated: February 4, 2026\n\n'
            '1. Acceptance of Terms\n'
            'By accessing and using Crop Diagnostic, you accept and agree to be bound by '
            'the terms and provisions of this agreement.\n\n'
            '2. Use License\n'
            'Permission is granted to use this application for personal or commercial '
            'agricultural purposes. You may not:\n'
            '• Modify or copy the application materials\n'
            '• Use the materials for commercial purposes without authorization\n'
            '• Attempt to reverse engineer any software\n'
            '• Remove any copyright or proprietary notations\n\n'
            '3. AI Diagnosis Disclaimer\n'
            'The AI-powered crop diagnosis feature is provided for informational purposes only. '
            'While we strive for accuracy, the diagnosis should not replace professional '
            'agricultural advice. Always consult with qualified experts for critical decisions.\n\n'
            '4. Marketplace Terms\n'
            'When using the marketplace:\n'
            '• Sellers are responsible for product quality and delivery\n'
            '• Buyers should verify product details before purchase\n'
            '• Transactions are subject to Kenya\'s consumer protection laws\n'
            '• We facilitate connections but are not party to transactions\n\n'
            '5. User Content\n'
            'You retain ownership of content you post. By sharing content, you grant us '
            'a license to use it for service improvement and AI model training.\n\n'
            '6. Account Termination\n'
            'We reserve the right to terminate accounts that violate these terms or '
            'engage in fraudulent activities.\n\n'
            '7. Limitation of Liability\n'
            'We are not liable for any damages arising from use of this application, '
            'including crop losses or marketplace transactions.\n\n'
            '8. Changes to Terms\n'
            'We may modify these terms at any time. Continued use constitutes acceptance '
            'of modified terms.\n\n'
            '9. Contact Information\n'
            'For questions about these terms, contact: legal@cropdiagnostic.com',
            style: TextStyle(fontSize: 14),
          ),
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
