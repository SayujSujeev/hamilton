import '../booking/slot_booking_logic.dart';
import '../models/user_booking.dart';
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

  /// Fetch all bookings belonging to the current user via
  /// `GET /api/v1/user/slots`. Tolerates the API returning the list under
  /// `data`, `data.bookings`, or `data.slots`.
  Future<List<UserBooking>> fetchUserBookings() async {
    final response = await _api.get('/api/v1/user/slots');
    final map = _api.parseJson(response);

    final raw = map['data'];
    List<dynamic> rows = const [];
    if (raw is List) {
      rows = raw;
    } else if (raw is Map<String, dynamic>) {
      for (final key in const ['bookings', 'slots', 'data', 'items']) {
        final v = raw[key];
        if (v is List) {
          rows = v;
          break;
        }
      }
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(UserBooking.fromJson)
        .toList();
  }
}
