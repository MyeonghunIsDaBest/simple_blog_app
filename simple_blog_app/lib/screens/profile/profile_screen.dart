import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _newAvatar;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final p = context.read<AuthProvider>().profile;
    if (p != null) {
      _nameCtrl.text = p.displayName ?? '';
      _bioCtrl.text = p.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (img != null) setState(() => _newAvatar = File(img.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile(
      displayName: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      avatarFile: _newAvatar,
    );

    if (mounted) {
      if (ok) {
        setState(() {
          _editing = false;
          _newAvatar = null;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')));
      }
    }
  }

  ImageProvider? _avatarProvider(String? url) {
    if (_newAvatar != null) return FileImage(_newAvatar!);
    if (url != null) return CachedNetworkImageProvider(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _editing = false;
                  _newAvatar = null;
                  _loadData();
                });
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final profile = auth.profile;
          final user = auth.user;

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final avatarImg = _avatarProvider(profile.avatarUrl);
          final showInitial = avatarImg == null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: avatarImg,
                        child: showInitial
                            ? Text(
                                profile.displayNameOrEmail[0].toUpperCase(),
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                      if (_editing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: _pickAvatar,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? ''),
                  ),
                  const Divider(),

                  // Display Name
                  if (_editing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a display name';
                          }
                          return null;
                        },
                      ),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Display Name'),
                      subtitle: Text(profile.displayNameOrEmail),
                    ),
                  const Divider(),

                  // Bio
                  if (_editing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _bioCtrl,
                        maxLines: 3,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          prefixIcon: Icon(Icons.info_outline),
                          alignLabelWithHint: true,
                        ),
                      ),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Bio'),
                      subtitle: Text(profile.bio ?? 'No bio yet'),
                    ),
                  const Divider(),

                  // Theme
                  Consumer<ThemeProvider>(
                    builder: (context, tp, _) {
                      return SwitchListTile(
                        secondary: Icon(
                          tp.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        ),
                        title: const Text('Dark Mode'),
                        value: tp.isDarkMode,
                        onChanged: (_) => tp.toggleTheme(),
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Save
                  if (_editing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            auth.status == AuthStatus.loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: auth.status == AuthStatus.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AuthProvider>().signOut();
                        context.go('/login');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child:
                          const Text('Logout', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
