// lib/screens/blog/edit_blog_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/blog_provider.dart';

class EditBlogScreen extends StatefulWidget {
  final String blogId;

  const EditBlogScreen({super.key, required this.blogId});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  File? _imageFile;
  String? _existingImageUrl;
  bool _removeImage = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBlog();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBlog() async {
    final provider = context.read<BlogProvider>();
    if (provider.currentBlog?.id != widget.blogId) {
      await provider.loadBlogDetail(widget.blogId);
    }
    final blog = provider.currentBlog;
    if (blog != null && mounted) {
      setState(() {
        _titleCtrl.text = blog.title;
        _contentCtrl.text = blog.content;
        _existingImageUrl = blog.imageUrl;
        _loaded = true;
      });
    }
  }

  Future<void> _pickImage() async {
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
                  maxWidth: 1280,
                  maxHeight: 1280,
                  imageQuality: 80,
                );
                if (p != null) {
                  setState(() {
                    _imageFile = File(p.path);
                    _removeImage = false;
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
                  maxWidth: 1280,
                  maxHeight: 1280,
                  imageQuality: 80,
                );
                if (p != null) {
                  setState(() {
                    _imageFile = File(p.path);
                    _removeImage = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BlogProvider>();
    final success = await provider.updateBlog(
      id: widget.blogId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      imageFile: _imageFile,
      removeImage: _removeImage,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog updated! ✓'),
            backgroundColor: Colors.green,
          ),
        );
        await provider.loadBlogDetail(widget.blogId);
        if (mounted) context.pop();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlogProvider>();
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Blog')),
        body: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

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
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text('Edit Blog'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: provider.actionLoading ? null : _handleUpdate,
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
                  : const Text('Update'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: _buildImageContent(theme),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _titleCtrl,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Blog title...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                },
              ),

              Divider(color: theme.dividerTheme.color, height: 1),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentCtrl,
                maxLines: null,
                minLines: 15,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                decoration: InputDecoration(
                  hintText: 'Content...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    if (_imageFile != null) {
      return _imageWithRemove(
        child: Image.file(_imageFile!, fit: BoxFit.cover),
        onRemove: () => setState(() {
          _imageFile = null;
          _removeImage = true;
        }),
      );
    }

    if (!_removeImage &&
        _existingImageUrl != null &&
        _existingImageUrl!.isNotEmpty) {
      return _imageWithRemove(
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(theme),
        ),
        onRemove: () => setState(() => _removeImage = true),
      );
    }

    return _placeholder(theme);
  }

  Widget _imageWithRemove({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: theme.colorScheme.primary.withOpacity(0.3)),
        const SizedBox(height: 8),
        Text(
          'Add cover image',
          style: TextStyle(
            color: theme.colorScheme.primary.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
