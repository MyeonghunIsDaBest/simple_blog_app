import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  ProfileModel? _profile;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  ProfileModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  String? get currentUserId => _user?.id;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    if (_user != null) {
      _status = AuthStatus.authenticated;
      _loadProfile();
    } else {
      _status = AuthStatus.unauthenticated;
    }

    _authService.authStateChanges.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        _user = data.session!.user;
        _status = AuthStatus.authenticated;
        _loadProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    try {
      _profile = await _authService.getProfile(_user!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        await _loadProfile();
        notifyListeners();
        return true;
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        await _loadProfile();
        notifyListeners();
        return true;
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _profile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    Uint8List? avatarBytes,
    String? avatarExt,
  }) async {
    if (_user == null) return false;

    try {
      _status = AuthStatus.loading;
      notifyListeners();

      String? avatarUrl;
      if (avatarBytes != null) {
        avatarUrl = await _authService.uploadAvatar(_user!.id, avatarBytes, avatarExt ?? 'jpg');
      }

      _profile = await _authService.updateProfile(
        userId: _user!.id,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (_) {
      _status = AuthStatus.authenticated;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
