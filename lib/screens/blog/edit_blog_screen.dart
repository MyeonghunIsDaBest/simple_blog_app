// lib/screens/blog/edit_blog_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/responsive_layout.dart';

class EditBlogScreen extends StatefulWidget {
  final String blogId;

  const EditBlogScreen({super.key, required this.blogId});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  static const int _maxImages = 5;
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  List<String> _existingImageUrls = [];
  final List<Uint8List> _newImageBytesList = [];
  final List<String> _newImageExts = [];

  bool _loaded = false;

  int get _totalImageCount =>
      _existingImageUrls.length + _newImageBytesList.length;
  int get _remainingSlots => _maxImages - _totalImageCount;

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
        _existingImageUrls = List<String>.from(blog.imageUrls);
        _loaded = true;
      });
    }
  }

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
              title: Text('Gallery ($_totalImageCount/$_maxImages)'),
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
                    _newImageBytesList.add(bytes);
                    _newImageExts.add(p.name.split('.').last);
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
                    _newImageBytesList.add(bytes);
                    _newImageExts.add(p.name.split('.').last);
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
      existingImageUrls:
          _existingImageUrls.isNotEmpty ? _existingImageUrls : null,
      newImageBytesList:
          _newImageBytesList.isNotEmpty ? _newImageBytesList : null,
      newImageExts: _newImageExts.isNotEmpty ? _newImageExts : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog updated!'),
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
      body: ResponsiveCenter(
        maxWidth: 700,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Images
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _totalImageCount + (_remainingSlots > 0 ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Existing images first
                      if (index < _existingImageUrls.length) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _existingImageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _existingImageUrls.removeAt(index);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // New images
                      final newIndex = index - _existingImageUrls.length;
                      if (newIndex < _newImageBytesList.length) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(
                                  _newImageBytesList[newIndex],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _newImageBytesList.removeAt(newIndex);
                                    _newImageExts.removeAt(newIndex);
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // "Add" button
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$_totalImageCount/$_maxImages',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
      ),
    );
  }
}
