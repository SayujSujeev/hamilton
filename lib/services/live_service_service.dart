import 'package:flutter/foundation.dart';
import '../models/live_service.dart';
import 'api_client.dart';

class LiveServiceService {
  LiveServiceService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /api/v1/user/live-service
  /// Returns the list of vehicles currently being serviced.
  Future<List<LiveService>> fetchLiveServices() async {
    return _api.handleAuthErrors(() async {
      final response = await _api.get('/user/live-service');
      final map = _api.parseJson(response);

      if (kDebugMode) {
        debugPrint('[LiveServiceService] /user/live-service -> ${map['data']}');
      }

      final raw = map['data'];
      final rows = ApiClient.extractApiListRows(raw);
      if (rows.isEmpty && raw is Map<String, dynamic>) {
        rows.addAll(
          ApiClient.extractApiListRows(
            raw['live_service'] ?? raw['live_services'] ?? raw['services'],
          ),
        );
      }

      if (kDebugMode && rows.isNotEmpty) {
        debugPrint('[LiveServiceService] first row keys: ${rows.first.keys}');
      }

      return rows.map(LiveService.fromJson).toList();
    });
  }
}
