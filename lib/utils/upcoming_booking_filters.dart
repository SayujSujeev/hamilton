import 'package:flutter/foundation.dart';

import '../models/user_booking.dart';
import '../models/vehicle_model.dart';

String normalizeLicensePlate(String plate) =>
    plate.trim().replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

bool isCancelledBooking(UserBooking booking) {
  final status = booking.status.toLowerCase().trim();
  return status == 'cancelled' || status == 'canceled';
}

bool bookingMatchesVehicle(UserBooking booking, VehicleModel vehicle) {
  final bookingIds = booking.vehicleMatchIds.toSet();
  final vehicleIds = <String>{
    if (vehicle.id.isNotEmpty) vehicle.id,
    if (vehicle.mVehicleId.isNotEmpty) vehicle.mVehicleId,
  };
  if (bookingIds.intersection(vehicleIds).isNotEmpty) return true;

  final bookingPlate = normalizeLicensePlate(booking.licensePlate);
  final vehiclePlate = normalizeLicensePlate(vehicle.licensePlate);
  return bookingPlate.isNotEmpty && bookingPlate == vehiclePlate;
}

List<UserBooking> upcomingBookingsForVehicle({
  required List<UserBooking> all,
  required VehicleModel vehicle,
  required List<VehicleModel> vehicles,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();

  if (kDebugMode && all.isNotEmpty) {
    for (final b in all) {
      final cancelled = isCancelledBooking(b);
      final upcoming = !b.hasDate || b.isUpcoming(clock);
      final matchesCurrent = bookingMatchesVehicle(b, vehicle);
      debugPrint(
        '[Filter] id=${b.id.substring(0, 8)} '
        'date=${b.bookingDate} slotTime=${b.slotTiming} '
        'status="${b.status}" cancelled=$cancelled upcoming=$upcoming '
        'vehicleId=${b.vehicleId} catalogId=${b.catalogVehicleId} '
        'plate=${b.licensePlate} '
        'matchesCurrent=$matchesCurrent',
      );
    }
  }

  // Include bookings with no date (assume upcoming) and exclude cancelled/past.
  final upcomingAll = all
      .where((b) => !isCancelledBooking(b) && (!b.hasDate || b.isUpcoming(clock)))
      .toList();

  var mine = upcomingAll
      .where((b) => bookingMatchesVehicle(b, vehicle))
      .toList();

  if (mine.isEmpty) {
    mine = upcomingAll
        .where((b) => vehicles.any((v) => bookingMatchesVehicle(b, v)))
        .toList();
  }

  if (mine.isEmpty && upcomingAll.isNotEmpty) {
    mine = upcomingAll;
  }

  mine.sort((a, b) {
    final ad = a.bookingDate;
    final bd = b.bookingDate;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    final byDay = ad.compareTo(bd);
    if (byDay != 0) return byDay;
    return a.slotTiming.compareTo(b.slotTiming);
  });

  return mine;
}
