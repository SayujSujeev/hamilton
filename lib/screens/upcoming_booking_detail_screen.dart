import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_booking.dart';
import '../models/vehicle_model.dart';
import '../services/slot_service.dart';
import '../utils/brand_display_name.dart';
import '../utils/upcoming_booking_filters.dart';
import '../widgets/get_started_primary_button.dart';
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
          SnackBar(
            backgroundColor: const Color(0xFF43001E),
            content: Text(
              message,
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel booking?',
          style: GoogleFonts.dmSerifText(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1B1B1B),
          ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
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

  void _openServices() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServicesScreen(
          userVehicleId: widget.vehicle.id,
          vehicles: widget.vehicles,
        ),
      ),
    );
  }

  String get _vehicleTitle {
    final nick = widget.vehicle.nickname?.trim();
    if (nick != null && nick.isNotEmpty) return nick;
    final name = widget.vehicle.name.trim();
    if (name.isNotEmpty) return displayMakeNameForUi(name);
    return 'Your vehicle';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFB71C1C),
              onRefresh: _loadBookings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UpcomingBookingHeader(
                      onBack: () => Navigator.of(context).pop(),
                      onRefresh: _loading ? null : _loadBookings,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vehicleTitle,
                              style: GoogleFonts.dmSerifText(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _showingAllVehicles
                                  ? 'All upcoming workshop appointments on your account.'
                                  : 'Workshop appointments for this car.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: const Color(0xFF6B6B6B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 64),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFB71C1C),
                                  ),
                                ),
                              )
                            else if (_error != null)
                              _ErrorBlock(
                                message: _error!,
                                onRetry: _loadBookings,
                              )
                            else if (_bookings.isEmpty)
                              const _EmptyBlock()
                            else
                              for (var i = 0; i < _bookings.length; i++) ...[
                                if (i > 0) const SizedBox(height: 12),
                                UpcomingBookingCard(
                                  booking: _bookings[i],
                                  isCancelling: _cancellingIds
                                      .contains(_bookings[i].id),
                                  onCancel: () =>
                                      _onCancelBooking(_bookings[i]),
                                ),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GetStartedPrimaryButton(
                width: double.infinity,
                height: 48,
                label: 'Book service',
                onPressed: _openServices,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingBookingHeader extends StatelessWidget {
  const _UpcomingBookingHeader({
    required this.onBack,
    this.onRefresh,
  });

  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF1A0608),
                  Color(0xFF43001E),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -8,
            bottom: -20,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/services_header_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      if (onRefresh != null)
                        IconButton(
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: 'Refresh',
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming booking',
                          style: GoogleFonts.dmSerifText(
                            color: Colors.white,
                            fontSize: 32,
                            height: 1.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your scheduled workshop visits.',
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43001E), Color(0xFFB71C1C)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No upcoming booking',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifText(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a service to see your appointment date and time here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B6B6B),
              height: 1.4,
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
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFB71C1C),
          ),
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
          const SizedBox(height: 16),
          GetStartedPrimaryButton(
            width: 140,
            height: 44,
            label: 'Retry',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
