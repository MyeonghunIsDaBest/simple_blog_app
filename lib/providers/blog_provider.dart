// lib/providers/blog_provider.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../services/blog_service.dart';

class BlogProvider with ChangeNotifier {
  final BlogService _service = BlogService();
  AuthProvider? _authProvider;

  // ══════════════════════════════════════════
  //  AUTH SYNC
  // ══════════════════════════════════════════

  /// Called by ChangeNotifierProxyProvider when AuthProvider updates
  void updateAuth(AuthProvider auth) {
    _authProvider = auth;

    // Auto-load blogs when user logs in
    if (auth.isAuthenticated && _blogs.isEmpty && !_blogsLoading) {
      loadBlogs();
    }

    // Clear data when user logs out
    if (!auth.isAuthenticated && _blogs.isNotEmpty) {
      _blogs = [];
      _currentBlog = null;
      _comments = [];
      _error = null;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════
  //  STATE
  // ══════════════════════════════════════════
  List<BlogModel> _blogs = [];
  BlogModel? _currentBlog;
  List<CommentModel> _comments = [];
  bool _blogsLoading = false;
  bool _detailLoading = false;
  bool _actionLoading = false;
  String? _error;

  // ══════════════════════════════════════════
  //  GETTERS
  // ══════════════════════════════════════════
  List<BlogModel> get blogs => _blogs;
  BlogModel? get currentBlog => _currentBlog;
  List<CommentModel> get comments => _comments;
  bool get blogsLoading => _blogsLoading;
  bool get detailLoading => _detailLoading;
  bool get actionLoading => _actionLoading;
  String? get error => _error;
  bool get isAuthenticated => _authProvider?.isAuthenticated ?? false;

  // ══════════════════════════════════════════
  //  BLOG OPERATIONS
  // ══════════════════════════════════════════

  /// Load all blogs
  Future<void> loadBlogs({bool refresh = false}) async {
    if (_blogsLoading) return;

    _blogsLoading = true;
    _error = null;
    if (refresh || _blogs.isEmpty) notifyListeners();

    try {
      _blogs = await _service.fetchBlogs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _blogsLoading = false;
      notifyListeners();
    }
  }

  /// Load single blog detail + comments
  Future<void> loadBlogDetail(String id) async {
    _detailLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchBlogById(id),
        _service.fetchComments(id),
      ]);

      _currentBlog = results[0] as BlogModel?;
      _comments = results[1] as List<CommentModel>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  /// Create blog with multiple images
  Future<bool> createBlog({
    required String title,
    required String content,
    List<Uint8List>? imageBytesList,
    List<String>? imageExts,
  }) async {
    _actionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBlog = await _service.createBlog(
        title: title,
        content: content,
        imageBytesList: imageBytesList,
        imageExts: imageExts,
      );

      if (newBlog != null) {
        _blogs.insert(0, newBlog);
      }

      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update blog with existing + new images
  Future<bool> updateBlog({
    required String id,
    required String title,
    required String content,
    List<String>? existingImageUrls,
    List<Uint8List>? newImageBytesList,
    List<String>? newImageExts,
  }) async {
    _actionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateBlog(
        id: id,
        title: title,
        content: content,
        existingImageUrls: existingImageUrls,
        newImageBytesList: newImageBytesList,
        newImageExts: newImageExts,
      );

      if (updated != null) {
        // Update in blog list
        final index = _blogs.indexWhere((b) => b.id == id);
        if (index != -1) {
          _blogs[index] = updated.copyWith(
            commentCount: _blogs[index].commentCount,
            likeCount: _blogs[index].likeCount,
            isLikedByCurrentUser: _blogs[index].isLikedByCurrentUser,
          );
        }
        _currentBlog = updated;
      }

      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete blog
  Future<bool> deleteBlog(String id) async {
    _actionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteBlog(id);
      _blogs.removeWhere((b) => b.id == id);
      if (_currentBlog?.id == id) _currentBlog = null;

      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search blogs
  Future<List<BlogModel>> searchBlogs(String query) async {
    try {
      return await _service.searchBlogs(query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Clear current blog (when navigating away)
  void clearCurrentBlog() {
    _currentBlog = null;
    _comments = [];
    notifyListeners();
  }

  // ══════════════════════════════════════════
  //  COMMENT OPERATIONS
  // ══════════════════════════════════════════

  /// Add comment with multiple images
  Future<bool> addComment({
    required String blogId,
    required String content,
    List<Uint8List>? imageBytesList,
    List<String>? imageExts,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final newComment = await _service.addComment(
        blogId: blogId,
        content: content,
        imageBytesList: imageBytesList,
        imageExts: imageExts,
      );

      if (newComment != null) {
        _comments.add(newComment);

        // Update comment count in current blog
        if (_currentBlog?.id == blogId) {
          _currentBlog = _currentBlog!.copyWith(
            commentCount: _comments.length,
          );
        }

        // Update in blog list too
        final index = _blogs.indexWhere((b) => b.id == blogId);
        if (index != -1) {
          _blogs[index] = _blogs[index].copyWith(
            commentCount: _blogs[index].commentCount + 1,
          );
        }
      }

      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final comment = _comments.firstWhere((c) => c.id == commentId);
      await _service.deleteComment(commentId);
      _comments.removeWhere((c) => c.id == commentId);

      // Update comment counts
      if (_currentBlog != null) {
        _currentBlog = _currentBlog!.copyWith(
          commentCount: _comments.length,
        );

        final index = _blogs.indexWhere((b) => b.id == comment.blogId);
        if (index != -1) {
          _blogs[index] = _blogs[index].copyWith(
            commentCount: (_blogs[index].commentCount - 1).clamp(0, 999),
          );
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ══════════════════════════════════════════
  //  LIKE OPERATIONS
  // ══════════════════════════════════════════

  /// Toggle like on a blog
  Future<void> toggleLike(String blogId) async {
    try {
      final isNowLiked = await _service.toggleLike(blogId);

      // Update current blog
      if (_currentBlog?.id == blogId) {
        _currentBlog = _currentBlog!.copyWith(
          isLikedByCurrentUser: isNowLiked,
          likeCount: _currentBlog!.likeCount + (isNowLiked ? 1 : -1),
        );
      }

      // Update in blog list
      final index = _blogs.indexWhere((b) => b.id == blogId);
      if (index != -1) {
        _blogs[index] = _blogs[index].copyWith(
          isLikedByCurrentUser: isNowLiked,
          likeCount: _blogs[index].likeCount + (isNowLiked ? 1 : -1),
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}
