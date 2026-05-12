import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vehicle_model.dart';
import '../utils/brand_display_name.dart';
import 'services_screen.dart';

/// Placeholder screen for a vehicle’s upcoming workshop booking.
/// Wire to your bookings API when available.
class UpcomingBookingDetailScreen extends StatelessWidget {
  const UpcomingBookingDetailScreen({
    super.key,
    required this.vehicle,
    required this.vehicles,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> vehicles;

  @override
  Widget build(BuildContext context) {
    final title = vehicle.nickname?.trim().isNotEmpty == true
        ? vehicle.nickname!.trim()
        : displayMakeNameForUi(vehicle.name.trim().isEmpty ? 'Your vehicle' : vehicle.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF43001E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Upcoming booking',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSerifText(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Workshop appointments for this car will appear here.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No upcoming booking',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book a service to see date and time here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ServicesScreen(
                        userVehicleId: vehicle.id,
                        vehicles: vehicles,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Book service',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
