class CommentModel {
  final String id;
  final String blogId;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.blogId,
    required this.userId,
    required this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      blogId: json['blog_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
