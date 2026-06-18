import 'dart:convert';

/// Claims embedded in the backend JWT after phone/Google login.
class JwtClaims {
  const JwtClaims({
    required this.isProfileCompleted,
    required this.isVehicleAdded,
    this.expiresAt,
    this.subject,
  });

  final bool isProfileCompleted;
  final bool isVehicleAdded;
  final DateTime? expiresAt;
  final String? subject;

  bool get isFullyOnboarded => isProfileCompleted && isVehicleAdded;

  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  static JwtClaims? fromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(payload);
      if (map is! Map<String, dynamic>) return null;

      return JwtClaims(
        isProfileCompleted: _pickBool(
          map['is_profile_completed'] ??
              map['isProfileCompleted'] ??
              map['profile_completed'] ??
              map['profileCompleted'],
        ),
        isVehicleAdded: _pickBool(
          map['is_vehicle_added'] ??
              map['isVehicleAdded'] ??
              map['vehicle_added'] ??
              map['vehicleAdded'],
        ),
        expiresAt: _pickExpiry(map['exp']),
        subject: map['sub']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  static bool isExpiredToken(String token) {
    final claims = fromToken(token);
    return claims?.isExpired ?? false;
  }

  static bool _pickBool(dynamic value) {
    if (value is bool) return value;
    if (value == 1 || value == '1' || value == 'true') return true;
    return false;
  }

  static DateTime? _pickExpiry(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
          .toLocal();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true)
          .toLocal();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true)
            .toLocal();
      }
    }
    return null;
  }
}
