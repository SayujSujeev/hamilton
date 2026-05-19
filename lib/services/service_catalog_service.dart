import '../models/workshop_service.dart';
import 'api_client.dart';

class ServiceCatalogService {
  ServiceCatalogService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /api/v1/service — active workshop service types.
  Future<List<WorkshopService>> fetchServices() async {
    return _api.handleAuthErrors(() async {
      final response = await _api.get('/api/v1/service');
      final json = _api.parseJson(response);
      final raw = json['data'];
      if (raw is! List<dynamic>) return [];

      return raw
          .whereType<Map<String, dynamic>>()
          .map(WorkshopService.fromJson)
          .where((s) => s.isActive)
          .toList();
    });
  }
}
