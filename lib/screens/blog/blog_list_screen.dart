// lib/screens/blog/blog_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/feed_column.dart';
import '../../widgets/sticky_header.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BlogProvider>().loadBlogs();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogProvider = context.watch<BlogProvider>();
    final theme = Theme.of(context);

    return AppShell(
      currentIndex: 0,
      body: FeedColumn(
        child: Column(
          children: [
            const StickyHeader(title: 'For you'),
            Expanded(child: _buildBody(blogProvider, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BlogProvider provider, ThemeData theme) {
    if (provider.blogsLoading) {
      return Center(
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
              'Loading blogs...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null && provider.blogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => provider.loadBlogs(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.blogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No blogs yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share something amazing!',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.push('/create'),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Write a Blog'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBlogs(refresh: true),
      color: theme.colorScheme.primary,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: provider.blogs.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: theme.dividerTheme.color,
        ),
        itemBuilder: (context, index) {
          return _FeedBlogCard(
            blog: provider.blogs[index],
            onTap: () => context.push('/blog/${provider.blogs[index].id}'),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  TWITTER-STYLE FEED BLOG CARD
// ═══════════════════════════════════════════
class _FeedBlogCard extends StatefulWidget {
  final BlogModel blog;
  final VoidCallback onTap;

  const _FeedBlogCard({required this.blog, required this.onTap});

  @override
  State<_FeedBlogCard> createState() => _FeedBlogCardState();
}

class _FeedBlogCardState extends State<_FeedBlogCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blog = widget.blog;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovering
              ? theme.colorScheme.onSurface.withOpacity(0.02)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar column
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: blog.author?.avatarUrl.isNotEmpty == true
                    ? NetworkImage(blog.author!.avatarUrl)
                    : null,
                child: blog.author?.avatarUrl.isEmpty != false
                    ? Text(
                        blog.author?.initials ?? '?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author + time + menu
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            blog.author?.nameOrEmail ?? 'Unknown',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '  ·  ${_formatDate(blog.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.45),
                          ),
                        ),
                        const Spacer(),
                        _buildPopupMenu(context, theme),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Blog title (prominent)
                    if (blog.title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          blog.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Content preview
                    Text(
                      blog.preview(maxLength: 150),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Image
                    if (blog.hasImages) ...[
                      const SizedBox(height: 10),
                      _buildImage(theme),
                    ],

                    const SizedBox(height: 10),

                    // Engagement row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _EngagementButton(
                          icon: Icons.chat_bubble_outline,
                          count: blog.commentCount,
                          hoverColor: Colors.blue,
                          onTap: widget.onTap,
                        ),
                        _EngagementButton(
                          icon: Icons.repeat_rounded,
                          hoverColor: Colors.green,
                          onTap: () {},
                        ),
                        _EngagementButton(
                          icon: blog.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          count: blog.likeCount,
                          isActive: blog.isLikedByCurrentUser,
                          activeColor: Colors.red,
                          hoverColor: Colors.red,
                          onTap: () =>
                              context.read<BlogProvider>().toggleLike(blog.id),
                        ),
                        _EngagementButton(
                          icon: Icons.share_outlined,
                          hoverColor: Colors.blue,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          context.push('/edit/${widget.blog.id}');
        } else if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(Icons.more_horiz_rounded,
          size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.blog.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.15),
                ),
              ),
            ),
          ),
        ),
        if (widget.blog.imageUrls.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_rounded,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.blog.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Blog'),
        content: const Text('Are you sure you want to delete this blog?'),
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
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        final blogProvider = context.read<BlogProvider>();
        final success = await blogProvider.deleteBlog(widget.blog.id);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog deleted successfully')),
          );
        }
      }
    });
  }
}

// ═══════════════════════════════════════════
//  ENGAGEMENT BUTTON WITH HOVER COLORS
// ═══════════════════════════════════════════
class _EngagementButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final int count;
  final Color? activeColor;
  final Color hoverColor;

  const _EngagementButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.count = 0,
    this.activeColor,
    this.hoverColor = Colors.blue,
  });

  @override
  State<_EngagementButton> createState() => _EngagementButtonState();
}

class _EngagementButtonState extends State<_EngagementButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isActive
        ? (widget.activeColor ?? widget.hoverColor)
        : _hovering
            ? widget.hoverColor
            : theme.colorScheme.onSurface.withOpacity(0.5);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovering
                ? widget.hoverColor.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: color),
              if (widget.count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
