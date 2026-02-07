import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../providers/auth_provider.dart';
import '../../providers/blog_provider.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;
  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _picker = ImagePicker();
  File? _commentImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().loadBlogById(widget.blogId);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (img != null) setState(() => _commentImage = File(img.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty && _commentImage == null) return;

    setState(() => _submitting = true);

    final ok = await context.read<BlogProvider>().addComment(
          blogId: widget.blogId,
          content: text,
          imageFile: _commentImage,
        );

    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        _commentCtrl.clear();
        setState(() => _commentImage = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add comment')));
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Blog'),
        content: const Text('Are you sure you want to delete this blog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await context.read<BlogProvider>().deleteBlog(widget.blogId);
              if (ok && mounted) context.go('/');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id;

    return Consumer<BlogProvider>(
      builder: (context, bp, _) {
        final blog = bp.selectedBlog;

        // Loading
        if (bp.status == BlogStatus.loading && blog == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Not found
        if (blog == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Blog not found')),
          );
        }

        final isOwner = blog.userId == currentUserId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: blog.imageUrl != null ? 250 : 0,
                pinned: true,
                flexibleSpace: blog.imageUrl != null
                    ? FlexibleSpaceBar(
                        background: CachedNetworkImage(
                          imageUrl: blog.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade200),
                        ),
                      )
                    : null,
                actions: isOwner
                    ? [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              context.push('/edit-blog/${blog.id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _confirmDelete,
                        ),
                      ]
                    : null,
              ),

              // Blog Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(blog.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                      const SizedBox(height: 16),

                      // Author
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: blog.author?.avatarUrl != null
                                ? CachedNetworkImageProvider(
                                    blog.author!.avatarUrl!)
                                : null,
                            child: blog.author?.avatarUrl == null
                                ? Text(
                                    (blog.author?.displayNameOrEmail ?? '?')[0]
                                        .toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  blog.author?.displayNameOrEmail ?? 'Unknown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (blog.createdAt != null)
                                  Text(timeago.format(blog.createdAt!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Content
                      Text(blog.content,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 8),

                      Text('Comments (${bp.comments.length})',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Comments
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = bp.comments[i];
                    return _CommentTile(
                      data: c,
                      isOwner: c['user_id'] == currentUserId,
                      onDelete: () =>
                          bp.deleteComment(c['id'] as String, widget.blogId),
                    );
                  },
                  childCount: bp.comments.length,
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Comment input
          bottomSheet: _buildCommentInput(context),
        );
      },
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview
          if (_commentImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 80,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_commentImage!,
                        height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _commentImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
              _submitting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitComment,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Comment tile ──

class _CommentTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isOwner;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.data,
    required this.isOwner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final profile = data['profiles'] as Map<String, dynamic>?;
    final avatar = profile?['avatar_url'] as String?;
    final name = profile?['display_name'] as String? ??
        (profile?['email'] as String?)?.split('@').first ??
        'Unknown';
    final content = data['content'] as String? ?? '';
    final imgUrl = data['image_url'] as String?;
    final created = data['created_at'] != null
        ? DateTime.tryParse(data['created_at'] as String)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                avatar != null ? CachedNetworkImageProvider(avatar) : null,
            child: avatar == null ? Text(name[0].toUpperCase()) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          if (isOwner)
                            GestureDetector(
                              onTap: onDelete,
                              child: const Icon(Icons.close, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(content),
                      if (imgUrl != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imgUrl,
                            placeholder: (_, __) => Container(
                                height: 150, color: Colors.grey.shade200),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (created != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(timeago.format(created),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
