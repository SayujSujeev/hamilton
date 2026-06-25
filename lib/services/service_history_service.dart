import '../models/service_history.dart';
import 'api_client.dart';

class ServiceHistoryService {
  ServiceHistoryService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /api/v1/user/service-history — past service records for the user.
  Future<List<ServiceHistory>> fetchServiceHistory() async {
    return _api.handleAuthErrors(() async {
      return await _api.getUserServiceHistory();
    });
  }

  /// GET /api/v1/user/service-history/{id} — bill and line-item details.
  Future<ServiceHistory> fetchServiceHistoryDetail(String id) async {
    return _api.handleAuthErrors(() async {
      return await _api.getUserServiceHistoryDetail(id);
    });
  }
}
