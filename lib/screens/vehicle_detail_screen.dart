import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vehicle_model.dart';
import '../utils/brand_display_name.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  final VehicleModel vehicle;

  String _formatLicensePlate(String plate) {
    final t = plate.trim();
    if (t.isEmpty) return '—';
    return t.replaceAll(' ', '').toUpperCase();
  }

  String _formatOdometerKm(int km) {
    if (km <= 0) return '—';
    final s = km.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} km';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final brand = vehicle.brandName.trim().isEmpty
        ? '—'
        : displayMakeNameForUi(vehicle.brandName);
    final model = vehicle.name.trim().isEmpty
        ? '—'
        : displayMakeNameForUi(vehicle.name);
    final nickname = vehicle.nickname?.trim();
    final hasNickname = nickname != null && nickname.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF43001E),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: Color(0xFF43001E)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/home_hero_bg.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasNickname) ...[
                            Text(
                              nickname,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.88),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            brand,
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.88),
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            model,
                            style: GoogleFonts.dmSerifText(
                              fontSize: 42,
                              color: Colors.white,
                              height: 1.1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: SizedBox(
                              width: 220,
                              height: 140,
                              child: _buildVehicleImage(vehicle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Information',
                              style: GoogleFonts.dmSerifText(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow(
                              'License Plate',
                              _formatLicensePlate(vehicle.licensePlate),
                              Icons.confirmation_number_outlined,
                            ),
                            const Divider(height: 32, color: Color(0xFFE9E9E9)),
                            _buildInfoRow(
                              'Manufactured Year',
                              vehicle.manufacturedYear.trim().isEmpty
                                  ? '—'
                                  : vehicle.manufacturedYear.trim(),
                              Icons.calendar_today_outlined,
                            ),
                            const Divider(height: 32, color: Color(0xFFE9E9E9)),
                            _buildInfoRow(
                              'Odometer Reading',
                              _formatOdometerKm(vehicle.odoReading),
                              Icons.speed_outlined,
                            ),
                            if (vehicle.noteText != null) ...[
                              const Divider(height: 32, color: Color(0xFFE9E9E9)),
                              _buildInfoRow(
                                'Notes',
                                vehicle.noteText!,
                                Icons.note_outlined,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (vehicle.serviceDetails != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service History',
                            style: GoogleFonts.dmSerifText(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1B1B1B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            'Last Service Date',
                            _formatDate(vehicle.serviceDetails!.lastServiceDate),
                            Icons.event_outlined,
                          ),
                          const Divider(height: 32, color: Color(0xFFE9E9E9)),
                          _buildInfoRow(
                            'Last Service Duration',
                            vehicle.serviceDetails!.lastServiceDuration?.trim().isNotEmpty ?? false
                                ? vehicle.serviceDetails!.lastServiceDuration!.trim()
                                : '—',
                            Icons.access_time_outlined,
                          ),
                          const Divider(height: 32, color: Color(0xFFE9E9E9)),
                          _buildInfoRow(
                            'Avg. Service Duration',
                            vehicle.serviceDetails!.avrgServiceDuration?.trim().isNotEmpty ?? false
                                ? vehicle.serviceDetails!.avrgServiceDuration!.trim()
                                : '—',
                            Icons.av_timer_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Information',
                          style: GoogleFonts.dmSerifText(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          'Created Date',
                          _formatDate(vehicle.createdAt),
                          Icons.add_circle_outline,
                        ),
                        const Divider(height: 32, color: Color(0xFFE9E9E9)),
                        _buildInfoRow(
                          'Last Updated',
                          _formatDate(vehicle.updatedAt),
                          Icons.update_outlined,
                        ),
                        const Divider(height: 32, color: Color(0xFFE9E9E9)),
                        _buildInfoRow(
                          'Status',
                          vehicle.isActive ? 'Active' : 'Inactive',
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to edit vehicle screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit vehicle feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFB71C1C),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text(
          'Edit Vehicle',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(VehicleModel vehicle) {
    final url = vehicle.imageUrl?.trim();
    final hasNetworkImage = url != null && url.isNotEmpty;

    if (hasNetworkImage) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/home_bmw_x5.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return Image.asset(
      'assets/images/home_bmw_x5.png',
      fit: BoxFit.contain,
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF1B1B1B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
