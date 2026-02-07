import 'profile_model.dart';

class CommentModel {
  final String id;
  final String blogId;
  final String userId;
  final String content;
  final String imageUrl;
  final String createdAt;
  final ProfileModel? author;

  CommentModel({
    required this.id,
    required this.blogId,
    required this.userId,
    required this.content,
    this.imageUrl = '',
    this.createdAt = '',
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? author;
    if (json['profiles'] != null && json['profiles'] is Map<String, dynamic>) {
      author = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return CommentModel(
      id: json['id'] as String,
      blogId: json['blog_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      author: author,
    );
  }
}
