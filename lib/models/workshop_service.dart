/// Workshop service type from GET /api/v1/service.
class WorkshopService {
  const WorkshopService({
    required this.id,
    required this.name,
    required this.capacity,
    required this.approxServiceTime,
    required this.isActive,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int capacity;
  final int approxServiceTime;
  final bool isActive;
  final String? description;
  final String? imageUrl;

  factory WorkshopService.fromJson(Map<String, dynamic> json) {
    return WorkshopService(
      id: _pickString(json, const ['id', 'service_id', 'serviceId']),
      name: _pickString(json, const ['name', 'service_name', 'title']),
      capacity: _pickInt(json, const ['capacity']) ?? 1,
      approxServiceTime:
          _pickInt(json, const ['approx_service_time', 'approxServiceTime']) ??
              1,
      isActive: _pickBool(json, const ['is_active', 'isActive']) ?? true,
      description: _pickNullableString(json, const ['description']),
      imageUrl: _pickNullableString(json, const ['image_url', 'imageUrl']),
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

  static String? _pickNullableString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
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

  static bool? _pickBool(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is bool) return v;
      if (v == 1 || v == '1' || v == 'true') return true;
      if (v == 0 || v == '0' || v == 'false') return false;
    }
    return null;
  }
}
