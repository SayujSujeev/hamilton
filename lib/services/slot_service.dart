import 'package:flutter/foundation.dart';

import '../booking/slot_booking_logic.dart';
import '../models/user_booking.dart';
import '../models/workshop_slot.dart';
import 'api_client.dart';

class SlotService {
  SlotService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<WorkshopSlot>> fetchSlotsForDate(DateTime date) async {
    return _api.handleAuthErrors(() async {
      final ymd = SlotBookingLogic.formatDateApi(date);
      final response =
          await _api.get('/slots', queryParameters: {'date': ymd});
      final map = _api.parseJson(response);
      final raw = map['data'];
      if (kDebugMode) {
        debugPrint('[SlotService] /slots?date=$ymd -> ${raw.runtimeType}');
      }
      if (raw is! List<dynamic>) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(WorkshopSlot.fromJson)
          .where((slot) => slot.slotId.isNotEmpty)
          .toList();
    });
  }

  /// Returns created booking id when present.
  Future<String?> bookSlot({
    required String bookingDate,
    required String slotId,
    required String vehicleUserRowId,
    required List<String> serviceTypeIds,
    String description = '',
  }) async {
    return _api.handleAuthErrors(() async {
      final response = await _api.post(
        '/slots',
        body: {
          'booking_date': bookingDate,
          'slot': slotId,
          'description': description,
          'vehicle': vehicleUserRowId,
          'service_type': serviceTypeIds,
        },
      );
      final map = _api.parseJson(response);
      return _extractBookingId(map['data']);
    });
  }

  /// PATCH `/api/v1/slots/{id}` — update an existing booked slot.
  Future<Map<String, dynamic>> updateBookedSlot({
    required String bookingId,
    String? bookingDate,
    String? slotId,
    String? description,
    String? vehicleUserRowId,
    String? serviceTypeId,
    String? status,
    bool? isActive,
  }) async {
    return _api.handleAuthErrors(() async {
      final body = <String, dynamic>{
        if (bookingDate != null) 'booking_date': bookingDate,
        if (slotId != null) 'slot': slotId,
        if (description != null) 'description': description,
        if (vehicleUserRowId != null) 'vehicle': vehicleUserRowId,
        if (serviceTypeId != null) 'service_type': serviceTypeId,
        if (status != null) 'status': status,
        if (isActive != null) 'is_active': isActive,
      };
      final response = await _api.patch('/slots/$bookingId', body: body);
      return _api.parseJson(response);
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await updateBookedSlot(bookingId: bookingId, status: 'cancelled');
  }

  Future<List<UserBooking>> fetchUserBookings() async {
    return _api.handleAuthErrors(() async {
      final response = await _api.get('/user/booking');
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

      if (kDebugMode) {
        debugPrint('[SlotService] /user/booking -> ${rows.length} rows');
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(UserBooking.fromJson)
          .toList();
    });
  }

  static String? _extractBookingId(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final id = raw['id'] ?? raw['booking_id'];
      if (id is String && id.isNotEmpty) return id;
    }
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map<String, dynamic>) {
        final id = first['id'] ?? first['booking_id'];
        if (id is String && id.isNotEmpty) return id;
      }
    }
    return null;
  }
}
