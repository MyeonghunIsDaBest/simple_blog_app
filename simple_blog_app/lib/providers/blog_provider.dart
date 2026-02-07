import 'dart:io';
import 'package:flutter/material.dart';

import '../models/blog_model.dart';
import '../providers/auth_provider.dart';
import '../services/blog_service.dart';

enum BlogStatus { initial, loading, loaded, error }

class BlogProvider extends ChangeNotifier {
  final BlogService _blogService = BlogService();
  AuthProvider? _authProvider;

  BlogStatus _status = BlogStatus.initial;
  List<BlogModel> _blogs = [];
  BlogModel? _selectedBlog;
  List<Map<String, dynamic>> _comments = [];
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  BlogStatus get status => _status;
  List<BlogModel> get blogs => _blogs;
  BlogModel? get selectedBlog => _selectedBlog;
  List<Map<String, dynamic>> get comments => _comments;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> loadBlogs({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 0;
        _hasMore = true;
        _status = BlogStatus.loading;
      } else if (_isLoadingMore || !_hasMore) {
        return;
      } else {
        _isLoadingMore = true;
      }
      notifyListeners();

      final newBlogs = await _blogService.getBlogs(page: _currentPage);

      if (refresh) {
        _blogs = newBlogs;
      } else {
        _blogs.addAll(newBlogs);
      }

      _hasMore = newBlogs.length >= BlogService.pageSize;
      _currentPage++;
      _status = BlogStatus.loaded;
      _isLoadingMore = false;
      notifyListeners();
    } catch (_) {
      _status = BlogStatus.error;
      _errorMessage = 'Failed to load blogs';
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadBlogById(String id) async {
    try {
      _status = BlogStatus.loading;
      notifyListeners();

      _selectedBlog = await _blogService.getBlogById(id);
      await loadComments(id);

      _status = BlogStatus.loaded;
      notifyListeners();
    } catch (_) {
      _status = BlogStatus.error;
      _errorMessage = 'Failed to load blog';
      notifyListeners();
    }
  }

  Future<bool> createBlog({
    required String title,
    required String content,
    File? imageFile,
  }) async {
    if (_authProvider?.user == null) return false;

    try {
      _status = BlogStatus.loading;
      notifyListeners();

      final blog = await _blogService.createBlog(
        userId: _authProvider!.user!.id,
        title: title,
        content: content,
        imageFile: imageFile,
      );

      _blogs.insert(0, blog);
      _status = BlogStatus.loaded;
      notifyListeners();
      return true;
    } catch (_) {
      _status = BlogStatus.error;
      _errorMessage = 'Failed to create blog';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBlog({
    required String id,
    required String title,
    required String content,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      _status = BlogStatus.loading;
      notifyListeners();

      final updatedBlog = await _blogService.updateBlog(
        id: id,
        title: title,
        content: content,
        imageFile: imageFile,
        existingImageUrl: existingImageUrl,
      );

      final index = _blogs.indexWhere((b) => b.id == id);
      if (index != -1) {
        _blogs[index] = updatedBlog;
      }
      if (_selectedBlog?.id == id) {
        _selectedBlog = updatedBlog;
      }

      _status = BlogStatus.loaded;
      notifyListeners();
      return true;
    } catch (_) {
      _status = BlogStatus.error;
      _errorMessage = 'Failed to update blog';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBlog(String id) async {
    try {
      await _blogService.deleteBlog(id);
      _blogs.removeWhere((b) => b.id == id);
      if (_selectedBlog?.id == id) {
        _selectedBlog = null;
      }
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to delete blog';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadComments(String blogId) async {
    try {
      _comments = await _blogService.getComments(blogId);
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Failed to load comments';
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String blogId,
    required String content,
    File? imageFile,
  }) async {
    if (_authProvider?.user == null) return false;

    try {
      final comment = await _blogService.createComment(
        blogId: blogId,
        userId: _authProvider!.user!.id,
        content: content,
        imageFile: imageFile,
      );

      _comments.add(comment);

      if (_selectedBlog != null && _selectedBlog!.id == blogId) {
        _selectedBlog = _selectedBlog!.copyWith(
          commentCount: _selectedBlog!.commentCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add comment';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment(String commentId, String blogId) async {
    try {
      await _blogService.deleteComment(commentId);
      _comments.removeWhere((c) => c['id'] == commentId);

      if (_selectedBlog != null && _selectedBlog!.id == blogId) {
        _selectedBlog = _selectedBlog!.copyWith(
          commentCount: _selectedBlog!.commentCount - 1,
        );
      }

      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to delete comment';
      notifyListeners();
      return false;
    }
  }

  Future<List<BlogModel>> searchBlogs(String query) async {
    try {
      return await _blogService.searchBlogs(query);
    } catch (_) {
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedBlog() {
    _selectedBlog = null;
    _comments = [];
    notifyListeners();
  }
}
