import 'profile_model.dart';

class BlogModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;
  final ProfileModel? author;
  final int commentCount;

  BlogModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.author,
    this.commentCount = 0,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? author;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      author = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return BlogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      author: author,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl.isNotEmpty ? imageUrl : null,
    };
  }

  BlogModel copyWith({
    String? title,
    String? content,
    String? imageUrl,
    ProfileModel? author,
    int? commentCount,
  }) {
    return BlogModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      author: author ?? this.author,
      commentCount: commentCount ?? this.commentCount,
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
