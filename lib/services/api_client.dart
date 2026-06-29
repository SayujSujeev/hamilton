import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/service_history.dart';

class ApiClient {
  static const String baseUrl = 'https://hamilton-be-dev.onrender.com/api/v1';
  final AuthService _authService = AuthService();

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (kDebugMode) {
      if (token == null) {
        debugPrint('[ApiClient] No token in storage — request will be UNauthenticated');
      } else {
        final preview = token.length > 16 ? '${token.substring(0, 16)}…' : token;
        debugPrint('[ApiClient] Attaching token (len=${token.length}): $preview');
      }
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generic GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final headers = await _getHeaders();
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: {...uri.queryParameters, ...queryParameters},
      );
    }

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

  /// Generic PATCH request
  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.patch(
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

  /// Pulls a list of JSON objects from common API `data` shapes.
  static List<Map<String, dynamic>> extractApiListRows(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      for (final key in const [
        'bookings',
        'booking',
        'slots',
        'data',
        'items',
        'rows',
        'results',
        'user_booking',
        'user_bookings',
      ]) {
        final value = raw[key];
        if (value is List) {
          final rows = value.whereType<Map<String, dynamic>>().toList();
          if (rows.isNotEmpty) return rows;
        }
        if (value is Map<String, dynamic>) {
          final nested = extractApiListRows(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }
    return const [];
  }

  /// Authenticate with a Google id_token obtained from the native SDK.
  /// Calls native auth endpoint and returns backend JWT.
  Future<String?> authenticateWithGoogleToken(String idToken) async {
    final endpoints = <String>[
      '/auth/google/app',
      '/auth/google/android',
    ];

    String? lastError;
    for (final endpoint in endpoints) {
      final uri = Uri.parse('$baseUrl$endpoint');
      try {
        final response = await http.post(
          uri,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'id_token': idToken}),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body) as Map<String, dynamic>;

          final topLevelToken = data['access_token'];
          if (topLevelToken is String && topLevelToken.isNotEmpty) {
            return topLevelToken;
          }

          final nestedData = data['data'];
          if (nestedData is Map<String, dynamic>) {
            final nestedToken = nestedData['access_token'];
            if (nestedToken is String && nestedToken.isNotEmpty) {
              return nestedToken;
            }
          }

          throw Exception(
            'Auth succeeded on $endpoint but access_token missing in response: ${response.body}',
          );
        }

        lastError =
            'Auth failed on $endpoint (${response.statusCode}): ${response.body}';
      } catch (e) {
        lastError = 'Auth request error on $endpoint: $e';
      }
    }

    throw Exception(lastError ?? 'Google authentication failed');
  }

  /// Authenticate with a Firebase Phone Auth id_token.
  /// Calls the backend phone-auth endpoint and returns the backend JWT.
  Future<String> authenticateWithPhoneToken(String firebaseIdToken) async {
    final uri = Uri.parse('$baseUrl/auth/phone-login');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // Try top-level access_token first, then nested under 'data'.
        final topLevel = data['access_token'];
        if (topLevel is String && topLevel.isNotEmpty) return topLevel;

        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          final nestedToken = nested['access_token'];
          if (nestedToken is String && nestedToken.isNotEmpty) {
            return nestedToken;
          }
        }

        throw Exception(
          'Auth succeeded but access_token missing: ${response.body}',
        );
      }

      throw Exception(_formatAuthFailure(response));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Phone authentication error: $e');
    }
  }

  String _formatAuthFailure(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final serverError = data['error']?.toString();
      if (response.statusCode >= 500) {
        return 'Server error during login (${response.statusCode}). '
            'The backend team needs to fix phone-login. '
            '${serverError ?? response.body}';
      }
      return 'Phone auth failed (${response.statusCode}): '
          '${serverError ?? response.body}';
    } catch (_) {
      return 'Phone auth failed (${response.statusCode}): ${response.body}';
    }
  }

  /// GET /api/v1/user — returns the full user object under response['data'].
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/user');
    return parseJson(response);
  }

  /// GET /api/v1/user — returns the UserModel object.
  Future<UserModel> getCurrentUserModel() async {
    final response = await get('/user');
    final json = parseJson(response);
    final userData = json['data'];
    if (userData is! Map<String, dynamic>) {
      throw Exception('User profile missing in response: ${response.body}');
    }
    return UserModel.fromJson(userData);
  }

  /// PATCH /api/v1/user — updates profile fields.
  /// Accepted fields: firstname, lastname, gender, dob, image_url,
  ///                  mobile_no, whatsapp_no, role_id, note, address
  Future<Map<String, dynamic>> updateCurrentUser(Map<String, dynamic> data) async {
    final response = await patch('/user', body: data);
    return parseJson(response);
  }

  /// PATCH /api/v1/user — updates profile fields using UserModel.
  Future<UserModel> updateCurrentUserModel(Map<String, dynamic> data) async {
    final response = await patch('/user', body: data);
    final json = parseJson(response);
    final userData = json['data'];
    if (userData is! Map<String, dynamic>) {
      throw Exception('User profile missing in response: ${response.body}');
    }
    return UserModel.fromJson(userData);
  }

  /// GET /api/v1/user/vehicle — returns the list of vehicles for the current user.
  Future<List<VehicleModel>> getUserVehicles() async {
    final response = await get('/user/vehicle');
    final json = parseJson(response);
    if (kDebugMode) {
      debugPrint('[ApiClient] /user/vehicle raw data: ${json['data']}');
    }

    final raw = json['data'];
    List<dynamic> vehiclesData = const [];
    if (raw is List) {
      vehiclesData = raw;
    } else if (raw is Map<String, dynamic>) {
      for (final key in const ['vehicles', 'vehicle', 'data', 'items']) {
        final value = raw[key];
        if (value is List) {
          vehiclesData = value;
          break;
        }
      }
    }

    return vehiclesData
        .whereType<Map<String, dynamic>>()
        .map(VehicleModel.fromJson)
        .toList();
  }

  /// GET /api/v1/user/vehicle/{id} — returns a single vehicle's full detail.
  Future<VehicleModel> getUserVehicleById(String userVehicleId) async {
    final response = await get('/user/vehicle/$userVehicleId');
    final json = parseJson(response);
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Vehicle missing in response: ${response.body}');
    }
    return VehicleModel.fromJson(data);
  }

  /// GET /api/v1/user/slots — returns available service slots for the current user.
  Future<Map<String, dynamic>> getUserSlots() async {
    final response = await get('/user/slots');
    return parseJson(response);
  }

  /// GET /api/v1/user/booking — returns bookings for the current user.
  ///
  /// Response shape:
  /// ```
  /// {
  ///   "message": "success",
  ///   "data": [
  ///     {
  ///       "id": "...",
  ///       "booking_date": "2026-05-13",
  ///       "slot": { "id": "...", "slot_timing": "08:00" },
  ///       ...
  ///     }
  ///   ]
  /// }
  /// ```
  Future<Map<String, dynamic>> getUserBookings() async {
    final response = await get('/user/booking');
    return parseJson(response);
  }

  /// GET /api/v1/user/service-history — returns past service records.
  Future<List<ServiceHistory>> getUserServiceHistory() async {
    final response = await get('/user/service-history');
    final json = parseJson(response);
    if (kDebugMode) {
      debugPrint('[ApiClient] /user/service-history raw data: ${json['data']}');
    }

    final raw = json['data'];
    List<dynamic> rows = const [];
    if (raw is List) {
      rows = raw;
    } else if (raw is Map<String, dynamic>) {
      for (final key in const ['history', 'service_history', 'data', 'items']) {
        final value = raw[key];
        if (value is List) {
          rows = value;
          break;
        }
      }
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(ServiceHistory.fromJson)
        .toList();
  }

  /// GET /api/v1/user/service-history/{id} — full bill and service details.
  Future<ServiceHistory> getUserServiceHistoryDetail(String id) async {
    final response = await get('/user/service-history/$id');
    final json = parseJson(response);
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ServiceHistory.fromJson(data);
    }
    throw Exception('Service history detail missing in response: ${response.body}');
  }

  /// GET /api/v1/invoice/{id} — invoice / bill data.
  Future<ServiceHistory> getInvoice(String id) async {
    final response = await get('/invoice/$id');
    final json = parseJson(response);
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return ServiceHistory.fromJson(data);
    }
    throw Exception('Invoice missing in response: ${response.body}');
  }

  /// GET /api/v1/invoice/{id}/download — invoice PDF or download URL.
  Future<http.Response> downloadInvoice(String id) async {
    final token = await _authService.getToken();
    final uri = Uri.parse('$baseUrl/invoice/$id/download');
    final headers = <String, String>{
      'Accept': 'application/pdf, application/octet-stream, application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      return await http.get(uri, headers: headers);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/v1/brand — returns a paginated list of all brands.
  /// [type] can be 'vehicle' or 'spare' to filter brand types.
  Future<List<Map<String, dynamic>>> getBrands({
    int offset = 0,
    int limit = 50,
    String? type,
  }) async {
    final queryParameters = <String, String>{
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    final uri = Uri.parse('$baseUrl/brand').replace(
      queryParameters: queryParameters,
    );
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] GET $uri');
      debugPrint('[ApiClient] hasAuthHeader=${headers.containsKey('Authorization')}');
    }
    try {
      final response = await http.get(uri, headers: headers);
      if (kDebugMode) {
        debugPrint('[ApiClient] /brand -> ${response.statusCode}: ${response.body}');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['data']?['brand'] as List?) ?? const [];
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/v1/brand/detail/{id} — returns details for a single brand.
  Future<Map<String, dynamic>> getBrandById(String id) async {
    final uri = Uri.parse('$baseUrl/brand/detail/$id');
    final headers = await _getHeaders();
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/v1/brand/search — searches brands by name.
  /// [type] can be 'vehicle' or 'spare' to filter brand types.
  Future<List<Map<String, dynamic>>> searchBrands(
    String name, {
    String? type,
  }) async {
    final queryParams = <String, String>{'name': name};
    if (type != null) {
      queryParams['type'] = type;
    }
    final uri = Uri.parse('$baseUrl/brand/search').replace(
      queryParameters: queryParams,
    );
    final headers = await _getHeaders();
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? const [];
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/v1/vehicle/list — returns vehicles for a given brand.
  Future<List<Map<String, dynamic>>> getVehiclesByBrandId(String brandId) async {
    final uri = Uri.parse('$baseUrl/vehicle/list').replace(
      queryParameters: {'brandId': brandId},
    );
    final headers = await _getHeaders();
    if (kDebugMode) {
      debugPrint('[ApiClient] GET $uri');
      debugPrint('[ApiClient] hasAuthHeader=${headers.containsKey('Authorization')}');
    }
    try {
      final response = await http.get(uri, headers: headers);
      if (kDebugMode) {
        debugPrint('[ApiClient] /vehicle/list -> ${response.statusCode}: ${response.body}');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? const [];
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// GET /api/v1/vehicle/search — searches vehicles by brand and model name (requires auth).
  Future<List<Map<String, dynamic>>> searchVehicles({
    required String brandId,
    required String name,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/vehicle/search').replace(
      queryParameters: {'brandId': brandId, 'name': name},
    );
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? const [];
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST /api/v1/user/vehicle — adds a vehicle to the user's profile.
  Future<Map<String, dynamic>> addUserVehicle({
    required String name,
    required String vehicleId,
    required String licensePlate,
    int? odoReading,
    String? note,
    int? manufacturedYear,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'vehicle_id': vehicleId,
      'license_plate': licensePlate,
      if (odoReading != null) 'odo_reading': odoReading,
      if (note != null && note.isNotEmpty) 'note': note,
      if (manufacturedYear != null) 'manufactured_year': manufacturedYear,
    };
    final response = await post('/user/vehicle', body: body);
    return parseJson(response);
  }

  /// PATCH /api/v1/user/vehicle/{id} — updates an existing vehicle on the user's profile.
  Future<Map<String, dynamic>> updateUserVehicle({
    required String userVehicleId,
    String? name,
    String? vehicleId,
    String? licensePlate,
    int? odoReading,
    String? note,
    int? manufacturedYear,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (odoReading != null) 'odo_reading': odoReading,
      if (note != null) 'note': note,
      if (manufacturedYear != null) 'manufactured_year': manufacturedYear,
    };
    final response = await patch('/user/vehicle/$userVehicleId', body: body);
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
