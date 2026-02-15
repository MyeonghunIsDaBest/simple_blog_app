// lib/screens/profile/profile_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/feed_column.dart';
import '../../widgets/sticky_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  Uint8List? _avatarBytes;
  String? _avatarExt;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final profile = context.read<AuthProvider>().profile;
    if (profile != null) {
      _nameCtrl.text = profile.displayName;
      _bioCtrl.text = profile.bio;
    }
    setState(() => _loaded = true);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final p = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (p != null) {
                  final bytes = await p.readAsBytes();
                  setState(() {
                    _avatarBytes = bytes;
                    _avatarExt = p.name.split('.').last;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(ctx);
                final p = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (p != null) {
                  final bytes = await p.readAsBytes();
                  setState(() {
                    _avatarBytes = bytes;
                    _avatarExt = p.name.split('.').last;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name is required')),
      );
      return;
    }

    setState(() => _saving = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      displayName: name,
      bio: _bioCtrl.text.trim(),
      avatarBytes: _avatarBytes,
      avatarExt: _avatarExt,
    );

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        await context.read<AuthProvider>().signOut();
        if (context.mounted) context.go('/login');
      }
    });
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(90, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _saving
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Save'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return AppShell(
      currentIndex: 3,
      body: FeedColumn(
        maxWidth: 500,
        child: Column(
          children: [
            StickyHeader(
              title: 'Profile',
              actions: [_buildSaveButton()],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Avatar
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary
                                    .withOpacity(0.08),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  width: 3,
                                ),
                                image: _avatarBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(_avatarBytes!),
                                        fit: BoxFit.cover,
                                      )
                                    : (profile?.avatarUrl.isNotEmpty == true
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                profile!.avatarUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                              ),
                              child: _avatarBytes == null &&
                                      (profile?.avatarUrl.isEmpty ?? true)
                                  ? Text(
                                      profile?.initials ?? '?',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.4),
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      profile?.nameOrEmail ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile?.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Fields
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Display Name',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        prefixIcon:
                            Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bio',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'A few words about you...',
                        prefixIcon:
                            Icon(Icons.info_outline_rounded, size: 20),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme toggle
                    _SettingsTile(
                      icon: themeProvider.isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'Appearance',
                      subtitle:
                          themeProvider.isDark ? 'Dark mode' : 'Light mode',
                      trailing: Switch(
                        value: themeProvider.isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Member since
                    if (profile != null)
                      _SettingsTile(
                        icon: Icons.calendar_today_rounded,
                        title: 'Member since',
                        subtitle: _memberSince(profile.createdAt),
                      ),

                    const SizedBox(height: 32),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _memberSince(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return 'Unknown';
    }
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovering
              ? theme.colorScheme.primary.withOpacity(0.04)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.dividerTheme.color ?? Colors.grey.withOpacity(0.15),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(widget.title),
          subtitle: Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          trailing: widget.trailing,
        ),
      ),
    );
  }
}
