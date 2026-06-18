import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/add_first_vehicle_screen.dart';
import '../screens/home_screen_wrapper.dart';
import '../screens/personal_details_screen.dart';
import '../screens/phone_registration_screen.dart';
import '../services/api_client.dart';
import 'jwt_utils.dart';

/// Onboarding progress — from JWT and/or live API checks.
class OnboardingStatus {
  const OnboardingStatus({
    required this.isProfileCompleted,
    required this.isVehicleAdded,
  });

  final bool isProfileCompleted;
  final bool isVehicleAdded;

  bool get isFullyOnboarded => isProfileCompleted && isVehicleAdded;
}

/// Thrown when the stored JWT is no longer accepted by the backend.
class AuthExpiredException implements Exception {
  AuthExpiredException([this.message = 'Authentication expired']);
  final String message;

  @override
  String toString() => message;
}

bool _isAuthError(Object e) {
  final msg = e.toString();
  return msg.contains('401') ||
      msg.contains('403') ||
      msg.contains('Authentication expired');
}

/// Reads profile + vehicle state from the backend (source of truth).
Future<OnboardingStatus> fetchOnboardingStatus(ApiClient api) async {
  var profileDone = false;
  var vehicleDone = false;

  try {
    final user = await api.getCurrentUserModel();
    profileDone = user.firstname.trim().isNotEmpty ||
        (user.mobileNo?.trim().isNotEmpty ?? false);
  } catch (e) {
    if (_isAuthError(e)) rethrow;
  }

  try {
    final vehicles = await api.getUserVehicles();
    vehicleDone = vehicles.isNotEmpty;
  } catch (e) {
    if (_isAuthError(e)) rethrow;
  }

  return OnboardingStatus(
    isProfileCompleted: profileDone,
    isVehicleAdded: vehicleDone,
  );
}

Widget destinationForStatus(
  OnboardingStatus status, {
  String phoneNumber = '',
}) {
  if (!status.isProfileCompleted) {
    return PersonalDetailsScreen(phoneNumber: phoneNumber);
  }
  if (!status.isVehicleAdded) {
    return const AddFirstVehicleScreen();
  }
  return const HomeScreenWrapper();
}

/// Sync route from JWT only (used right after login before API round-trip).
Widget authDestinationForToken(
  String token, {
  String phoneNumber = '',
}) {
  final claims = JwtClaims.fromToken(token);
  if (claims == null) {
    return PersonalDetailsScreen(phoneNumber: phoneNumber);
  }
  return destinationForStatus(
    OnboardingStatus(
      isProfileCompleted: claims.isProfileCompleted,
      isVehicleAdded: claims.isVehicleAdded,
    ),
    phoneNumber: phoneNumber,
  );
}

/// Best route after splash or login — JWT first, then API fallback.
Future<Widget> resolveAuthDestination({
  String? token,
  String phoneNumber = '',
  ApiClient? apiClient,
}) async {
  if (token == null || token.isEmpty) {
    return const PhoneRegistrationScreen();
  }

  if (JwtClaims.isExpiredToken(token)) {
    throw AuthExpiredException('Token expired');
  }

  final claims = JwtClaims.fromToken(token);
  if (kDebugMode && claims != null) {
    debugPrint(
      '[Auth] JWT claims: profile=${claims.isProfileCompleted}, '
      'vehicle=${claims.isVehicleAdded}, exp=${claims.expiresAt}',
    );
  }

  // Fast path — JWT says fully onboarded.
  if (claims != null && claims.isFullyOnboarded) {
    return const HomeScreenWrapper();
  }

  // JWT flags missing or false — verify with live API (profile/vehicles exist).
  final api = apiClient ?? ApiClient();
  final status = await fetchOnboardingStatus(api);

  if (kDebugMode) {
    debugPrint(
      '[Auth] API status: profile=${status.isProfileCompleted}, '
      'vehicle=${status.isVehicleAdded}',
    );
  }

  return destinationForStatus(status, phoneNumber: phoneNumber);
}
