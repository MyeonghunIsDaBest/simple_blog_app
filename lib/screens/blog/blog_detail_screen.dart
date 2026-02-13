// lib/screens/blog/blog_detail_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/horizontal_scrollable_list.dart';
import '../../widgets/image_carousel.dart';
import '../../widgets/responsive_layout.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  static const int _maxCommentImages = 10;
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _commentScrollCtrl = ScrollController();
  final List<Uint8List> _commentImageBytesList = [];
  final List<String> _commentImageExts = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BlogProvider>().loadBlogDetail(widget.blogId);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    _commentScrollCtrl.dispose();
    super.dispose();
  }

  String? get _currentUserId => context.read<AuthProvider>().currentUserId;

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Blog'),
        content: const Text(
          'This will permanently delete this blog and all its comments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success =
          await context.read<BlogProvider>().deleteBlog(widget.blogId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog deleted'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    }
  }

  int get _commentRemainingSlots =>
      _maxCommentImages - _commentImageBytesList.length;

  Future<void> _pickCommentImage() async {
    if (_commentRemainingSlots <= 0) return;
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(
                  'Gallery (${_commentImageBytesList.length}/$_maxCommentImages)'),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await picker.pickMultiImage(
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 75,
                );
                if (picked.isNotEmpty) {
                  final take = picked.take(_commentRemainingSlots);
                  for (final p in take) {
                    final bytes = await p.readAsBytes();
                    _commentImageBytesList.add(bytes);
                    _commentImageExts.add(p.name.split('.').last);
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
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 75,
                );
                if (p != null) {
                  final bytes = await p.readAsBytes();
                  setState(() {
                    _commentImageBytesList.add(bytes);
                    _commentImageExts.add(p.name.split('.').last);
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
    final text = _commentCtrl.text.trim();
    if (text.isEmpty && _commentImageBytesList.isEmpty) return;

    final blogProvider = context.read<BlogProvider>();
    final success = await blogProvider.addComment(
      blogId: widget.blogId,
      content: text.isNotEmpty ? text : '📷',
      imageBytesList:
          _commentImageBytesList.isNotEmpty ? _commentImageBytesList : null,
      imageExts: _commentImageExts.isNotEmpty ? _commentImageExts : null,
    );

    if (success && mounted) {
      _commentCtrl.clear();
      setState(() {
        _commentImageBytesList.clear();
        _commentImageExts.clear();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        final ctrl = isDesktop(context) ? _commentScrollCtrl : _scrollCtrl;
        if (ctrl.hasClients) {
          ctrl.animateTo(
            ctrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showEditCommentDialog(CommentModel comment) {
    final editController = TextEditingController(text: comment.content);
    final List<String> existingUrls = List<String>.from(comment.imageUrls);
    final List<Uint8List> newImageBytes = [];
    final List<String> newImageExts = [];
    const int maxImages = 10;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final totalImages = existingUrls.length + newImageBytes.length;
          final remainingSlots = maxImages - totalImages;

          Future<void> pickImage() async {
            if (remainingSlots <= 0) return;
            final picker = ImagePicker();
            Navigator.pop(context); // Close bottom sheet

            final picked = await picker.pickMultiImage(
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 75,
            );

            if (picked.isNotEmpty) {
              final take = picked.take(remainingSlots);
              for (final p in take) {
                final bytes = await p.readAsBytes();
                newImageBytes.add(bytes);
                newImageExts.add(p.name.split('.').last);
              }
              setDialogState(() {});
            }
          }

          return AlertDialog(
            title: const Text('Edit Comment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Existing images
                  if (existingUrls.isNotEmpty) ...[
                    Text(
                      'Current Images',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    HorizontalScrollableList(
                      height: 70,
                      spacing: 8,
                      children: existingUrls.asMap().entries.map((entry) {
                        final index = entry.key;
                        final url = entry.value;
                        return HorizontalImageItem(
                          width: 70,
                          borderRadius: BorderRadius.circular(8),
                          image: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                          onDelete: () => setDialogState(() {
                            existingUrls.removeAt(index);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // New images
                  if (newImageBytes.isNotEmpty) ...[
                    Text(
                      'New Images',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    HorizontalScrollableList(
                      height: 70,
                      spacing: 8,
                      children: newImageBytes.asMap().entries.map((entry) {
                        final index = entry.key;
                        return HorizontalImageItem(
                          width: 70,
                          borderRadius: BorderRadius.circular(8),
                          image: Image.memory(
                            newImageBytes[index],
                            fit: BoxFit.cover,
                          ),
                          onDelete: () => setDialogState(() {
                            newImageBytes.removeAt(index);
                            newImageExts.removeAt(index);
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Add image button
                  if (remainingSlots > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading:
                                      const Icon(Icons.photo_library_rounded),
                                  title: Text('Gallery ($totalImages/$maxImages)'),
                                  onTap: pickImage,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt_rounded),
                                  title: const Text('Camera'),
                                  onTap: () async {
                                    Navigator.pop(ctx);
                                    final picker = ImagePicker();
                                    final p = await picker.pickImage(
                                      source: ImageSource.camera,
                                      maxWidth: 1024,
                                      maxHeight: 1024,
                                      imageQuality: 75,
                                    );
                                    if (p != null) {
                                      final bytes = await p.readAsBytes();
                                      setDialogState(() {
                                        newImageBytes.add(bytes);
                                        newImageExts.add(p.name.split('.').last);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text('Add Images ($totalImages/$maxImages)'),
                    ),
                  const SizedBox(height: 12),
                  // Text field
                  TextField(
                    controller: editController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  editController.dispose();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newContent = editController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);
                  final provider = context.read<BlogProvider>();

                  if (newContent.isEmpty &&
                      existingUrls.isEmpty &&
                      newImageBytes.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Comment cannot be empty'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final success = await provider.updateComment(
                    commentId: comment.id,
                    content: newContent.isNotEmpty ? newContent : '📷',
                    existingImageUrls:
                        existingUrls.isNotEmpty ? existingUrls : null,
                    newImageBytesList:
                        newImageBytes.isNotEmpty ? newImageBytes : null,
                    newImageExts:
                        newImageExts.isNotEmpty ? newImageExts : null,
                  );

                  editController.dispose();
                  if (mounted) {
                    navigator.pop();
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Comment updated'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update comment'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blogProvider = context.watch<BlogProvider>();
    final blog = blogProvider.currentBlog;
    final comments = blogProvider.comments;
    final theme = Theme.of(context);
    final isOwner = blog?.userId == _currentUserId;
    final wide = isDesktop(context);

    if (blogProvider.detailLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (blog == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined,
                  size: 56,
                  color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text('Blog not found'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
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
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              onPressed: () {
                blogProvider.clearCurrentBlog();
                context.go('/');
              },
            ),
          ),
        ),
        actions: [
          if (isOwner) ...[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => context.push('/edit/${blog.id}'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 20, color: Colors.red),
                  onPressed: _handleDelete,
                ),
              ),
            ),
          ],
        ],
      ),
      body: wide
          ? _buildDesktopLayout(blog, comments, theme, blogProvider)
          : _buildMobileLayout(blog, comments, theme, blogProvider),
    );
  }

  // ══════════════════════════════════════════
  //  DESKTOP: Two-column layout
  // ══════════════════════════════════════════
  Widget _buildDesktopLayout(
    dynamic blog,
    List<CommentModel> comments,
    ThemeData theme,
    BlogProvider blogProvider,
  ) {
    return ResponsiveCenter(
      maxWidth: 1100,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Blog content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              child: _buildBlogContent(blog, comments, theme, blogProvider),
            ),
          ),
          const SizedBox(width: 24),
          // RIGHT: Comments
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Comments header
                _buildCommentsHeader(comments, theme),
                const SizedBox(height: 12),
                // Comments list
                Expanded(
                  child: comments.isEmpty
                      ? _buildEmptyComments(theme)
                      : ListView.builder(
                          controller: _commentScrollCtrl,
                          itemCount: comments.length,
                          itemBuilder: (context, index) =>
                              _buildCommentCard(comments[index], theme),
                        ),
                ),
                // Comment input
                _buildCommentInput(theme, blogProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  //  MOBILE: Stacked layout (original)
  // ══════════════════════════════════════════
  Widget _buildMobileLayout(
    dynamic blog,
    List<CommentModel> comments,
    ThemeData theme,
    BlogProvider blogProvider,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            child: ResponsiveCenter(
              maxWidth: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBlogContent(blog, comments, theme, blogProvider),
                        const SizedBox(height: 36),
                        _buildCommentsHeader(comments, theme),
                        const SizedBox(height: 20),
                        if (comments.isEmpty)
                          _buildEmptyComments(theme)
                        else
                          ...comments.map((c) => _buildCommentCard(c, theme)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ResponsiveCenter(
          maxWidth: 700,
          child: _buildCommentInput(theme, blogProvider),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  //  SHARED WIDGETS
  // ══════════════════════════════════════════

  Widget _buildBlogContent(
    dynamic blog,
    List<CommentModel> comments,
    ThemeData theme,
    BlogProvider blogProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          blog.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // Author card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: blog.author?.avatarUrl.isNotEmpty == true
                    ? NetworkImage(blog.author!.avatarUrl)
                    : null,
                child: blog.author?.avatarUrl.isEmpty != false
                    ? Text(
                        blog.author?.initials ?? '?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.author?.nameOrEmail ?? 'Unknown',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(blog.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Content
        SelectableText(
          blog.content,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.8,
            letterSpacing: 0.2,
          ),
        ),

        // Blog images
        if (blog.hasImages) ...[
          const SizedBox(height: 20),
          ImageCarousel(
            imageUrls: blog.imageUrls,
            height: 260,
            borderRadius: BorderRadius.circular(14),
          ),
        ],

        const SizedBox(height: 36),

        // Engagement buttons
        Row(
          children: [
            Expanded(
              child: _HoverEngagement(
                icon: blog.isLikedByCurrentUser
                    ? Icons.favorite
                    : Icons.favorite_outline,
                count: blog.likeCount,
                isActive: blog.isLikedByCurrentUser,
                activeColor: Colors.red,
                onTap: () => blogProvider.toggleLike(blog.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HoverEngagement(
                icon: Icons.chat_bubble_outline_rounded,
                count: comments.length,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsHeader(List<CommentModel> comments, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Comments',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${comments.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyComments(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 36,
              color: theme.colorScheme.onSurface.withOpacity(0.15),
            ),
            const SizedBox(height: 10),
            Text(
              'Start the conversation',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.35),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, ThemeData theme) {
    final isOwner = comment.userId == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: comment.author?.avatarUrl.isNotEmpty == true
                    ? NetworkImage(comment.author!.avatarUrl)
                    : null,
                child: comment.author?.avatarUrl.isEmpty != false
                    ? Text(
                        comment.author?.initials ?? '?',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author?.nameOrEmail ?? 'Unknown',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner) ...[
                // Edit button
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    onPressed: () => _showEditCommentDialog(comment),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    color: Colors.red.withOpacity(0.7),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Comment'),
                          content: const Text('Remove this comment?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context
                                    .read<BlogProvider>()
                                    .deleteComment(comment.id);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (comment.hasImages) ...[
            const SizedBox(height: 12),
            ImageCarousel(
              imageUrls: comment.imageUrls,
              height: 200,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme, BlogProvider blogProvider) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_commentImageBytesList.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: HorizontalScrollableList(
                height: 70,
                spacing: 8,
                children: _commentImageBytesList.asMap().entries.map((entry) {
                  final index = entry.key;
                  return HorizontalImageItem(
                    width: 70,
                    borderRadius: BorderRadius.circular(10),
                    image: Image.memory(
                      _commentImageBytesList[index],
                      fit: BoxFit.cover,
                    ),
                    onDelete: () => setState(() {
                      _commentImageBytesList.removeAt(index);
                      _commentImageExts.removeAt(index);
                    }),
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _pickCommentImage,
                  constraints: const BoxConstraints(
                    minWidth: 42,
                    minHeight: 42,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerTheme.color ??
                          Colors.grey.withOpacity(0.15),
                    ),
                  ),
                  child: TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              blogProvider.actionLoading
                  ? Container(
                      width: 42,
                      height: 42,
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: _submitComment,
                        constraints: const BoxConstraints(
                          minWidth: 42,
                          minHeight: 42,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Engagement button with hover effect
class _HoverEngagement extends StatefulWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _HoverEngagement({
    required this.icon,
    required this.count,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  State<_HoverEngagement> createState() => _HoverEngagementState();
}

class _HoverEngagementState extends State<_HoverEngagement> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (widget.activeColor ?? theme.colorScheme.primary)
                    .withOpacity(0.1)
                : _hovering
                    ? theme.colorScheme.primary.withOpacity(0.08)
                    : theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isActive
                    ? widget.activeColor ?? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.count}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isActive ? widget.activeColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
