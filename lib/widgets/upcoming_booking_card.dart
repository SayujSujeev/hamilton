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

  @override
  Widget build(BuildContext context) {
    final services = booking.serviceNames;

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEFEF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  color: const Color(0xFFB71C1C),
                  size: compact ? 18 : 20,
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
                        fontSize: compact ? 13 : 14,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          if (compact) ...[
            const SizedBox(height: 10),
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
          if (!compact && services.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final service in services)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      service,
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
          if (!compact && booking.description.isNotEmpty) ...[
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
            const SizedBox(height: 8),
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
                          color: Color(0xFFB71C1C),
                        ),
                      )
                    : const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFB71C1C),
                      ),
                label: Text(
                  isCancelling ? 'Cancelling…' : 'Cancel booking',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB71C1C),
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
    );
  }
}
