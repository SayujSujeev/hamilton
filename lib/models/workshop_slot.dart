class ServiceAvailabilityRow {
  const ServiceAvailabilityRow({
    required this.serviceName,
    required this.serviceId,
    required this.totalCapacity,
    required this.availableSlot,
  });

  factory ServiceAvailabilityRow.fromJson(Map<String, dynamic> json) {
    return ServiceAvailabilityRow(
      serviceName: (json['service_name'] ?? '') as String,
      serviceId: (json['service_id'] ?? '') as String,
      totalCapacity: (json['total_capacity'] as num?)?.toInt() ?? 0,
      availableSlot: (json['available_slot'] as num?)?.toInt() ?? 0,
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
    final rawList = json['service_availability'];
    final list = rawList is List
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(ServiceAvailabilityRow.fromJson)
            .toList()
        : <ServiceAvailabilityRow>[];

    return WorkshopSlot(
      slotTiming: (json['slot_timing'] ?? '') as String,
      slotId: (json['slot_id'] ?? '') as String,
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
