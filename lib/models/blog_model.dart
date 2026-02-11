// lib/models/blog_model.dart

import 'profile_model.dart';

class BlogModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String createdAt;
  final String updatedAt;
  final ProfileModel? author;
  final int commentCount;
  final int likeCount;
  final bool isLikedByCurrentUser;

  BlogModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.author,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
  });

  /// Backward-compatible: returns first URL or empty string
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// Whether this blog has any images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Number of images
  int get imageCount => imageUrls.length;

  factory BlogModel.fromJson(Map<String, dynamic> json) {
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

    return BlogModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrls: imageUrls,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      author: author,
      commentCount: json['comment_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool? ?? false,
    );
  }

  /// For inserting into Supabase
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
    };
  }

  /// For updating in Supabase
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  BlogModel copyWith({
    String? title,
    String? content,
    List<String>? imageUrls,
    ProfileModel? author,
    int? commentCount,
    int? likeCount,
    bool? isLikedByCurrentUser,
  }) {
    return BlogModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      author: author ?? this.author,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  String get excerpt {
    if (content.length <= 150) return content;
    return '${content.substring(0, 150)}...';
  }

  String preview({int maxLength = 150}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}
