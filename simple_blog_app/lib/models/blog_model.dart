// ============================================================================
// BLOG MODEL
// ============================================================================
//
// This represents a blog post from the 'blogs' table in Supabase.
//
// A blog has:
//   - title and content (the actual post)
//   - imageUrl (optional cover image)
//   - authorId (who wrote it)
//   - timestamps (when created/updated)
//
// ============================================================================

class BlogModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;      // Optional - not every blog has an image
  final String authorId;        // Links to the user who wrote it
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extra: author profile info (joined from profiles table)
  // When we fetch blogs, we can also grab the author's username/avatar
  final String? authorUsername;
  final String? authorAvatarUrl;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.authorUsername,
    this.authorAvatarUrl,
  });

  // Turn Supabase data into a BlogModel
  //
  // Supabase can return JOINED data like:
  // {
  //   'id': '...', 'title': '...', 'content': '...',
  //   'profiles': { 'username': 'john', 'avatar_url': '...' }
  // }
  //
  // The 'profiles' part is the author's info (from a join/select)
  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // Check if author profile data was included in the response
    final profile = json['profiles'] as Map<String, dynamic>?;

    return BlogModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorUsername: profile?['username'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  // Turn BlogModel into data for Supabase (for creating/updating)
  // Note: we DON'T include id (Supabase generates it)
  //       we DON'T include author profile (that's separate)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'author_id': authorId,
    };
  }

  // Create a copy with some fields changed
  BlogModel copyWith({
    String? title,
    String? content,
    String? imageUrl,
  }) {
    return BlogModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
    );
  }
}
