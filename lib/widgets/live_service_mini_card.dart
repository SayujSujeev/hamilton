import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/live_service.dart';
import '../screens/live_service_detail_screen.dart';

/// A compact tappable banner shown on the home screen when a vehicle
/// is actively being serviced. Tapping opens [LiveServiceDetailScreen].
class LiveServiceMiniCard extends StatefulWidget {
  const LiveServiceMiniCard({super.key, required this.liveService});

  final LiveService liveService;

  @override
  State<LiveServiceMiniCard> createState() => _LiveServiceMiniCardState();
}

class _LiveServiceMiniCardState extends State<LiveServiceMiniCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _dotScale;
  late final Animation<double> _ringFade;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _dotScale = Tween<double>(begin: 0.9, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _ringFade = Tween<double>(begin: 0.55, end: 0.10).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ls = widget.liveService;
    final plate = ls.licensePlate.trim().isEmpty
        ? 'Vehicle in workshop'
        : ls.licensePlate.toUpperCase();
    final subtitle = ls.serviceInTime != null
        ? 'Checked in ${_formatRelative(ls.serviceInTime!)}'
        : ls.customerName == '—'
            ? 'Tap to view live service details'
            : '${ls.customerName} • Tap to view details';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LiveServiceDetailScreen(liveService: ls),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FFF8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFE7C4)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Swiggy-like live pulse dot.
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Opacity(
                    opacity: _ringFade.value,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF12A94B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Transform.scale(
                    scale: _dotScale.value,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF12A94B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Live • ${ls.statusLabel}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F5132),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plate,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.5,
                      color: const Color(0xFF687076),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE9F7EC),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF12A94B),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatRelative(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}';
  }
}
