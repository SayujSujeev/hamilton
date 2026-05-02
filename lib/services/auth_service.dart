import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';

  /// The OAuth 2.0 Web Client ID from Google Cloud Console.
  /// Required so the Android/iOS SDK requests an id_token the backend can verify.
  /// Replace this with your project's actual Web Client ID.
  static const String _webClientId =
      '1045447863619-3l1tg56ubovdlvur04hlh186htiqg5nh.apps.googleusercontent.com';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: _webClientId,
    );
    _googleSignInInitialized = true;
  }

  /// Sign in with Google and return the id_token, or null if cancelled/failed.
  Future<String?> getGoogleIdToken() async {
    try {
      await _ensureGoogleSignInInitialized();

      // Sign out first to always show the account picker.
      await _googleSignIn.signOut();

      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final GoogleSignInAuthentication auth = account.authentication;
      return auth.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw Exception('Google Sign-In failed: ${e.code.name} ${e.description}');
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Sign out of Google.
  Future<void> signOutGoogle() async {
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }

  /// Save JWT token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get saved JWT token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear stored token (logout).
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Best-effort clear for Google account session.
  Future<void> clearGoogleSession() async {
    await _ensureGoogleSignInInitialized();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }
}
