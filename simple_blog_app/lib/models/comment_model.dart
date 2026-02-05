// ============================================================================
// COMMENT MODEL
// ============================================================================
//
// This represents a comment on a blog post.
// Stored in the 'comments' table in Supabase.
//
// A comment has:
//   - content (the text)
//   - blogId (which blog post it belongs to)
//   - authorId (who wrote the comment)
//   - createdAt (when it was written)
//
// ============================================================================

class CommentModel {
  final String id;
  final String content;         // The comment text
  final String blogId;          // Which blog this comment is on
  final String authorId;        // Who wrote it
  final DateTime createdAt;

  // Extra: author info (from join)
  final String? authorUsername;
  final String? authorAvatarUrl;

  CommentModel({
    required this.id,
    required this.content,
    required this.blogId,
    required this.authorId,
    required this.createdAt,
    this.authorUsername,
    this.authorAvatarUrl,
  });

  // Turn Supabase data into a CommentModel
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      blogId: json['blog_id'] as String,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: profile?['username'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  // Turn CommentModel into data for Supabase (for creating)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'blog_id': blogId,
      'author_id': authorId,
    };
  }
}
