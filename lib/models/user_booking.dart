/// A single booking belonging to the current user.
///
/// The backend may return one of several shapes:
///
/// 1. Flat: `booking_date`, `slot_timing`, `vehicle_id`, ...
/// 2. Legacy nested (`GET /api/v1/user/slots`):
///    `slot: { slot_timing, slot_id }`, `vehicle: { id, name, ... }`
/// 3. Current (`GET /api/v1/user/booking`):
///    `slot: { id, slot_timing }`,
///    `vehicle_detail: { id, license_plate, odo_reading }`,
///    `json_build_object: { id, service_name }` (single service per row).
///
/// This parser accepts all of them so callers don't need to special-case it.
class UserBooking {
  const UserBooking({
    required this.id,
    required this.bookingDate,
    required this.slotTiming,
    required this.slotId,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleBrand,
    required this.licensePlate,
    required this.odoReading,
    required this.serviceNames,
    required this.description,
    required this.status,
  });

  final String id;
  final DateTime? bookingDate;
  final String slotTiming;
  final String slotId;
  final String vehicleId;
  final String vehicleName;
  final String vehicleBrand;
  final String licensePlate;
  final int? odoReading;
  final List<String> serviceNames;
  final String description;
  final String status;

  bool get hasDate => bookingDate != null;

  /// `true` if the booking starts now or later (date + slot time).
  bool isUpcoming(DateTime now) {
    final d = bookingDate;
    if (d == null) return false;

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day.isAfter(today)) return true;
    if (day.isBefore(today)) return false;

    final parts = slotTiming.trim().split(':');
    if (parts.length < 2) return true;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return true;
    final slotMin = h * 60 + m;
    final nowMin = now.hour * 60 + now.minute;
    return slotMin >= nowMin;
  }

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    final id = _pickString(json, const ['id', 'booking_id', '_id']);

    final bookingDate = _pickDate(json, const [
      'booking_date',
      'date',
      'bookingDate',
    ]);

    final slotRaw = json['slot'];
    final slotObj = slotRaw is Map<String, dynamic> ? slotRaw : null;

    final slotTiming = _pickString(json, const ['slot_timing', 'slotTiming']) .ifEmptyTry(() => slotObj == null
            ? ''
            : _pickString(slotObj, const ['slot_timing', 'slotTiming', 'time']));

    final slotId = _pickString(json, const ['slot_id', 'slotId']).ifEmptyTry(
        () => slotObj == null ? '' : _pickString(slotObj, const ['id', 'slot_id']));

    final vehicleRaw = json['vehicle'];
    final vehicleObj =
        vehicleRaw is Map<String, dynamic> ? vehicleRaw : null;

    final vehicleDetailRaw = json['vehicle_detail'] ?? json['vehicleDetail'];
    final vehicleDetailObj =
        vehicleDetailRaw is Map<String, dynamic> ? vehicleDetailRaw : null;

    final vehicleId = vehicleRaw is String && vehicleRaw.trim().isNotEmpty
        ? vehicleRaw.trim()
        : _pickString(json, const ['vehicle_id', 'vehicleId']).ifEmptyTry(() {
            if (vehicleObj != null) {
              final v = _pickString(vehicleObj, const ['id', '_id']);
              if (v.isNotEmpty) return v;
            }
            if (vehicleDetailObj != null) {
              return _pickString(vehicleDetailObj, const ['id', '_id']);
            }
            return '';
          });

    final vehicleName = vehicleObj != null
        ? _pickString(vehicleObj, const ['name', 'model', 'nickname'])
        : _pickString(json, const ['vehicle_name', 'vehicleName']);

    final vehicleBrand = vehicleObj != null
        ? _pickString(vehicleObj, const ['brand_name', 'brandName', 'brand'])
        : _pickString(json, const ['brand_name', 'brandName']);

    final licensePlate = _pickString(json, const [
      'license_plate',
      'licensePlate',
    ]).ifEmptyTry(() {
      if (vehicleObj != null) {
        final v = _pickString(
          vehicleObj,
          const ['license_plate', 'licensePlate', 'plate'],
        );
        if (v.isNotEmpty) return v;
      }
      if (vehicleDetailObj != null) {
        return _pickString(
          vehicleDetailObj,
          const ['license_plate', 'licensePlate', 'plate'],
        );
      }
      return '';
    });

    final odoReading = _pickInt(json, const ['odo_reading', 'odoReading']) ??
        (vehicleDetailObj == null
            ? null
            : _pickInt(vehicleDetailObj, const ['odo_reading', 'odoReading']));

    final services = _pickServiceNames(json);
    final description = _pickString(json, const ['description', 'note']);
    final status = _pickString(json, const ['status', 'booking_status', 'state']);

    return UserBooking(
      id: id,
      bookingDate: bookingDate,
      slotTiming: slotTiming,
      slotId: slotId,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      vehicleBrand: vehicleBrand,
      licensePlate: licensePlate,
      odoReading: odoReading,
      serviceNames: services,
      description: description,
      status: status,
    );
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static DateTime? _pickDate(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static List<String> _pickServiceNames(Map<String, dynamic> json) {
    final result = <String>[];

    void addFromObject(dynamic raw) {
      if (raw is! Map<String, dynamic>) return;
      final name = _pickString(raw, const ['service_name', 'name', 'title']);
      if (name.isNotEmpty) result.add(name);
    }

    void addFromList(dynamic raw) {
      if (raw is! List) return;
      for (final item in raw) {
        if (item is String && item.trim().isNotEmpty) {
          result.add(item.trim());
        } else if (item is Map<String, dynamic>) {
          final name = _pickString(item, const [
            'service_name',
            'name',
            'title',
          ]);
          if (name.isNotEmpty) result.add(name);
        }
      }
    }

    addFromList(json['service_type']);
    if (result.isEmpty) addFromList(json['services']);
    if (result.isEmpty) addFromList(json['service_types']);
    if (result.isEmpty) addFromList(json['service']);

    // `/api/v1/user/booking` returns the service as a single embedded object
    // under the PostgreSQL builder alias `json_build_object`.
    if (result.isEmpty) {
      final svc = json['json_build_object'];
      if (svc is List) {
        addFromList(svc);
      } else {
        addFromObject(svc);
      }
    }
    return result;
  }
}

extension _IfEmptyTry on String {
  String ifEmptyTry(String Function() fallback) =>
      isEmpty ? fallback() : this;
}
