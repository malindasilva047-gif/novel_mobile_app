import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthSession {
  const AuthSession({
    this.id,
    required this.method,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  final int? id;
  final String method;
  final String email;
  final String displayName;
  final String? photoUrl;

  bool get isGoogle => method == 'google';
}

class AuthService {
  AuthService({required ApiService apiService, GoogleSignIn? googleSignIn})
    : _apiService = apiService,
      _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  static const String _methodKey = 'auth_method';
  static const String _idKey = 'auth_id';
  static const String _emailKey = 'auth_email';
  static const String _displayNameKey = 'auth_display_name';
  static const String _photoUrlKey = 'auth_photo_url';

  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;

  Future<AuthSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final method = prefs.getString(_methodKey);
    if (method == null || method.isEmpty) {
      return null;
    }

    if (method == 'google') {
      final user = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      if (user != null) {
        final session = AuthSession(
          id: prefs.getInt(_idKey),
          method: 'google',
          email: user.email,
          displayName: user.displayName ?? user.email,
          photoUrl: user.photoUrl,
        );
        await _persistSession(session);
        return session;
      }
    }

    final email = prefs.getString(_emailKey) ?? '';
    final displayName = prefs.getString(_displayNameKey) ?? email;
    final photoUrl = prefs.getString(_photoUrlKey);
    if (email.isEmpty) {
      return null;
    }

    return AuthSession(
      id: prefs.getInt(_idKey),
      method: method,
      email: email,
      displayName: displayName.isEmpty ? email : displayName,
      photoUrl: photoUrl,
    );
  }

  Future<AuthSession> signInWithGoogle() async {
    final user = await _googleSignIn.signIn();
    if (user == null) {
      throw Exception('Google sign-in was cancelled.');
    }
    final auth = await user.authentication;
    final payload = await _apiService.verifyGoogleSignIn(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    final session = AuthSession(
      id: payload['id'] as int?,
      method: 'google',
      email: payload['email']?.toString() ?? user.email,
      displayName:
          payload['display_name']?.toString() ?? user.displayName ?? user.email,
      photoUrl: payload['photo_url']?.toString() ?? user.photoUrl,
    );
    await _persistSession(session);
    return session;
  }

  Future<AuthSession> signInWithEmail(String email) async {
    final normalized = email.trim();
    final session = AuthSession(
      id: null,
      method: 'email',
      email: normalized,
      displayName: normalized.split('@').first,
    );
    await _persistSession(session);
    return session;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_methodKey);
    await prefs.remove(_idKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_photoUrlKey);
  }

  Future<void> _persistSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_methodKey, session.method);
    if (session.id != null) {
      await prefs.setInt(_idKey, session.id!);
    } else {
      await prefs.remove(_idKey);
    }
    await prefs.setString(_emailKey, session.email);
    await prefs.setString(_displayNameKey, session.displayName);
    if (session.photoUrl != null && session.photoUrl!.isNotEmpty) {
      await prefs.setString(_photoUrlKey, session.photoUrl!);
    } else {
      await prefs.remove(_photoUrlKey);
    }
  }
}