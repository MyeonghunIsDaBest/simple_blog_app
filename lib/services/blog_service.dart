// lib/services/blog_service.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blog_model.dart';
import '../models/comment_model.dart';

class BlogService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // ══════════════════════════════════════════
  //  IMAGE UPLOAD HELPERS
  // ══════════════════════════════════════════

  /// Upload multiple images to a storage bucket and return their public URLs
  Future<List<String>> _uploadImages({
    required String bucket,
    required String folder,
    required List<Uint8List> imageBytesList,
    required List<String> imageExts,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < imageBytesList.length; i++) {
      final ext = imageExts[i].toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
      final path = '$folder/$fileName';

      await _client.storage.from(bucket).uploadBinary(
            path,
            imageBytesList[i],
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      urls.add(publicUrl);
    }

    return urls;
  }

  /// Upload blog images
  Future<List<String>> uploadBlogImages({
    required List<Uint8List> imageBytesList,
    required List<String> imageExts,
  }) async {
    return _uploadImages(
      bucket: 'blog-images',
      folder: '$_userId/${DateTime.now().millisecondsSinceEpoch}',
      imageBytesList: imageBytesList,
      imageExts: imageExts,
    );
  }

  /// Upload comment images
  Future<List<String>> uploadCommentImages({
    required List<Uint8List> imageBytesList,
    required List<String> imageExts,
  }) async {
    return _uploadImages(
      bucket: 'comment-images',
      folder: '$_userId/${DateTime.now().millisecondsSinceEpoch}',
      imageBytesList: imageBytesList,
      imageExts: imageExts,
    );
  }

  // ══════════════════════════════════════════
  //  BLOG CRUD
  // ══════════════════════════════════════════

  /// Fetch all blogs with author profiles, comment count, like count
  Future<List<BlogModel>> fetchBlogs() async {
    final userId = _userId;

    final response = await _client.from('blogs').select('''
          *,
          profiles!blogs_user_id_fkey(*),
          comment_count:comments(count),
          like_count:likes(count),
          is_liked:likes!left(user_id)
        ''').order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;

    return data.map((json) {
      final map = Map<String, dynamic>.from(json);

      // Parse comment count
      if (map['comment_count'] is List &&
          (map['comment_count'] as List).isNotEmpty) {
        map['comment_count'] = (map['comment_count'] as List)[0]['count'] ?? 0;
      } else {
        map['comment_count'] = 0;
      }

      // Parse like count
      if (map['like_count'] is List && (map['like_count'] as List).isNotEmpty) {
        map['like_count'] = (map['like_count'] as List)[0]['count'] ?? 0;
      } else {
        map['like_count'] = 0;
      }

      // Parse is_liked_by_current_user
      bool isLiked = false;
      if (userId != null && map['is_liked'] is List) {
        isLiked =
            (map['is_liked'] as List).any((like) => like['user_id'] == userId);
      }
      map['is_liked_by_current_user'] = isLiked;
      map.remove('is_liked');

      return BlogModel.fromJson(map);
    }).toList();
  }

  /// Fetch single blog with details
  Future<BlogModel?> fetchBlogById(String id) async {
    final userId = _userId;

    final response = await _client.from('blogs').select('''
          *,
          profiles!blogs_user_id_fkey(*),
          comment_count:comments(count),
          like_count:likes(count),
          is_liked:likes!left(user_id)
        ''').eq('id', id).maybeSingle();

    if (response == null) return null;

    final map = Map<String, dynamic>.from(response);

    // Parse comment count
    if (map['comment_count'] is List &&
        (map['comment_count'] as List).isNotEmpty) {
      map['comment_count'] = (map['comment_count'] as List)[0]['count'] ?? 0;
    } else {
      map['comment_count'] = 0;
    }

    // Parse like count
    if (map['like_count'] is List && (map['like_count'] as List).isNotEmpty) {
      map['like_count'] = (map['like_count'] as List)[0]['count'] ?? 0;
    } else {
      map['like_count'] = 0;
    }

    // Parse is_liked
    bool isLiked = false;
    if (userId != null && map['is_liked'] is List) {
      isLiked =
          (map['is_liked'] as List).any((like) => like['user_id'] == userId);
    }
    map['is_liked_by_current_user'] = isLiked;
    map.remove('is_liked');

    return BlogModel.fromJson(map);
  }

  /// Create a new blog with multiple images
  Future<BlogModel?> createBlog({
    required String title,
    required String content,
    List<Uint8List>? imageBytesList,
    List<String>? imageExts,
  }) async {
    List<String> imageUrls = [];

    // Upload images if provided
    if (imageBytesList != null &&
        imageExts != null &&
        imageBytesList.isNotEmpty) {
      imageUrls = await uploadBlogImages(
        imageBytesList: imageBytesList,
        imageExts: imageExts,
      );
    }

    final response = await _client.from('blogs').insert({
      'user_id': _userId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
    }).select('''
          *,
          profiles!blogs_user_id_fkey(*)
        ''').single();

    final map = Map<String, dynamic>.from(response);
    map['comment_count'] = 0;
    map['like_count'] = 0;
    map['is_liked_by_current_user'] = false;

    return BlogModel.fromJson(map);
  }

  /// Update blog with support for keeping existing + adding new images
  Future<BlogModel?> updateBlog({
    required String id,
    required String title,
    required String content,
    List<String>? existingImageUrls,
    List<Uint8List>? newImageBytesList,
    List<String>? newImageExts,
  }) async {
    // Start with existing images that user kept
    List<String> finalImageUrls = existingImageUrls ?? [];

    // Upload and append new images
    if (newImageBytesList != null &&
        newImageExts != null &&
        newImageBytesList.isNotEmpty) {
      final newUrls = await uploadBlogImages(
        imageBytesList: newImageBytesList,
        imageExts: newImageExts,
      );
      finalImageUrls = [...finalImageUrls, ...newUrls];
    }

    final response = await _client
        .from('blogs')
        .update({
          'title': title,
          'content': content,
          'image_urls': finalImageUrls,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select('''
          *,
          profiles!blogs_user_id_fkey(*)
        ''')
        .single();

    return BlogModel.fromJson(Map<String, dynamic>.from(response));
  }

  /// Delete a blog
  Future<void> deleteBlog(String id) async {
    await _client.from('blogs').delete().eq('id', id);
  }

  /// Search blogs by title or content
  Future<List<BlogModel>> searchBlogs(String query) async {
    final response = await _client
        .from('blogs')
        .select('''
          *,
          profiles!blogs_user_id_fkey(*)
        ''')
        .or('title.ilike.%$query%,content.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['comment_count'] = 0;
      map['like_count'] = 0;
      map['is_liked_by_current_user'] = false;
      return BlogModel.fromJson(map);
    }).toList();
  }

  // ══════════════════════════════════════════
  //  COMMENTS
  // ══════════════════════════════════════════

  /// Fetch comments for a blog
  Future<List<CommentModel>> fetchComments(String blogId) async {
    final response = await _client.from('comments').select('''
          *,
          profiles!comments_user_id_fkey(*)
        ''').eq('blog_id', blogId).order('created_at', ascending: true);

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => CommentModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Add a comment with multiple images
  Future<CommentModel?> addComment({
    required String blogId,
    required String content,
    List<Uint8List>? imageBytesList,
    List<String>? imageExts,
  }) async {
    List<String> imageUrls = [];

    // Upload images if provided
    if (imageBytesList != null &&
        imageExts != null &&
        imageBytesList.isNotEmpty) {
      imageUrls = await uploadCommentImages(
        imageBytesList: imageBytesList,
        imageExts: imageExts,
      );
    }

    final response = await _client.from('comments').insert({
      'blog_id': blogId,
      'user_id': _userId,
      'content': content,
      'image_urls': imageUrls,
    }).select('''
          *,
          profiles!comments_user_id_fkey(*)
        ''').single();

    return CommentModel.fromJson(Map<String, dynamic>.from(response));
  }

  /// Delete a comment
  Future<void> deleteComment(String id) async {
    await _client.from('comments').delete().eq('id', id);
  }

  // ══════════════════════════════════════════
  //  LIKES
  // ══════════════════════════════════════════

  /// Toggle like on a blog
  Future<bool> toggleLike(String blogId) async {
    final userId = _userId;
    if (userId == null) return false;

    // Check if already liked
    final existing = await _client
        .from('likes')
        .select()
        .eq('blog_id', blogId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client
          .from('likes')
          .delete()
          .eq('blog_id', blogId)
          .eq('user_id', userId);
      return false; // now unliked
    } else {
      // Like
      await _client.from('likes').insert({
        'blog_id': blogId,
        'user_id': userId,
      });
      return true; // now liked
    }
  }
}
