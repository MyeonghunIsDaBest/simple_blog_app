import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blog_provider.dart';
import '../../providers/theme_provider.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  List<BlogModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().loadBlogs(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<BlogProvider>().loadBlogs();
    }
  }

  Future<void> _onSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _searching = false;
        _searchResults = [];
      });
      return;
    }
    setState(() => _searching = true);
    final results = await context.read<BlogProvider>().searchBlogs(q.trim());
    if (mounted) setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search blogs...',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                onChanged: _onSearch,
              )
            : const Text('Blog'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  _searchResults = [];
                }
              });
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, tp, _) {
              return IconButton(
                icon: Icon(tp.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => tp.toggleTheme(),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'profile') context.push('/profile');
              if (v == 'logout') {
                context.read<AuthProvider>().signOut();
                context.go('/login');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<BlogProvider>(
        builder: (context, bp, _) {
          final items = _searching ? _searchResults : bp.blogs;

          if (bp.status == BlogStatus.loading && items.isEmpty) {
            return _buildShimmer();
          }

          if (bp.status == BlogStatus.error && items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(bp.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bp.loadBlogs(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(_searching ? 'No results found' : 'No blogs yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _searching
                        ? 'Try a different search'
                        : 'Create the first blog!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bp.loadBlogs(refresh: true),
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: items.length + (bp.hasMore && !_searching ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _BlogCard(blog: items[i]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-blog'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: double.infinity, height: 150, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                      width: double.infinity, height: 20, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 16, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogModel blog;
  const _BlogCard({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/blog/${blog.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imageUrl != null)
              CachedNetworkImage(
                imageUrl: blog.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheHeight: 360,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.excerpt,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: blog.author?.avatarUrl != null
                            ? CachedNetworkImageProvider(
                                blog.author!.avatarUrl!)
                            : null,
                        child: blog.author?.avatarUrl == null
                            ? Text(
                                (blog.author?.displayNameOrEmail ?? '?')[0]
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.author?.displayNameOrEmail ?? 'Unknown',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (blog.createdAt != null)
                              Text(
                                timeago.format(blog.createdAt!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.comment_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${blog.commentCount}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
