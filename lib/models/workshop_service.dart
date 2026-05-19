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
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      approxServiceTime: (json['approx_service_time'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
