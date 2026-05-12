import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

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

  /// Authenticate with a Google id_token obtained from the native SDK.
  /// Calls native auth endpoint and returns backend JWT.
  Future<String?> authenticateWithGoogleToken(String idToken) async {
    final endpoints = <String>[
      '/api/v1/auth/google/app',
      '/api/v1/auth/google/android',
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

  /// GET /api/v1/user — returns the full user object under response['data'].
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/api/v1/user');
    return parseJson(response);
  }

  /// GET /api/v1/user — returns the UserModel object.
  Future<UserModel> getCurrentUserModel() async {
    final response = await get('/api/v1/user');
    final json = parseJson(response);
    final userData = json['data'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// PATCH /api/v1/user — updates profile fields.
  /// Accepted fields: firstname, lastname, gender, dob, image_url,
  ///                  mobile_no, whatsapp_no, role_id, note, address
  Future<Map<String, dynamic>> updateCurrentUser(Map<String, dynamic> data) async {
    final response = await patch('/api/v1/user', body: data);
    return parseJson(response);
  }

  /// PATCH /api/v1/user — updates profile fields using UserModel.
  Future<UserModel> updateCurrentUserModel(Map<String, dynamic> data) async {
    final response = await patch('/api/v1/user', body: data);
    final json = parseJson(response);
    final userData = json['data'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// GET /api/v1/user/vehicle — returns the list of vehicles for the current user.
  Future<List<VehicleModel>> getUserVehicles() async {
    final response = await get('/api/v1/user/vehicle');
    final json = parseJson(response);
    final vehiclesData = json['data'] as List<dynamic>;
    return vehiclesData
        .map((vehicleJson) => VehicleModel.fromJson(vehicleJson as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/user/vehicle/{id} — returns a single vehicle's full detail.
  Future<VehicleModel> getUserVehicleById(String userVehicleId) async {
    final response = await get('/api/v1/user/vehicle/$userVehicleId');
    final json = parseJson(response);
    return VehicleModel.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// GET /api/v1/user/slots — returns available service slots for the current user.
  Future<Map<String, dynamic>> getUserSlots() async {
    final response = await get('/api/v1/user/slots');
    return parseJson(response);
  }

  /// GET /api/v1/brand — returns a paginated list of all brands.
  Future<List<Map<String, dynamic>>> getBrands({
    int offset = 0,
    int limit = 50,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/brand').replace(
      queryParameters: {
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );
    final headers = await _getHeaders();
    try {
      final response = await http.get(uri, headers: headers);
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
    final response = await get('/api/v1/brand/detail/$id');
    final data = parseJson(response);
    return data['data'] as Map<String, dynamic>;
  }

  /// GET /api/v1/brand/search — searches brands by name.
  /// [type] can be 'vehicle' or 'spare' to filter brand types.
  Future<List<Map<String, dynamic>>> searchBrands(
    String name, {
    String? type,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{'name': name};
    if (type != null) {
      queryParams['type'] = type;
    }
    final uri = Uri.parse('$baseUrl/api/v1/brand/search').replace(
      queryParameters: queryParams,
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

  /// GET /api/v1/vehicle/list — returns vehicles for a given brand (no auth required).
  Future<List<Map<String, dynamic>>> getVehiclesByBrandId(String brandId) async {
    final uri = Uri.parse('$baseUrl/api/v1/vehicle/list').replace(
      queryParameters: {'brandId': brandId},
    );
    try {
      final response = await http.get(uri, headers: const {'Accept': 'application/json'});
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
    final uri = Uri.parse('$baseUrl/api/v1/vehicle/search').replace(
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
    final response = await post('/api/v1/user/vehicle', body: body);
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
    final response = await patch('/api/v1/user/vehicle/$userVehicleId', body: body);
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
