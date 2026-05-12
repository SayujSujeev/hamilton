import '../booking/slot_booking_logic.dart';
import '../models/workshop_slot.dart';
import 'api_client.dart';

class SlotService {
  SlotService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<WorkshopSlot>> fetchSlotsForDate(DateTime date) async {
    final ymd = SlotBookingLogic.formatDateApi(date);
    final response =
        await _api.get('/api/v1/slots', queryParameters: {'date': ymd});
    final map = _api.parseJson(response);
    final raw = map['data'];
    if (raw is! List<dynamic>) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(WorkshopSlot.fromJson)
        .toList();
  }

  /// Returns created booking id when present.
  Future<String?> bookSlot({
    required String bookingDate,
    required String slotId,
    required String vehicleUserRowId,
    required List<String> serviceTypeIds,
    String description = '',
  }) async {
    final response = await _api.post(
      '/api/v1/slots',
      body: {
        'booking_date': bookingDate,
        'slot': slotId,
        'description': description,
        'vehicle': vehicleUserRowId,
        'service_type': serviceTypeIds,
      },
    );
    final map = _api.parseJson(response);
    final raw = map['data'];
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        final id = first['id'];
        if (id is String && id.isNotEmpty) return id;
      }
    }
    return null;
  }
}
