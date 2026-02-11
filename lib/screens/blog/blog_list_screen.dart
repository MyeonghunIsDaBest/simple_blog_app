// lib/screens/blog/blog_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blog_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/hover_card.dart';
import '../../widgets/responsive_layout.dart';

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

    return Scaffold(
      appBar: TopNavBar(
        currentIndex: 0,
        title: 'Blog',
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: _buildBody(blogProvider, theme),
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
        child: ResponsiveCenter(
          maxWidth: 400,
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
        child: ResponsiveCenter(
          maxWidth: 400,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = responsiveGridCount(constraints.maxWidth);

          if (columns == 1) {
            // Mobile: single column list
            return ResponsiveCenter(
              maxWidth: 700,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                itemCount: provider.blogs.length,
                itemBuilder: (context, index) {
                  return _BlogCard(
                    blog: provider.blogs[index],
                    onTap: () =>
                        context.push('/blog/${provider.blogs[index].id}'),
                  );
                },
              ),
            );
          }

          // Tablet/Desktop: grid layout
          return ResponsiveCenter(
            maxWidth: 1200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: columns == 3 ? 0.75 : 0.85,
              ),
              itemCount: provider.blogs.length,
              itemBuilder: (context, index) {
                return _BlogCard(
                  blog: provider.blogs[index],
                  onTap: () =>
                      context.push('/blog/${provider.blogs[index].id}'),
                  isGrid: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  BLOG CARD WITH HOVER SUPPORT
// ═══════════════════════════════════════════
class _BlogCard extends StatelessWidget {
  final BlogModel blog;
  final VoidCallback onTap;
  final bool isGrid;

  const _BlogCard({
    required this.blog,
    required this.onTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return HoverCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author info + menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isGrid ? 16 : 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: blog.author?.avatarUrl.isNotEmpty == true
                      ? NetworkImage(blog.author!.avatarUrl)
                      : null,
                  child: blog.author?.avatarUrl.isEmpty != false
                      ? Text(
                          blog.author?.initials ?? '?',
                          style: TextStyle(
                            fontSize: isGrid ? 9 : 10,
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
                        blog.author?.nameOrEmail ?? 'Unknown',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(blog.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push('/edit/${blog.id}');
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
                  child: Icon(Icons.more_vert,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),

          // Title
          if (blog.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                blog.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: isGrid ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (blog.title.isNotEmpty) const SizedBox(height: 8),

          // Content preview
          if (!isGrid || !blog.hasImages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                blog.preview(maxLength: isGrid ? 80 : 200),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: isGrid ? 2 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          if (!isGrid) const SizedBox(height: 12),

          // Image
          if (blog.hasImages)
            isGrid
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildImage(theme),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildImage(theme),
                  ),

          if (blog.hasImages && !isGrid) const SizedBox(height: 12),

          // Engagement row
          if (!isGrid) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _EngagementButton(
                      icon: blog.isLikedByCurrentUser
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      count: blog.likeCount,
                      isActive: blog.isLikedByCurrentUser,
                      onTap: () =>
                          context.read<BlogProvider>().toggleLike(blog.id),
                    ),
                  ),
                  Expanded(
                    child: _EngagementButton(
                      icon: Icons.chat_bubble_outline,
                      count: blog.commentCount,
                      onTap: onTap,
                    ),
                  ),
                  Expanded(
                    child: _EngagementButton(
                      icon: Icons.share_outlined,
                      onTap: onTap,
                    ),
                  ),
                  Expanded(
                    child: _EngagementButton(
                      icon: Icons.send_outlined,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ] else ...[
            // Compact engagement for grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    blog.isLikedByCurrentUser
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    size: 14,
                    color: blog.isLikedByCurrentUser ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('${blog.likeCount}', style: theme.textTheme.labelSmall),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${blog.commentCount}',
                      style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            blog.imageUrl,
            height: isGrid ? double.infinity : 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: isGrid ? double.infinity : 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
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
        if (blog.imageUrls.length > 1)
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
                    '${blog.imageUrls.length}',
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
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM dd, yyyy').format(date);
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
        final success = await blogProvider.deleteBlog(blog.id);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog deleted successfully')),
          );
        }
      }
    });
  }
}

// Engagement button widget
class _EngagementButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final bool isActive;
  final int count;

  const _EngagementButton({
    required this.icon,
    this.label,
    required this.onTap,
    this.isActive = false,
    this.count = 0,
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
        ? Colors.red
        : _hovering
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: color),
              if (widget.count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '${widget.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else if (widget.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
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
