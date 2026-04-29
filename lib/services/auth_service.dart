import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

class AuthService {
  static const String _baseUrl = 'https://hamilton-be-dev.vercel.app';
  static const String _authEndpoint = '/api/v1/auth/google';
  static const String _callbackEndpoint = '/api/v1/auth/google/callback';
  static const String _mobileRedirectUri = 'hamiltoncarservice://oauth';
  static const String _tokenKey = 'jwt_token';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;

  /// Get the Google OAuth URL to initiate login
  String getGoogleAuthUrl() {
    final uri = Uri.parse('$_baseUrl$_authEndpoint').replace(
      queryParameters: <String, String>{
        // App redirect is for backend post-auth handoff to mobile.
        // Do NOT overload OAuth's redirect_uri, which some backends pass to Google.
        'app_redirect_uri': _mobileRedirectUri,
      },
    );
    return uri.toString();
  }

  /// Get the callback URL that Google will redirect to
  String getCallbackUrl() {
    return '$_baseUrl$_callbackEndpoint';
  }

  /// Open Google OAuth in system browser
  Future<bool> openGoogleAuthInBrowser() async {
    final url = Uri.parse(getGoogleAuthUrl());

    try {
      // Avoid canLaunchUrl() gate on Android 11+ where package visibility can
      // report false even when a browser exists.
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      return false;
    }
  }

  /// Listen for deep link callback
  Stream<Uri> getDeepLinkStream() {
    return _appLinks.uriLinkStream;
  }

  /// Get initial deep link (when app is opened via deep link)
  Future<Uri?> getInitialDeepLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (e) {
      return null;
    }
  }

  /// Start listening for OAuth callback
  void startListeningForCallback(Function(String?) onCallback) {
    _linkSubscription?.cancel();
    _linkSubscription = getDeepLinkStream().listen((uri) {
      final uriString = uri.toString();
      if (uriString.contains(_callbackEndpoint) ||
          uriString.startsWith(_mobileRedirectUri)) {
        onCallback(uriString);
      }
    });
  }

  /// Stop listening for callback
  void stopListeningForCallback() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get saved JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear stored token (logout)
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Verify token with backend (optional)
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Add your token verification endpoint here if available
      // Example:
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/api/v1/auth/verify'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // return response.statusCode == 200;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract JWT token from callback response
  Future<String?> extractTokenFromCallback(String url) async {
    try {
      // The callback should return JWT token
      // If the token is in the URL, extract it
      final uri = Uri.parse(url);
      
      // Check if token is in query parameters (various possible key names)
      if (uri.queryParameters.containsKey('token')) {
        return uri.queryParameters['token'];
      }
      if (uri.queryParameters.containsKey('access_token')) {
        return uri.queryParameters['access_token'];
      }
      if (uri.queryParameters.containsKey('accessToken')) {
        return uri.queryParameters['accessToken'];
      }
      if (uri.queryParameters.containsKey('jwt')) {
        return uri.queryParameters['jwt'];
      }

      // If not in URL, make a request to the callback endpoint
      // The API returns JSON with access_token
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Try to parse JSON response
        try {
          final jsonResponse = json.decode(response.body);
          // API documentation shows response format: {"access_token": "eyJhbGc..."}
          if (jsonResponse.containsKey('access_token')) {
            return jsonResponse['access_token'];
          }
          if (jsonResponse.containsKey('accessToken')) {
            return jsonResponse['accessToken'];
          }
          if (jsonResponse.containsKey('token')) {
            return jsonResponse['token'];
          }
          if (jsonResponse.containsKey('jwt')) {
            return jsonResponse['jwt'];
          }
        } catch (_) {
          // If not JSON, the token might be the direct response
          return response.body;
        }
      }
      
      return null;
    } catch (e) {
      // Log error for debugging
      // print('Error extracting token: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopListeningForCallback();
  }
}
