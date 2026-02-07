import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final _picker = ImagePicker();
  File? _newImage;
  String? _existingUrl;
  bool _submitting = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final blog = context.read<BlogProvider>().selectedBlog;
      if (blog != null) {
        _titleCtrl.text = blog.title;
        _contentCtrl.text = blog.content;
        _existingUrl = blog.imageUrl;
        _loaded = true;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (img != null) {
        setState(() {
          _newImage = File(img.path);
          _existingUrl = null;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  void _removeImage() {
    setState(() {
      _newImage = null;
      _existingUrl = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final ok = await context.read<BlogProvider>().updateBlog(
          id: widget.blogId,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          imageFile: _newImage,
          existingImageUrl: _existingUrl,
        );

    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        context.go('/blog/${widget.blogId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update blog')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _newImage != null || _existingUrl != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _newImage != null
                                ? Image.file(_newImage!, fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: _existingUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        Container(color: Colors.grey.shade200),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 48, color: Colors.grey.shade500),
                          const SizedBox(height: 8),
                          Text('Add Cover Image',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _titleCtrl,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter blog title',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a title';
                if (v.trim().length < 5) return 'Min 5 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contentCtrl,
              maxLines: 15,
              minLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your blog content here...',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter content';
                if (v.trim().length < 50) return 'Min 50 characters';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
