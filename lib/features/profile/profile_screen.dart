import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/community_provider.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? (user.avatarUrl.startsWith('http')
                              ? NetworkImage(user.avatarUrl)
                              : FileImage(File(user.avatarUrl)) as ImageProvider)
                          : null,
                      child: user.avatarUrl.isEmpty
                          ? Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups,
                        label: 'Communities',
                        count: user.communityIds.length,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.group,
                        label: 'Groups',
                        count: user.groupIds.length,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // My Communities
              Consumer<CommunityProvider>(
                builder: (context, communityProvider, _) {
                  final userCommunities = communityProvider.communities
                      .where((c) => user.communityIds.contains(c.id))
                      .toList();

                  return _SectionCard(
                    title: 'My Communities',
                    icon: Icons.groups,
                    count: userCommunities.length,
                    children: userCommunities.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'You are not in any communities yet',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]
                        : userCommunities.map((community) {
                            final groupCount = communityProvider
                                .getGroupsForCommunity(community.id)
                                .length;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  community.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(community.name),
                              subtitle: Text('$groupCount groups'),
                              trailing: const Icon(Icons.chevron_right),
                            );
                          }).toList(),
                  );
                },
              ),

              const SizedBox(height: 16),

              // My Groups
              Consumer<CommunityProvider>(
                builder: (context, communityProvider, _) {
                  final userGroups = communityProvider.groups
                      .where((g) => user.groupIds.contains(g.id))
                      .toList();

                  return _SectionCard(
                    title: 'My Groups',
                    icon: Icons.group,
                    count: userGroups.length,
                    children: userGroups.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'You are not in any groups yet',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]
                        : userGroups.map((group) {
                            final messageCount = communityProvider
                                .getMessagesForGroup(group.id)
                                .length;
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.primaryLight,
                                child: Icon(Icons.group, color: Colors.white),
                              ),
                              title: Text(group.name),
                              subtitle: Text('$messageCount messages'),
                              trailing: const Icon(Icons.chevron_right),
                            );
                          }).toList(),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Settings
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppTheme.primaryColor),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showHelpDialog(context);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Crop Diagnostic',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Crop Diagnostic',
                        );
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Use Crop Diagnostic',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _HelpItem(
                icon: Icons.chat,
                title: 'AI Diagnosis',
                description: 'Take a photo of your crop and chat with AI to get instant diagnosis and treatment recommendations.',
              ),
              SizedBox(height: 8),
              _HelpItem(
                icon: Icons.groups,
                title: 'Communities',
                description: 'Join communities to connect with other farmers, share experiences, and get advice.',
              ),
              SizedBox(height: 8),
              _HelpItem(
                icon: Icons.shopping_bag,
                title: 'Marketplace',
                description: 'Buy and sell agricultural products. Browse listings or add your own products.',
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Text(
                'Need More Help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.email, color: AppTheme.primaryColor),
                title: Text('Email Support'),
                subtitle: Text('support@cropdiagnostic.com'),
                dense: true,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone, color: AppTheme.primaryColor),
                title: Text('Phone Support'),
                subtitle: Text('+254 700 000 000'),
                dense: true,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.schedule, color: AppTheme.primaryColor),
                title: Text('Support Hours'),
                subtitle: Text('Mon-Fri: 8:00 AM - 6:00 PM EAT'),
                dense: true,
              ),
            ],
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.count,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
