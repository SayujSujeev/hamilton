import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_booking.dart';
import '../utils/brand_display_name.dart';

class UpcomingBookingCard extends StatelessWidget {
  const UpcomingBookingCard({
    super.key,
    required this.booking,
    this.isCancelling = false,
    this.onCancel,
    this.compact = false,
  });

  final UserBooking booking;
  final bool isCancelling;
  final VoidCallback? onCancel;
  final bool compact;

  static const _accent = Color(0xFFB71C1C);
  static const _burgundy = Color(0xFF43001E);

  bool get _canCancel {
    if (onCancel == null || booking.id.isEmpty) return false;
    final status = booking.status.toLowerCase().trim();
    return status != 'cancelled' &&
        status != 'canceled' &&
        status != 'completed' &&
        status != 'done';
  }

  static const _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formattedDate() {
    final date = booking.bookingDate;
    if (date == null) return '—';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
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

  String _serviceLabel() {
    if (booking.serviceNames.isNotEmpty) {
      return booking.serviceNames.join(', ');
    }
    final description = booking.description.trim();
    if (description.isNotEmpty) return description;
    return 'Workshop appointment';
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

  Color _statusBackground(String status) {
    final s = status.toLowerCase().trim();
    if (s.contains('cancel')) return const Color(0xFFF5F5F5);
    if (s.contains('complete') || s.contains('done')) {
      return const Color(0xFFE8F5E9);
    }
    return const Color(0xFFFFEFEF);
  }

  Color _statusForeground(String status) {
    final s = status.toLowerCase().trim();
    if (s.contains('cancel')) return const Color(0xFF757575);
    if (s.contains('complete') || s.contains('done')) {
      return const Color(0xFF1B5E20);
    }
    return _accent;
  }

  @override
  Widget build(BuildContext context) {
    final services = booking.serviceNames;
    final radius = compact ? 12.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE7E7E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_burgundy, _accent],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 36 : 44,
                      height: compact ? 36 : 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF43001E), Color(0xFFB71C1C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_available_outlined,
                        color: Colors.white,
                        size: compact ? 18 : 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compact ? _formattedDate() : _formattedDate(),
                            style: compact
                                ? GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B1B1B),
                                  )
                                : GoogleFonts.dmSerifText(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1B1B1B),
                                    height: 1.1,
                                  ),
                          ),
                          const SizedBox(height: 6),
                          _TimeChip(label: _formattedTime()),
                        ],
                      ),
                    ),
                    if (booking.status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBackground(booking.status),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          booking.status,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statusForeground(booking.status),
                          ),
                        ),
                      ),
                  ],
                ),
                if (compact) ...[
                  const SizedBox(height: 12),
                  Text(
                    _serviceLabel(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
                if (!compact) ...[
                  const SizedBox(height: 14),
                  Text(
                    _serviceLabel(),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                    ),
                  ),
                ],
                if (!compact && services.length > 1) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final service in services)
                        _MetaChip(label: service),
                    ],
                  ),
                ],
                if (!compact &&
                    (booking.licensePlate.isNotEmpty ||
                        booking.vehicleName.isNotEmpty ||
                        booking.vehicleBrand.isNotEmpty)) ...[
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
                if (_canCancel) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFEFEFEF)),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: isCancelling ? null : onCancel,
                      icon: isCancelling
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _accent,
                              ),
                            )
                          : const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _accent,
                            ),
                      label: Text(
                        isCancelling ? 'Cancelling…' : 'Cancel booking',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            size: 12,
            color: Color(0xFFB71C1C),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}
