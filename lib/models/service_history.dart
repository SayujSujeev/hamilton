/// One row from GET /api/v1/user/service-history.
class ServiceHistory {
  const ServiceHistory({
    required this.id,
    required this.serviceDate,
    required this.grandTotal,
    required this.vehicleId,
    required this.odoReading,
    required this.vehicleName,
  });

  final String id;
  final DateTime? serviceDate;
  final double grandTotal;
  final String vehicleId;
  final int odoReading;
  final String vehicleName;

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    final rawDate = json['service_date'] ?? json['serviceDate'];
    DateTime? serviceDate;
    if (rawDate is String && rawDate.isNotEmpty) {
      serviceDate = DateTime.tryParse(rawDate);
    }

    return ServiceHistory(
      id: _pickString(json, const ['id', 'service_history_id']),
      serviceDate: serviceDate,
      grandTotal: _pickDouble(json, const ['grand_total', 'grandTotal']) ?? 0,
      vehicleId: _pickString(json, const ['vehicle_id', 'vehicleId']),
      odoReading: _pickInt(json, const ['odo_reading', 'odoReading']) ?? 0,
      vehicleName: _pickString(json, const ['vehicle_name', 'vehicleName', 'name']),
    );
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return '';
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
    }
    return null;
  }

  static double? _pickDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
    }
    return null;
  }
}
