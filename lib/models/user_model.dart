class UserModel {
  final String id;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String? gender;
  final String? imageUrl;
  final int roleId;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? dob;
  final String? mobileNo;
  final String? whatsappNo;
  final String? note;

  UserModel({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.gender,
    this.imageUrl,
    required this.roleId,
    this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.dob,
    this.mobileNo,
    this.whatsappNo,
    this.note,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRoleId = json['role_id'] ?? json['roleId'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];

    return UserModel(
      id: _asString(json['id']),
      username: _asString(json['username']),
      firstname: _asString(json['firstname']),
      lastname: _asString(json['lastname']),
      email: _asString(json['email']),
      gender: _asNullableString(json['gender']),
      imageUrl: _asNullableString(json['image_url'] ?? json['imageUrl']),
      roleId: rawRoleId is int
          ? rawRoleId
          : (rawRoleId is num ? rawRoleId.toInt() : 0),
      address: _asNullableString(json['address']),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['isActive'] as bool?) ?? true,
      createdAt: rawCreatedAt is String
          ? (DateTime.tryParse(rawCreatedAt) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: rawUpdatedAt is String
          ? (DateTime.tryParse(rawUpdatedAt) ?? DateTime.now())
          : DateTime.now(),
      dob: _asNullableString(json['dob']),
      mobileNo: _asNullableString(json['mobile_no'] ?? json['mobileNo']),
      whatsappNo: _asNullableString(json['whatsapp_no'] ?? json['whatsappNo']),
      note: _asNullableString(json['note']),
    );
  }

  static String _asString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      if (gender != null) 'gender': gender,
      if (imageUrl != null) 'image_url': imageUrl,
      'role_id': roleId,
      if (address != null) 'address': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (dob != null) 'dob': dob,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (whatsappNo != null) 'whatsapp_no': whatsappNo,
      if (note != null) 'note': note,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (firstname.isNotEmpty) 'firstname': firstname,
      if (lastname.isNotEmpty) 'lastname': lastname,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (imageUrl != null) 'image_url': imageUrl,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (whatsappNo != null) 'whatsapp_no': whatsappNo,
      if (note != null) 'note': note,
      if (address != null) 'address': address,
    };
  }
}
