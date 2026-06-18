class ServiceAvailabilityRow {
  const ServiceAvailabilityRow({
    required this.serviceName,
    required this.serviceId,
    required this.totalCapacity,
    required this.availableSlot,
  });

  factory ServiceAvailabilityRow.fromJson(Map<String, dynamic> json) {
    return ServiceAvailabilityRow(
      serviceName: _pickString(json, const [
        'service_name',
        'serviceName',
        'name',
      ]),
      serviceId: _pickString(json, const [
        'service_id',
        'serviceId',
        'id',
      ]),
      totalCapacity: _pickInt(json, const ['total_capacity', 'totalCapacity']) ?? 0,
      availableSlot:
          _pickInt(json, const ['available_slot', 'availableSlot']) ?? 0,
    );
  }

  final String serviceName;
  final String serviceId;
  final int totalCapacity;
  final int availableSlot;

  bool get hasCapacity => availableSlot > 0 && serviceId.isNotEmpty;
}

/// One row from GET /api/v1/slots?date=
class WorkshopSlot {
  const WorkshopSlot({
    required this.slotTiming,
    required this.slotId,
    required this.serviceAvailability,
  });

  factory WorkshopSlot.fromJson(Map<String, dynamic> json) {
    final rawList = json['service_availability'] ?? json['serviceAvailability'];
    final list = rawList is List
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(ServiceAvailabilityRow.fromJson)
            .toList()
        : <ServiceAvailabilityRow>[];

    return WorkshopSlot(
      slotTiming: _pickString(json, const ['slot_timing', 'slotTiming', 'time']),
      slotId: _pickString(json, const ['slot_id', 'slotId', 'id']),
      serviceAvailability: list,
    );
  }

  final String slotTiming;
  final String slotId;
  final List<ServiceAvailabilityRow> serviceAvailability;

  bool capacityForServiceId(String serviceId) {
    for (final row in serviceAvailability) {
      if (row.serviceId == serviceId) return row.hasCapacity;
    }
    return false;
  }
}

String _pickString(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    if (v is num) return v.toString();
  }
  return '';
}

int? _pickInt(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
  }
  return null;
}
