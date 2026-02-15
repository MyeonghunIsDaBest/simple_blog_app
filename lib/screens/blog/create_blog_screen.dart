// lib/screens/blog/create_blog_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/feed_column.dart';
import '../../widgets/horizontal_scrollable_list.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/sidebar_nav.dart';
import '../../widgets/sticky_header.dart';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  static const int _maxImages = 10;
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<Uint8List> _imageBytesList = [];
  final List<String> _imageExts = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  int get _remainingSlots => _maxImages - _imageBytesList.length;

  Future<void> _pickImage() async {
    if (_remainingSlots <= 0) return;
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text('Gallery (${_imageBytesList.length}/$_maxImages)'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickMultiImage(
                  maxWidth: 1280,
                  maxHeight: 1280,
                  imageQuality: 80,
                );
                if (picked.isNotEmpty) {
                  final take = picked.take(_remainingSlots);
                  for (final p in take) {
                    final bytes = await p.readAsBytes();
                    _imageBytesList.add(bytes);
                    _imageExts.add(p.name.split('.').last);
                  }
                  setState(() {});
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
                  maxWidth: 1280,
                  maxHeight: 1280,
                  imageQuality: 80,
                );
                if (p != null) {
                  final bytes = await p.readAsBytes();
                  setState(() {
                    _imageBytesList.add(bytes);
                    _imageExts.add(p.name.split('.').last);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BlogProvider>();
    final success = await provider.createBlog(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      imageBytesList: _imageBytesList.isNotEmpty ? _imageBytesList : null,
      imageExts: _imageExts.isNotEmpty ? _imageExts : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog published! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDiscardDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Draft?'),
        content: const Text(
          'Are you sure you want to discard this blog draft?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.go('/');
      }
    });
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Images
            HorizontalScrollableList(
              height: 120,
              spacing: 10,
              children: [
                ..._imageBytesList.asMap().entries.map((entry) {
                  final index = entry.key;
                  return HorizontalImageItem(
                    width: 120,
                    borderRadius: BorderRadius.circular(14),
                    image: Image.memory(
                      _imageBytesList[index],
                      fit: BoxFit.cover,
                    ),
                    onDelete: () => setState(() {
                      _imageBytesList.removeAt(index);
                      _imageExts.removeAt(index);
                    }),
                  );
                }),
                if (_remainingSlots > 0)
                  AddImageButton(
                    width: 120,
                    height: 120,
                    borderRadius: BorderRadius.circular(14),
                    label: '${_imageBytesList.length}/$_maxImages',
                    onTap: _pickImage,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleCtrl,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Give your blog a title...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.25),
                  fontWeight: FontWeight.w700,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),

            Divider(color: theme.dividerTheme.color, height: 1),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentCtrl,
              maxLines: null,
              minLines: 15,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
              decoration: InputDecoration(
                hintText: 'Tell your story...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.25),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Content is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlogProvider>();
    final theme = Theme.of(context);
    final hasSidebar = showSidebar(context);

    final publishButton = ElevatedButton(
      onPressed: provider.actionLoading ? null : _handlePublish,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: provider.actionLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Publish'),
    );

    if (hasSidebar) {
      return Scaffold(
        body: Row(
          children: [
            const SidebarNav(currentIndex: 2),
            Expanded(
              child: FeedColumn(
                maxWidth: 700,
                child: Column(
                  children: [
                    StickyHeader(
                      title: 'New Blog',
                      showBackButton: true,
                      onBack: _showDiscardDialog,
                      actions: [publishButton],
                    ),
                    Expanded(child: _buildForm(theme)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: _showDiscardDialog,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('New Blog'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: publishButton,
          ),
        ],
      ),
      body: _buildForm(theme),
    );
  }
}
