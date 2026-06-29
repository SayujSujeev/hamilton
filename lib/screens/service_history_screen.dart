import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/service_history.dart';
import '../services/invoice_service.dart';
import '../services/service_history_service.dart';
import '../utils/brand_display_name.dart';
import '../widgets/get_started_primary_button.dart';
import 'service_history_detail_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final ServiceHistoryService _service = ServiceHistoryService();
  final InvoiceService _invoiceService = InvoiceService();

  bool _loading = true;
  String? _error;
  List<ServiceHistory> _history = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await _service.fetchServiceHistory();
      if (!mounted) return;
      rows.sort((a, b) {
        final ad = a.serviceDate;
        final bd = b.serviceDate;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      setState(() {
        _history = rows;
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

  void _openDetail(ServiceHistory item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceHistoryDetailScreen(summary: item),
      ),
    );
  }

  Future<void> _openBill(ServiceHistory item) async {
    try {
      await _invoiceService.openBill(item);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (message.contains('not available')) {
        _openDetail(item);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            message,
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

  String _formatOdo(int km) {
    if (km <= 0) return '—';
    return '$km km';
  }

  String _formatTotal(double total) => 'QAR ${total.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF43001E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Service History',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFB71C1C),
        onRefresh: _loadHistory,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 56),
          const SizedBox(height: 12),
          Text(
            'Could not load history',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.35,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GetStartedPrimaryButton(
              width: 160,
              height: 46,
              label: 'Retry',
              onPressed: _loadHistory,
            ),
          ),
        ],
      );
    }

    if (_history.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No service history yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed services will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _history[index];
        return _HistoryCard(
          item: item,
          dateLabel: _formatDate(item.serviceDate),
          odoLabel: _formatOdo(item.odoReading),
          totalLabel: _formatTotal(item.grandTotal),
          onTap: () => _openDetail(item),
          onViewBill: () => _openBill(item),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.dateLabel,
    required this.odoLabel,
    required this.totalLabel,
    required this.onTap,
    required this.onViewBill,
  });

  final ServiceHistory item;
  final String dateLabel;
  final String odoLabel;
  final String totalLabel;
  final VoidCallback onTap;
  final VoidCallback onViewBill;

  @override
  Widget build(BuildContext context) {
    final vehicleName = item.vehicleName.trim().isEmpty
        ? 'Vehicle'
        : displayMakeNameForUi(item.vehicleName);

    final servicePreview = item.serviceNames.isNotEmpty
        ? item.serviceNames.take(2).join(' • ')
        : (item.hasItems
            ? '${item.items.length} bill item${item.items.length == 1 ? '' : 's'}'
            : 'Tap for bill & service details');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
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
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEFEF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFB71C1C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleName,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Service date • $dateLabel',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bill total',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      Text(
                        totalLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1B1B1B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                servicePreview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  height: 1.35,
                  color: const Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetaChip(icon: Icons.speed_outlined, label: odoLabel),
                  if (item.licensePlate.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.pin_outlined,
                      label: item.licensePlate.toUpperCase(),
                    ),
                  ],
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onViewBill,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      'View Bill',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF666666)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
