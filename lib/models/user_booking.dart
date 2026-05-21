/// A single booking belonging to the current user.
///
/// The backend (`GET /api/v1/user/slots`) may return either a flat shape
/// (`booking_date`, `slot_timing`, `vehicle_id`, ...) or a nested shape
/// (`slot: { slot_timing, slot_id }`, `vehicle: { id, name, ... }`).
/// This parser accepts both so callers don't need to special-case it.
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
    final vehicleObj = vehicleRaw is Map<String, dynamic> ? vehicleRaw : null;

    final vehicleId = _pickString(json, const ['vehicle_id', 'vehicleId']).ifEmptyTry(
        () => vehicleObj == null ? '' : _pickString(vehicleObj, const ['id', '_id']));

    final vehicleName = vehicleObj != null
        ? _pickString(vehicleObj, const ['name', 'model', 'nickname'])
        : _pickString(json, const ['vehicle_name', 'vehicleName']);

    final vehicleBrand = vehicleObj != null
        ? _pickString(vehicleObj, const ['brand_name', 'brandName', 'brand'])
        : _pickString(json, const ['brand_name', 'brandName']);

    final licensePlate = vehicleObj != null
        ? _pickString(vehicleObj, const ['license_plate', 'licensePlate', 'plate'])
        : _pickString(json, const ['license_plate', 'licensePlate']);

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

  static List<String> _pickServiceNames(Map<String, dynamic> json) {
    final result = <String>[];

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
    return result;
  }
}

extension _IfEmptyTry on String {
  String ifEmptyTry(String Function() fallback) =>
      isEmpty ? fallback() : this;
}
