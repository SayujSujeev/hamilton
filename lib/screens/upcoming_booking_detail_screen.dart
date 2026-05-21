import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_booking.dart';
import '../models/vehicle_model.dart';
import '../services/slot_service.dart';
import '../utils/brand_display_name.dart';
import 'services_screen.dart';

/// Shows upcoming workshop bookings for [vehicle], pulled from
/// `GET /api/v1/user/slots` and filtered to this car.
class UpcomingBookingDetailScreen extends StatefulWidget {
  const UpcomingBookingDetailScreen({
    super.key,
    required this.vehicle,
    required this.vehicles,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> vehicles;

  @override
  State<UpcomingBookingDetailScreen> createState() =>
      _UpcomingBookingDetailScreenState();
}

class _UpcomingBookingDetailScreenState
    extends State<UpcomingBookingDetailScreen> {
  final SlotService _slotService = SlotService();

  bool _loading = true;
  String? _error;
  List<UserBooking> _bookings = const [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final all = await _slotService.fetchUserBookings();
      if (!mounted) return;

      final now = DateTime.now();
      final mine = all.where((b) {
        if (b.vehicleId.isNotEmpty && b.vehicleId == widget.vehicle.id) {
          return true;
        }
        return false;
      }).toList();

      final filtered = mine.isEmpty ? all : mine;

      final upcoming = filtered
          .where((b) => b.hasDate && b.isUpcoming(now))
          .toList()
        ..sort((a, b) {
          final ad = a.bookingDate!;
          final bd = b.bookingDate!;
          final byDay = ad.compareTo(bd);
          if (byDay != 0) return byDay;
          return a.slotTiming.compareTo(b.slotTiming);
        });

      setState(() {
        _bookings = upcoming;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.vehicle.nickname?.trim().isNotEmpty == true
        ? widget.vehicle.nickname!.trim()
        : displayMakeNameForUi(
            widget.vehicle.name.trim().isEmpty ? 'Your vehicle' : widget.vehicle.name,
          );

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadBookings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
              'Workshop appointments for this car.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildBody(),
            const SizedBox(height: 32),
            _BookServiceButton(
              vehicle: widget.vehicle,
              vehicles: widget.vehicles,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
        ),
      );
    }
    if (_error != null) {
      return _ErrorBlock(message: _error!, onRetry: _loadBookings);
    }
    if (_bookings.isEmpty) {
      return const _EmptyBlock();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _bookings.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _BookingCard(booking: _bookings[i]),
        ],
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final UserBooking booking;

  static const _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formattedDate() {
    final d = booking.bookingDate;
    if (d == null) return '—';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String _formattedTime() {
    final raw = booking.slotTiming.trim();
    if (raw.isEmpty) return '—';
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return raw;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final mm = m.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }

  @override
  Widget build(BuildContext context) {
    final services = booking.serviceNames;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEFEF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Color(0xFFB71C1C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedDate(),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formattedTime(),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              if (booking.status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    booking.status,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
            ],
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in services)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (booking.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              booking.description,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF777777),
                height: 1.4,
              ),
            ),
          ],
          if (booking.licensePlate.isNotEmpty ||
              booking.vehicleName.isNotEmpty ||
              booking.vehicleBrand.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 14,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _vehicleLine(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _vehicleLine() {
    final parts = <String>[];
    final brand = booking.vehicleBrand.trim();
    final name = booking.vehicleName.trim();
    if (brand.isNotEmpty) parts.add(displayMakeNameForUi(brand));
    if (name.isNotEmpty) parts.add(displayMakeNameForUi(name));
    final head = parts.join(' ');
    final plate = booking.licensePlate.trim().toUpperCase();
    if (head.isEmpty) return plate;
    if (plate.isEmpty) return head;
    return '$head  •  $plate';
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
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
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            'Could not load bookings',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB71C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookServiceButton extends StatelessWidget {
  const _BookServiceButton({
    required this.vehicle,
    required this.vehicles,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> vehicles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
