import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_booking.dart';
import '../models/vehicle_model.dart';
import '../services/slot_service.dart';
import '../utils/brand_display_name.dart';
import '../utils/upcoming_booking_filters.dart';
import '../widgets/upcoming_booking_card.dart';
import 'services_screen.dart';

/// Shows upcoming workshop bookings for [vehicle], pulled from
/// `GET /api/v1/user/booking` and filtered to this car.
class UpcomingBookingDetailScreen extends StatefulWidget {
  const UpcomingBookingDetailScreen({
    super.key,
    required this.vehicle,
    required this.vehicles,
    this.bookingConfirmedMessage,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> vehicles;
  final String? bookingConfirmedMessage;

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
  bool _showingAllVehicles = false;
  final Set<String> _cancellingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadBookings();
    final message = widget.bookingConfirmedMessage?.trim();
    if (message != null && message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final all = await _slotService.fetchUserBookings();
      if (!mounted) return;

      final mine = upcomingBookingsForVehicle(
        all: all,
        vehicle: widget.vehicle,
        vehicles: widget.vehicles,
      );

      if (kDebugMode) {
        final first = mine.isEmpty ? null : mine.first;
        debugPrint(
          '[UpcomingBooking] fetched=${all.length} shown=${mine.length} '
          'vehicle=${widget.vehicle.id} plate=${widget.vehicle.licensePlate} '
          'date=${first?.bookingDate} time=${first?.slotTiming} '
          'services=${first?.serviceNames}',
        );
      }

      setState(() {
        _bookings = mine;
        _showingAllVehicles = mine.isNotEmpty &&
            mine.every(
              (b) => !bookingMatchesVehicle(b, widget.vehicle),
            );
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

  Future<void> _onCancelBooking(UserBooking booking) async {
    if (booking.id.isEmpty) return;
    if (_cancellingIds.contains(booking.id)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel booking?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will cancel your workshop appointment. You can always book '
          'another slot afterwards.',
          style: GoogleFonts.dmSans(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep booking',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cancel booking',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancellingIds.add(booking.id));

    try {
      await _slotService.cancelBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled.')),
      );
      await _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not cancel: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingIds.remove(booking.id));
      }
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
              _showingAllVehicles
                  ? 'All upcoming workshop appointments on your account.'
                  : 'Workshop appointments for this car.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B6B6B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                ),
              )
            else if (_error != null)
              _ErrorBlock(message: _error!, onRetry: _loadBookings)
            else if (_bookings.isEmpty)
              const _EmptyBlock()
            else
              for (var i = 0; i < _bookings.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                UpcomingBookingCard(
                  booking: _bookings[i],
                  isCancelling: _cancellingIds.contains(_bookings[i].id),
                  onCancel: () => _onCancelBooking(_bookings[i]),
                ),
              ],
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
