import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../booking/slot_booking_logic.dart';
import '../models/booking_cart_line.dart';
import '../models/workshop_slot.dart';
import '../services/slot_service.dart';

/// Pick a date, then a start slot from GET /api/v1/slots.
/// Multiple services require that many consecutive slots with capacity.
class BookingDateTimeScreen extends StatefulWidget {
  const BookingDateTimeScreen({
    super.key,
    required this.cartLines,
    required this.total,
    this.userVehicleId,
  });

  final List<BookingCartLine> cartLines;
  final double total;
  /// `VehicleModel.id` from GET /api/v1/user/vehicle (user↔vehicle row).
  final String? userVehicleId;

  int get serviceCount => cartLines.length;

  @override
  State<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends State<BookingDateTimeScreen> {
  static const int _horizonDays = 21;

  final SlotService _slotService = SlotService();

  late List<DateTime> _days;
  late int _selectedDayIndex;

  List<WorkshopSlot> _sortedSlots = [];
  List<WorkshopSlot> _eligibleStarts = [];
  List<String>? _resolvedServiceIds;
  String? _resolutionError;

  int _slotStepMinutes = 45;
  WorkshopSlot? _selectedFirstSlot;

  bool _loadingSlots = false;
  String? _slotsLoadError;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _days = List.generate(
      _horizonDays,
      (i) => today.add(Duration(days: i)),
    );
    _selectedDayIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlotsForSelectedDay();
    });
  }

  DateTime get _selectedDate => _days[_selectedDayIndex];

  Future<void> _loadSlotsForSelectedDay() async {
    setState(() {
      _loadingSlots = true;
      _slotsLoadError = null;
      _resolutionError = null;
      _selectedFirstSlot = null;
      _sortedSlots = [];
      _eligibleStarts = [];
      _resolvedServiceIds = null;
    });

    try {
      final raw = await _slotService.fetchSlotsForDate(_selectedDate);
      if (!mounted) return;

      final sorted = SlotBookingLogic.sortedByTime(raw);
      final step = SlotBookingLogic.inferSlotStepMinutes(sorted);
      final catalog = SlotBookingLogic.serviceNameCatalog(sorted);
      final resolved =
          SlotBookingLogic.resolveOrderedServiceIds(widget.cartLines, catalog);

      final unresolvedIdx =
          resolved.indexWhere((id) => id == null || id.isEmpty);

      List<WorkshopSlot> eligible;
      String? resErr;
      List<String>? ids;

      if (unresolvedIdx >= 0) {
        eligible = [];
        ids = null;
        resErr =
            'Could not match "${widget.cartLines[unresolvedIdx].title}" to a '
            'service from the workshop schedule for this day. '
            'Set an explicit service UUID in the app catalog or align names '
            'with the API.';
      } else {
        ids = [for (final r in resolved) r!];
        eligible = SlotBookingLogic.eligibleStartSlots(
          sortedSlots: sorted,
          orderedServiceIds: ids,
        );
      }

      setState(() {
        _sortedSlots = sorted;
        _slotStepMinutes = step;
        _resolvedServiceIds = ids;
        _resolutionError = resErr;
        _eligibleStarts = eligible;
        _loadingSlots = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSlots = false;
        _slotsLoadError = e.toString();
      });
    }
  }

  void _onPickDay(int index) {
    setState(() => _selectedDayIndex = index);
    _loadSlotsForSelectedDay();
  }

  void _onPickSlot(WorkshopSlot slot) {
    setState(() => _selectedFirstSlot = slot);
  }

  TimeOfDay? _timeOf(WorkshopSlot s) =>
      SlotBookingLogic.parseSlotTiming(s.slotTiming);

  Future<void> _submitBooking() async {
    final vehicleId = widget.userVehicleId?.trim();
    if (vehicleId == null || vehicleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a vehicle on Home before booking (vehicle id missing).',
          ),
        ),
      );
      return;
    }

    final slot = _selectedFirstSlot;
    final ids = _resolvedServiceIds;
    if (slot == null || ids == null || ids.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final description = widget.cartLines
          .map((e) {
            final sub = e.subtitle;
            return sub == null ? e.title : '${e.title} ($sub)';
          })
          .join('; ');

      final bookingId = await _slotService.bookSlot(
        bookingDate: SlotBookingLogic.formatDateApi(_selectedDate),
        slotId: slot.slotId,
        vehicleUserRowId: vehicleId,
        serviceTypeIds: ids,
        description: description,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bookingId != null
                ? 'Booking confirmed ($bookingId)'
                : 'Booking submitted.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.serviceCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F4F4),
        elevation: 0,
        foregroundColor: const Color(0xFF1B1B1B),
        title: Text(
          'Pick date & time',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                    lines: widget.cartLines,
                    total: widget.total,
                    serviceCount: k,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Select date',
                    style: GoogleFonts.dmSerifText(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final d = _days[index];
                        final sel = index == _selectedDayIndex;
                        return _DateChip(
                          date: d,
                          selected: sel,
                          onTap: () => _onPickDay(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available slots',
                    style: GoogleFonts.dmSerifText(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    k <= 1
                        ? 'Choose any slot that has capacity for your service.'
                        : 'Only start times with $k consecutive slots are shown — '
                            'each service uses one slot in order.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_loadingSlots)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_slotsLoadError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        _slotsLoadError!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.red.shade800,
                        ),
                      ),
                    )
                  else if (_resolutionError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        _resolutionError!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.red.shade800,
                        ),
                      ),
                    )
                  else if (_eligibleStarts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No matching slots on this day. Try another date.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _eligibleStarts.map((ws) {
                        final t = _timeOf(ws);
                        if (t == null) return const SizedBox.shrink();

                        final picked = _selectedFirstSlot?.slotId == ws.slotId;
                        final labelPrimary =
                            SlotBookingLogic.formatTime(t);
                        final labelSecondary = k > 1
                            ? SlotBookingLogic.formatSlotRangeFromApi(
                                ws,
                                k,
                                _slotStepMinutes,
                                _sortedSlots,
                              )
                            : null;

                        return ChoiceChip(
                          showCheckmark: false,
                          label: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  labelPrimary,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: picked
                                        ? Colors.white
                                        : const Color(0xFF222222),
                                  ),
                                ),
                                if (labelSecondary != null)
                                  Text(
                                    labelSecondary,
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10,
                                      color: picked
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : const Color(0xFF777777),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          selected: picked,
                          onSelected: (v) {
                            if (v) _onPickSlot(ws);
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: picked
                                  ? Colors.black
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedFirstSlot == null ||
                          _resolvedServiceIds == null ||
                          _submitting)
                      ? null
                      : _submitBooking,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.lines,
    required this.total,
    required this.serviceCount,
  });

  final List<BookingCartLine> lines;
  final double total;
  final int serviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$serviceCount service${serviceCount == 1 ? '' : 's'} • Q ${total.toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map((line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.title,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF444444),
                          ),
                        ),
                        if (line.subtitle != null)
                          Text(
                            line.subtitle!,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: const Color(0xFF909090),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Q ${line.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: const Color(0xFF151515),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final wd = _weekdays[date.weekday - 1];
    final mon = _months[date.month - 1];

    return Material(
      color: selected ? Colors.black : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.black : const Color(0xFFE0E0E0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                wd,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : const Color(0xFF1E1E1E),
                  height: 1,
                ),
              ),
              Text(
                mon,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
