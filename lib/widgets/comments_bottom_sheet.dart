import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../providers/blog_provider.dart';
import 'horizontal_scrollable_list.dart';
import 'image_carousel.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String blogId;
  final List<CommentModel> comments;
  final int totalCommentCount;

  const CommentsBottomSheet({
    super.key,
    required this.blogId,
    required this.comments,
    required this.totalCommentCount,
  });

  static void show(
    BuildContext context, {
    required String blogId,
    required List<CommentModel> comments,
    required int totalCommentCount,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CommentsBottomSheet(
        blogId: blogId,
        comments: comments,
        totalCommentCount: totalCommentCount,
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  static const int _maxImages = 10;
  late TextEditingController _commentController;
  final List<Uint8List> _imageBytesList = [];
  final List<String> _imageExts = [];
  bool _isSubmitting = false;

  int get _remainingSlots => _maxImages - _imageBytesList.length;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
              title: Text('Gallery (${_imageBytesList.length}/$_maxImages)'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickMultiImage(
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
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
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
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

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty && _imageBytesList.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    final blogProvider = context.read<BlogProvider>();
    final success = await blogProvider.addComment(
      blogId: widget.blogId,
      content: _commentController.text.trim(),
      imageBytesList: _imageBytesList.isNotEmpty ? _imageBytesList : null,
      imageExts: _imageExts.isNotEmpty ? _imageExts : null,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      _commentController.clear();
      _imageBytesList.clear();
      _imageExts.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Comments (${widget.totalCommentCount})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // Comments list
          Expanded(
            child: widget.comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Comment header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: comment
                                              .author?.avatarUrl.isNotEmpty ==
                                          true
                                      ? NetworkImage(comment.author!.avatarUrl)
                                      : null,
                                  child: comment.author?.avatarUrl.isEmpty ??
                                          true
                                      ? Text(
                                          comment.author?.displayName
                                                      .isNotEmpty ==
                                                  true
                                              ? comment.author!.displayName[0]
                                              : comment.author?.email
                                                      .substring(0, 1)
                                                      .toUpperCase() ??
                                                  '?',
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.author?.nameOrEmail ??
                                            'Anonymous',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        comment.createdAt.isNotEmpty
                                            ? _formatDate(comment.createdAt)
                                            : 'Just now',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Comment content
                            Text(
                              comment.content,
                              style: const TextStyle(fontSize: 13),
                            ),
                            // Comment images
                            if (comment.hasImages)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ImageCarousel(
                                  imageUrls: comment.imageUrls,
                                  height: 150,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 0),
          // Comment input
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview thumbnails
                if (_imageBytesList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HorizontalScrollableList(
                      height: 70,
                      spacing: 8,
                      children: _imageBytesList.asMap().entries.map((entry) {
                        final index = entry.key;
                        return HorizontalImageItem(
                          width: 70,
                          borderRadius: BorderRadius.circular(8),
                          image: Image.memory(
                            _imageBytesList[index],
                            fit: BoxFit.cover,
                          ),
                          onDelete: () => setState(() {
                            _imageBytesList.removeAt(index);
                            _imageExts.removeAt(index);
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _isSubmitting || _remainingSlots <= 0
                          ? null
                          : _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.image_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submitComment,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return 'Just now';
    }
  }
}
