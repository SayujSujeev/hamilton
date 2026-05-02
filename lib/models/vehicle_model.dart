class ServiceDetails {
  final DateTime? lastServiceDate;
  final String? avrgServiceDuration;
  final String? lastServiceDuration;

  const ServiceDetails({
    this.lastServiceDate,
    this.avrgServiceDuration,
    this.lastServiceDuration,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    final rawDate = json['last_service_date'];
    return ServiceDetails(
      lastServiceDate: rawDate is String ? DateTime.tryParse(rawDate) : null,
      avrgServiceDuration: json['avrg_service_duration'] as String?,
      lastServiceDuration: json['last_service_duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (lastServiceDate != null)
          'last_service_date': lastServiceDate!.toIso8601String(),
        if (avrgServiceDuration != null)
          'avrg_service_duration': avrgServiceDuration,
        if (lastServiceDuration != null)
          'last_service_duration': lastServiceDuration,
      };
}

class VehicleModel {
  final String id;
  final String name;
  final String? nickname;
  final String brandName;
  final String? imageUrl;
  /// Raw note value — the API may return a String, a Map, or null.
  final dynamic note;
  final String licensePlate;
  final String manufacturedYear;
  final int odoReading;
  final String mVehicleId;
  final String tUserId;
  final ServiceDetails? serviceDetails;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const VehicleModel({
    required this.id,
    required this.name,
    this.nickname,
    required this.brandName,
    this.imageUrl,
    this.note,
    required this.licensePlate,
    required this.manufacturedYear,
    required this.odoReading,
    required this.mVehicleId,
    required this.tUserId,
    this.serviceDetails,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
  });

  /// Returns the note as a plain string, or null if absent / not a string.
  String? get noteText => note is String && (note as String).isNotEmpty
      ? note as String
      : null;

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'];
    final rawUpdatedAt = json['updated_at'];
    final rawServiceDetails = json['service_details'];

    return VehicleModel(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      nickname: json['nickname'] as String?,
      brandName: (json['brand_name'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      note: json['note'],
      licensePlate: (json['license_plate'] ?? '') as String,
      manufacturedYear: (json['manufactured_year'] ?? '') as String,
      odoReading: (json['odo_reading'] as num?)?.toInt() ?? 0,
      mVehicleId: (json['m_vehicle_id'] ?? '') as String,
      tUserId: (json['t_user_id'] ?? '') as String,
      serviceDetails: rawServiceDetails is Map<String, dynamic>
          ? ServiceDetails.fromJson(rawServiceDetails)
          : null,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: rawCreatedAt is String ? DateTime.tryParse(rawCreatedAt) : null,
      updatedAt: rawUpdatedAt is String ? DateTime.tryParse(rawUpdatedAt) : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nickname != null) 'nickname': nickname,
        'brand_name': brandName,
        if (imageUrl != null) 'image_url': imageUrl,
        if (note != null) 'note': note,
        'license_plate': licensePlate,
        'manufactured_year': manufacturedYear,
        'odo_reading': odoReading,
        'm_vehicle_id': mVehicleId,
        't_user_id': tUserId,
        if (serviceDetails != null) 'service_details': serviceDetails!.toJson(),
        if (createdBy != null) 'created_by': createdBy,
        if (updatedBy != null) 'updated_by': updatedBy,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        'is_active': isActive,
      };
}
