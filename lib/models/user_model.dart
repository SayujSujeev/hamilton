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
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String?,
      imageUrl: json['image_url'] as String?,
      roleId: json['role_id'] as int,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dob: json['dob'] as String?,
      mobileNo: json['mobile_no'] as String?,
      whatsappNo: json['whatsapp_no'] as String?,
      note: json['note'] as String?,
    );
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
