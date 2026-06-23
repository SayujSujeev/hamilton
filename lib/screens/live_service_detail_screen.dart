import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/live_service.dart';

class LiveServiceDetailScreen extends StatelessWidget {
  const LiveServiceDetailScreen({super.key, required this.liveService});

  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A1A1A),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Live Service',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusBanner(liveService: liveService),
            const SizedBox(height: 12),
            _VehicleInfoCard(liveService: liveService),
            if (liveService.serviceHistory.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ServiceHistoryCard(liveService: liveService),
            ],
            const SizedBox(height: 12),
            _ItemsCard(liveService: liveService),
            const SizedBox(height: 12),
            _CostSummaryCard(liveService: liveService),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// STATUS BANNER
// ─────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.liveService});
  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    final ls = liveService;
    final isActive = ls.isActive;
    final bgColor = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5);
    final borderColor =
        isActive ? const Color(0xFFA5D6A7) : const Color(0xFFE0E0E0);
    final titleColor =
        isActive ? const Color(0xFF1B5E20) : const Color(0xFF424242);
    final subtitleColor =
        isActive ? const Color(0xFF2E7D32) : const Color(0xFF757575);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (isActive) _PulsingDot(),
          if (!isActive)
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF9E9E9E),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ls.statusLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? 'Your vehicle is currently being serviced at the workshop.'
                      : 'Latest update on your live service booking.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFF43A047),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// VEHICLE INFO CARD
// ─────────────────────────────────────────────────────────
class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.liveService});
  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    final ls = liveService;
    final hasCustomer = ls.customerName != '—';
    return _Card(
      title: hasCustomer ? 'Vehicle & Customer' : 'Vehicle',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.directions_car_outlined,
            label: 'License Plate',
            value: ls.licensePlate.trim().isEmpty ? '—' : ls.licensePlate.toUpperCase(),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.speed_outlined,
            label: 'Odometer',
            value: ls.odoReading <= 0 ? '—' : '${_formatKm(ls.odoReading)} km',
          ),
          if (ls.serviceInTime != null) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.login_rounded,
              label: 'Checked In',
              value: _formatDateTime(ls.serviceInTime!),
            ),
          ],
          if (ls.serviceOutTime != null) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.logout_rounded,
              label: 'Checked Out',
              value: _formatDateTime(ls.serviceOutTime!),
            ),
          ],
          if (hasCustomer) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Customer',
              value: ls.customerName,
            ),
          ],
          if (ls.mobileNo != null) ...[
            const _RowDivider(),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Mobile',
              value: ls.mobileNo!,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final months = const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year} • $hour:$minute $period';
  }

  static String _formatKm(int km) {
    final s = km.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─────────────────────────────────────────────────────────
// SERVICE HISTORY
// ─────────────────────────────────────────────────────────
class _ServiceHistoryCard extends StatelessWidget {
  const _ServiceHistoryCard({required this.liveService});
  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    final history = liveService.serviceHistory;
    return _Card(
      title: 'Service Timeline',
      child: Column(
        children: [
          for (var i = 0; i < history.length; i++) ...[
            _HistoryRow(
              entry: history[i],
              isLast: i == history.length - 1,
              isCurrent: i == history.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.isLast,
    required this.isCurrent,
  });

  final LiveServiceHistoryEntry entry;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final dotColor =
        isCurrent ? const Color(0xFF43A047) : const Color(0xFFBDBDBD);
    final lineColor = const Color(0xFFE0E0E0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayStatus,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (entry.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _VehicleInfoCard._formatDateTime(entry.createdAt!),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                  if (entry.remarks != null && entry.remarks!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.remarks!,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: const Color(0xFF666666),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ITEMS CARD
// ─────────────────────────────────────────────────────────
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.liveService});
  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    final items = liveService.items;
    if (items.isEmpty) {
      return _Card(
        title: 'Service Items',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No items recorded yet.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
      );
    }

    return _Card(
      title: 'Service Items',
      child: Column(
        children: [
          _ItemsHeader(),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _ItemRow(item: item),
                if (i < items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                  )
                else
                  const SizedBox(height: 2),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            'Item',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
        _HeaderCell('Qty', flex: 2),
        _HeaderCell('Unit', flex: 3),
        _HeaderCell('Total', flex: 3, align: TextAlign.right),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {required this.flex, this.align});
  final String text;
  final int flex;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align ?? TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final LiveServiceItem item;

  @override
  Widget build(BuildContext context) {
    final isLabour = item.isLabour;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.itemName.isEmpty ? '—' : item.itemName,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isLabour
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isLabour ? 'Labour' : 'Spare Part',
                  style: GoogleFonts.dmSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isLabour
                        ? const Color(0xFF1565C0)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.note,
                  style: GoogleFonts.dmSans(
                    fontSize: 10.5,
                    color: const Color(0xFF9E9E9E),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF444444),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            item.unitPrice == 0 ? '—' : _fmt(item.unitPrice),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF444444),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            item.totalPrice == 0 ? '—' : _fmt(item.totalPrice),
            textAlign: TextAlign.right,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  static String _fmt(double v) => 'QAR ${v.toStringAsFixed(2)}';
}

// ─────────────────────────────────────────────────────────
// COST SUMMARY CARD
// ─────────────────────────────────────────────────────────
class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.liveService});
  final LiveService liveService;

  @override
  Widget build(BuildContext context) {
    final ls = liveService;
    return _Card(
      title: 'Cost Summary',
      child: Column(
        children: [
          _CostRow(label: 'Parts Total', amount: ls.totalPartsCost),
          const _RowDivider(),
          _CostRow(label: 'Labour Total', amount: ls.totalLaborCost),
          if (ls.discount > 0) ...[
            const _RowDivider(),
            _CostRow(
              label: 'Discount',
              amount: -ls.discount,
              color: const Color(0xFF2E7D32),
              prefix: '-',
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'QAR ${ls.grandTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({
    required this.label,
    required this.amount,
    this.color,
    this.prefix = '',
  });
  final String label;
  final double amount;
  final Color? color;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? const Color(0xFF1A1A1A);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            '${prefix}QAR ${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9E9E9E),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              color: const Color(0xFF666666),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF0F0F0));
  }
}
