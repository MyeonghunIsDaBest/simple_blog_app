import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/profile_model.dart';

class AuthService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;

  Session? get currentSession => supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data =
          await supabase.from('profiles').select().eq('id', userId).single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<ProfileModel> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final data = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<String> uploadAvatar(String userId, File imageFile) async {
    final ext = p.extension(imageFile.path);
    final fileName = '${const Uuid().v4()}$ext';
    final filePath = '$userId/$fileName';

    await supabase.storage.from('avatars').upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return supabase.storage.from('avatars').getPublicUrl(filePath);
  }
}
