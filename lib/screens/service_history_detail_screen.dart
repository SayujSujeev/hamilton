import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/live_service.dart';
import '../models/service_history.dart';
import '../services/service_history_service.dart';
import '../utils/brand_display_name.dart';
import '../widgets/get_started_primary_button.dart';

class ServiceHistoryDetailScreen extends StatefulWidget {
  const ServiceHistoryDetailScreen({
    super.key,
    required this.summary,
  });

  final ServiceHistory summary;

  @override
  State<ServiceHistoryDetailScreen> createState() =>
      _ServiceHistoryDetailScreenState();
}

class _ServiceHistoryDetailScreenState extends State<ServiceHistoryDetailScreen> {
  final ServiceHistoryService _service = ServiceHistoryService();

  bool _loading = true;
  String? _error;
  late ServiceHistory _record;

  @override
  void initState() {
    super.initState();
    _record = widget.summary;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await _service.fetchServiceHistoryDetail(widget.summary.id);
      if (!mounted) return;
      setState(() {
        _record = _mergeDetail(widget.summary, detail);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  ServiceHistory _mergeDetail(ServiceHistory summary, ServiceHistory detail) {
    return ServiceHistory(
      id: detail.id.isNotEmpty ? detail.id : summary.id,
      serviceDate: detail.serviceDate ?? summary.serviceDate,
      grandTotal: detail.grandTotal > 0 ? detail.grandTotal : summary.grandTotal,
      vehicleId: detail.vehicleId.isNotEmpty ? detail.vehicleId : summary.vehicleId,
      odoReading: detail.odoReading > 0 ? detail.odoReading : summary.odoReading,
      vehicleName:
          detail.vehicleName.isNotEmpty ? detail.vehicleName : summary.vehicleName,
      licensePlate:
          detail.licensePlate.isNotEmpty ? detail.licensePlate : summary.licensePlate,
      totalPartsCost: detail.totalPartsCost > 0
          ? detail.totalPartsCost
          : summary.totalPartsCost,
      totalLaborCost: detail.totalLaborCost > 0
          ? detail.totalLaborCost
          : summary.totalLaborCost,
      discount: detail.discount > 0 ? detail.discount : summary.discount,
      serviceNames:
          detail.serviceNames.isNotEmpty ? detail.serviceNames : summary.serviceNames,
      items: detail.items.isNotEmpty ? detail.items : summary.items,
      billUrl: detail.billUrl ?? summary.billUrl,
      serviceInTime: detail.serviceInTime ?? summary.serviceInTime,
      serviceOutTime: detail.serviceOutTime ?? summary.serviceOutTime,
    );
  }

  Future<void> _openBill() async {
    final url = _record.billUrl?.trim();
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF43001E),
          content: Text(
            'Bill is not available for this service yet.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            'Could not open bill.',
            style: GoogleFonts.dmSans(color: Colors.white),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year} • $hour:$minute $period';
  }

  String _formatKm(int km) {
    if (km <= 0) return '—';
    final s = km.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf km';
  }

  String _formatMoney(double amount) => 'QAR ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final vehicleName = _record.vehicleName.trim().isEmpty
        ? 'Vehicle'
        : displayMakeNameForUi(_record.vehicleName);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF43001E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Service Bill',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFFB71C1C),
              onRefresh: _loadDetail,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: Text(
                        'Showing saved summary — full bill could not be loaded.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Card(
                    title: 'Service Date',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Color(0xFFB71C1C),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatDate(_record.serviceDate),
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    title: 'Vehicle & Service',
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.directions_car_outlined,
                          label: 'Vehicle',
                          value: vehicleName,
                        ),
                        if (_record.licensePlate.trim().isNotEmpty) ...[
                          const _RowDivider(),
                          _InfoRow(
                            icon: Icons.pin_outlined,
                            label: 'License Plate',
                            value: _record.licensePlate.toUpperCase(),
                          ),
                        ],
                        const _RowDivider(),
                        _InfoRow(
                          icon: Icons.speed_outlined,
                          label: 'Odometer',
                          value: _formatKm(_record.odoReading),
                        ),
                        if (_record.serviceInTime != null) ...[
                          const _RowDivider(),
                          _InfoRow(
                            icon: Icons.login_rounded,
                            label: 'Checked In',
                            value: _formatDateTime(_record.serviceInTime!),
                          ),
                        ],
                        if (_record.serviceOutTime != null) ...[
                          const _RowDivider(),
                          _InfoRow(
                            icon: Icons.logout_rounded,
                            label: 'Checked Out',
                            value: _formatDateTime(_record.serviceOutTime!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_record.serviceNames.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Card(
                      title: 'Services Performed',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _record.serviceNames
                            .map(
                              (name) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEFEF),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: const Color(0xFFF8CFCF),
                                  ),
                                ),
                                child: Text(
                                  name,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB71C1C),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ItemsSection(items: _record.items),
                  const SizedBox(height: 12),
                  _CostSummaryCard(record: _record, formatMoney: _formatMoney),
                  const SizedBox(height: 16),
                  GetStartedPrimaryButton(
                    width: double.infinity,
                    height: 48,
                    label: 'View Bill',
                    onPressed: _openBill,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.items});

  final List<LiveServiceItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _Card(
        title: 'Bill Details',
        child: Text(
          'Line items will appear here when the workshop adds them to your bill.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF9E9E9E),
            height: 1.4,
          ),
        ),
      );
    }

    return _Card(
      title: 'Bill Details',
      child: Column(
        children: [
          Row(
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
          ),
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
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF444444)),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            item.unitPrice == 0 ? '—' : _fmt(item.unitPrice),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF444444)),
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

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({
    required this.record,
    required this.formatMoney,
  });

  final ServiceHistory record;
  final String Function(double) formatMoney;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Bill Summary',
      child: Column(
        children: [
          if (record.hasCostBreakdown) ...[
            _CostRow(
              label: 'Parts Total',
              amount: record.totalPartsCost,
              formatMoney: formatMoney,
            ),
            const _RowDivider(),
            _CostRow(
              label: 'Labour Total',
              amount: record.totalLaborCost,
              formatMoney: formatMoney,
            ),
            if (record.discount > 0) ...[
              const _RowDivider(),
              _CostRow(
                label: 'Discount',
                amount: -record.discount,
                color: const Color(0xFF2E7D32),
                prefix: '-',
                formatMoney: formatMoney,
              ),
            ],
            const SizedBox(height: 10),
          ],
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
                  formatMoney(record.grandTotal),
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
    required this.formatMoney,
    this.color,
    this.prefix = '',
  });

  final String label;
  final double amount;
  final String Function(double) formatMoney;
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
            style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF666666)),
          ),
          Text(
            '$prefix${formatMoney(amount.abs())}',
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
            style: GoogleFonts.dmSans(fontSize: 12.5, color: const Color(0xFF666666)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
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
