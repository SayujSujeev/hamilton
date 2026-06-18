import 'package:flutter/material.dart';

import '../screens/add_first_vehicle_screen.dart';
import '../screens/home_screen_wrapper.dart';
import '../screens/personal_details_screen.dart';
import 'jwt_utils.dart';

/// Picks the first onboarding screen based on JWT claims from phone/Google login.
Widget authDestinationForToken(
  String token, {
  String phoneNumber = '',
}) {
  final claims = JwtClaims.fromToken(token);
  if (claims == null) {
    return PersonalDetailsScreen(phoneNumber: phoneNumber);
  }
  return authDestinationForClaims(claims, phoneNumber: phoneNumber);
}

Widget authDestinationForClaims(
  JwtClaims claims, {
  String phoneNumber = '',
}) {
  if (!claims.isProfileCompleted) {
    return PersonalDetailsScreen(phoneNumber: phoneNumber);
  }
  if (!claims.isVehicleAdded) {
    return const AddFirstVehicleScreen();
  }
  return const HomeScreenWrapper();
}
