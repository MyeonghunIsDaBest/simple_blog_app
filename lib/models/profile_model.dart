// lib/models/profile_model.dart

class ProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String createdAt;
  final String updatedAt;

  ProfileModel({
    required this.id,
    this.email = '',
    this.displayName = '',
    this.bio = '',
    this.avatarUrl = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  /// Display name, fallback to email username, fallback to 'User'
  String get nameOrEmail {
    if (displayName.isNotEmpty) return displayName;
    if (email.isNotEmpty) return email.split('@').first;
    return 'User';
  }

  /// Initials for avatar placeholder
  String get initials {
    if (displayName.isNotEmpty) {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName[0].toUpperCase();
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// For updating profile (don't send email — it's read-only from auth)
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? email,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return ProfileModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}
