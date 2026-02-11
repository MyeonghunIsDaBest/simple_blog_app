// lib/models/comment_model.dart

import 'profile_model.dart';

class CommentModel {
  final String id;
  final String blogId;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final String createdAt;
  final ProfileModel? author;

  CommentModel({
    required this.id,
    required this.blogId,
    required this.userId,
    required this.content,
    this.imageUrls = const [],
    this.createdAt = '',
    this.author,
  });

  /// Backward-compatible: first image URL or empty
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// Whether this comment has any images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Number of images
  int get imageCount => imageUrls.length;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse author profile
    ProfileModel? author;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      author = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    // Parse image_urls (JSONB array from Supabase)
    List<String> imageUrls = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      imageUrls = (json['image_urls'] as List)
          .map((e) => e.toString())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return CommentModel(
      id: json['id'] as String? ?? '',
      blogId: json['blog_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrls: imageUrls,
      createdAt: json['created_at'] as String? ?? '',
      author: author,
    );
  }

  /// For inserting into Supabase
  Map<String, dynamic> toInsertJson() {
    return {
      'blog_id': blogId,
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls,
    };
  }
}
