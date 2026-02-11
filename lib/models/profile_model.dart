class ProfileModel {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String createdAt;
  final String updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    this.displayName = '',
    this.avatarUrl = '',
    this.bio = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  String get displayNameOrEmail =>
      displayName.isNotEmpty ? displayName : email.split('@').first;

  String get nameOrEmail =>
      displayName.isNotEmpty ? displayName : email.split('@').first;

  String get initials {
    final name = displayName.isNotEmpty ? displayName : email;
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
