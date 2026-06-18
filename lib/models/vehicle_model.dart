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
  /// HTTPS URL to a make logo hosted on your CDN (e.g. PNG/WebP).
  final String? brandLogoUrl;
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
    this.brandLogoUrl,
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
    final vehicleObj = json['vehicle'] is Map<String, dynamic>
        ? json['vehicle'] as Map<String, dynamic>
        : null;
    final vehicleDetailObj = json['vehicle_detail'] is Map<String, dynamic>
        ? json['vehicle_detail'] as Map<String, dynamic>
        : null;
    final brandObj = json['brand'] is Map<String, dynamic>
        ? json['brand'] as Map<String, dynamic>
        : (vehicleObj?['brand'] is Map<String, dynamic>
            ? vehicleObj!['brand'] as Map<String, dynamic>
            : null);

    final rawCreatedAt = _pickFirst(json, vehicleObj, vehicleDetailObj, const [
      'created_at',
      'createdAt',
    ]);
    final rawUpdatedAt = _pickFirst(json, vehicleObj, vehicleDetailObj, const [
      'updated_at',
      'updatedAt',
    ]);
    final rawServiceDetails = json['service_details'] ?? json['serviceDetails'];

    return VehicleModel(
      id: _pickString(json, const ['id', 'user_vehicle_id', '_id']).ifEmptyTry(
        () => vehicleDetailObj == null
            ? ''
            : _pickString(vehicleDetailObj, const ['id', 'user_vehicle_id', '_id']),
      ),
      name: _pickString(json, const ['name', 'vehicle_name', 'model']).ifEmptyTry(
        () => vehicleObj == null
            ? ''
            : _pickString(vehicleObj, const ['name', 'vehicle_name', 'model']),
      ),
      nickname: _pickNullableString(json, const ['nickname']),
      brandName: _pickString(json, const ['brand_name', 'brandName']).ifEmptyTry(() {
        if (brandObj != null) {
          final fromBrand = _pickString(
            brandObj,
            const ['name', 'brand_name', 'brandName'],
          );
          if (fromBrand.isNotEmpty) return fromBrand;
        }
        if (vehicleObj != null) {
          final fromVehicle = _pickString(
            vehicleObj,
            const ['brand_name', 'brandName', 'brand'],
          );
          if (fromVehicle.isNotEmpty) return fromVehicle;
        }
        return '';
      }),
      brandLogoUrl: _pickNullableString(json, const [
        'brand_logo_url',
        'brandLogoUrl',
      ]) ??
          (brandObj == null
              ? null
              : _pickNullableString(brandObj, const [
                  'logo_url',
                  'brand_logo_url',
                  'brandLogoUrl',
                  'image_url',
                ])),
      imageUrl: _pickNullableString(json, const ['image_url', 'imageUrl']),
      note: json['note'],
      licensePlate: _pickString(json, const [
        'license_plate',
        'licensePlate',
        'plate',
      ]).ifEmptyTry(() {
        if (vehicleDetailObj != null) {
          final fromDetail = _pickString(
            vehicleDetailObj,
            const ['license_plate', 'licensePlate', 'plate'],
          );
          if (fromDetail.isNotEmpty) return fromDetail;
        }
        if (vehicleObj != null) {
          return _pickString(
            vehicleObj,
            const ['license_plate', 'licensePlate', 'plate'],
          );
        }
        return '';
      }),
      manufacturedYear: _pickYear(json, const [
        'manufactured_year',
        'manufacturedYear',
        'year',
      ]),
      odoReading: _pickInt(json, const ['odo_reading', 'odoReading']) ??
          (vehicleDetailObj == null
              ? 0
              : _pickInt(vehicleDetailObj, const ['odo_reading', 'odoReading']) ??
                  0),
      mVehicleId: _pickString(json, const [
        'm_vehicle_id',
        'vehicle_id',
        'mVehicleId',
        'vehicleId',
      ]).ifEmptyTry(() => vehicleObj == null
          ? ''
          : _pickString(vehicleObj, const [
              'm_vehicle_id',
              'vehicle_id',
              'id',
            ])),
      tUserId: _pickString(json, const [
        't_user_id',
        'user_id',
        'tUserId',
        'userId',
      ]),
      serviceDetails: rawServiceDetails is Map<String, dynamic>
          ? ServiceDetails.fromJson(rawServiceDetails)
          : null,
      createdBy: _pickNullableString(json, const ['created_by', 'createdBy']),
      updatedBy: _pickNullableString(json, const ['updated_by', 'updatedBy']),
      createdAt: rawCreatedAt is String ? DateTime.tryParse(rawCreatedAt) : null,
      updatedAt: rawUpdatedAt is String ? DateTime.tryParse(rawUpdatedAt) : null,
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['isActive'] as bool?) ?? true,
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

  static dynamic _pickFirst(
    Map<String, dynamic> json,
    Map<String, dynamic>? vehicleObj,
    Map<String, dynamic>? vehicleDetailObj,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = json[k];
      if (v != null) return v;
    }
    if (vehicleObj != null) {
      for (final k in keys) {
        final v = vehicleObj[k];
        if (v != null) return v;
      }
    }
    if (vehicleDetailObj != null) {
      for (final k in keys) {
        final v = vehicleDetailObj[k];
        if (v != null) return v;
      }
    }
    return null;
  }

  static String _pickYear(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is int) return v.toString();
      if (v is num) return v.toInt().toString();
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nickname != null) 'nickname': nickname,
        'brand_name': brandName,
        if (brandLogoUrl != null) 'brand_logo_url': brandLogoUrl,
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

extension _IfEmptyTry on String {
  String ifEmptyTry(String Function() fallback) =>
      isEmpty ? fallback() : this;
}
