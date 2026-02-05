// ============================================================================
// PROFILE MODEL
// ============================================================================
//
// This represents extra user info (username, bio, avatar)
// stored in the 'profiles' table in Supabase.
//
// Why separate from UserModel?
// - UserModel = Supabase Auth data (email, password stuff)
// - ProfileModel = Your custom data (username, bio, avatar)
//
// It's like:
//   UserModel = your login credentials
//   ProfileModel = your social media profile
//
// ============================================================================

class ProfileModel {
  final String id;             // Same ID as the user (linked!)
  final String username;       // Unique username (@john)
  final String? displayName;   // Display name (can be null)
  final String? bio;           // About me text (can be null)
  final String? avatarUrl;     // Profile picture URL (can be null)
  final DateTime createdAt;
  final DateTime updatedAt;

  // Why some have '?' (nullable)?
  // When a user first signs up, they might not have a bio or avatar yet.
  // The '?' says "this field is optional, it CAN be empty/null"

  ProfileModel({
    required this.id,
    required this.username,
    this.displayName,    // No 'required' = optional
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Turn Supabase data into a ProfileModel
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,   // as String? = might be null
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Turn ProfileModel into data for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // copyWith - create a copy with some fields changed
  //
  // WHY? Models are 'final' (can't change fields).
  // So to "update" a profile, we create a NEW one with changes.
  //
  // Example:
  //   final updated = profile.copyWith(bio: 'New bio!');
  //   // Everything else stays the same, only bio changes
  ProfileModel copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id,                                // Keep same
      username: username ?? this.username,    // Use new or keep old
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,                  // Keep same
      updatedAt: DateTime.now(),             // Update timestamp
    );
  }
}
