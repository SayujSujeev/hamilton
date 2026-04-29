import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl = 'https://hamilton-be-dev.vercel.app';
  final AuthService _authService = AuthService();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generic GET request
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.get(uri, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic POST request
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.delete(uri, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check if response is successful
  bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Parse JSON response
  Map<String, dynamic> parseJson(http.Response response) {
    if (!isSuccessful(response)) {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Example: Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await get('/api/v1/user/profile');
    return parseJson(response);
  }

  /// Get current user (self)
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/api/v1/user');
    return parseJson(response);
  }

  /// Example: Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await put('/api/v1/user/profile', body: data);
    return parseJson(response);
  }

  /// Handle authentication errors
  Future<T> handleAuthErrors<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        // Token expired or invalid
        await _authService.clearToken();
        throw Exception('Authentication expired. Please login again.');
      }
      rethrow;
    }
  }
}
