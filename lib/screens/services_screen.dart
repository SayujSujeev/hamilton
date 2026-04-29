import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<_ServiceItemData> _services = [
    _ServiceItemData(
      title: 'Tyre Replacement',
      duration: '45-90 min',
      imageAsset: 'assets/images/service_tyre_replacement.png',
      footerLabel: '3 Brands Available',
      footerIcon: Icons.info_outline,
      glowColor: Color(0xFF88F8E9),
      gradientEndColor: Color(0xFFE4FBF8),
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
    ),
    _ServiceItemData(
      title: 'Wheel Alignment',
      duration: '45-90 min',
      imageAsset: 'assets/images/service_wheel_alignment.png',
      footerLabel: 'From 280.00',
      footerIcon: Icons.local_offer_outlined,
      glowColor: Color(0xFFFCF3AB),
      gradientEndColor: Color(0xFFFBF6DC),
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
    ),
    _ServiceItemData(
      title: 'Wheel Balance',
      duration: '45-90 min',
      imageAsset: 'assets/images/service_wheel_balance.png',
      footerLabel: 'From 280.00',
      footerIcon: Icons.local_offer_outlined,
      glowColor: Color(0xFFA8B9FF),
      gradientEndColor: Color(0xFFE4E8FF),
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
    ),
    _ServiceItemData(
      title: 'Lubricants',
      duration: '45-90 min',
      imageAsset: 'assets/images/service_lubricants.png',
      footerLabel: '3 Brands Available',
      footerIcon: Icons.info_outline,
      glowColor: Color(0xFFFFA8B1),
      gradientEndColor: Color(0xFFFFF1F1),
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                const _ServicesHeader(),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -26),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CurrentVehicleCard(),
                          const SizedBox(height: 10),
                          const _SearchAndFilterRow(),
                          const SizedBox(height: 12),
                          Text(
                            'All Services',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF404040),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _services.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _ServiceCard(item: _services[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _BottomBookingBar(),
        ],
      ),
    );
  }
}

class _ServicesHeader extends StatelessWidget {
  const _ServicesHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 182,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/serviceheader.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Services',
                  style: GoogleFonts.dmSerifText(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select one or more services to book together.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentVehicleCard extends StatelessWidget {
  const _CurrentVehicleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/bmwsvg.svg', width: 28, height: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMW X5  •  2023',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'QA 1234  •  Pearl White',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Change',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFAA5757),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterRow extends StatelessWidget {
  const _SearchAndFilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Search',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: const Color(0xFFE2E2E2)),
                const SizedBox(width: 10),
                const Icon(Icons.search, size: 20, color: Color(0xFF4A4A4A)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E2E2)),
          ),
          child: const Icon(Icons.tune, size: 20, color: Color(0xFF4A4A4A)),
        ),
      ],
    );
  }
}

class _ServiceItemData {
  const _ServiceItemData({
    required this.title,
    required this.duration,
    required this.imageAsset,
    required this.footerLabel,
    required this.footerIcon,
    required this.glowColor,
    required this.gradientEndColor,
    this.headerIcon = Icons.settings_outlined,
    this.headerIconAsset,
  });

  final String title;
  final String duration;
  final String imageAsset;
  final String footerLabel;
  final IconData footerIcon;
  final Color glowColor;
  final Color gradientEndColor;
  final IconData headerIcon;
  final String? headerIconAsset;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});

  final _ServiceItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 340,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, item.gradientEndColor],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Glow blob behind image
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 220,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: item.glowColor.withValues(alpha: 0.85),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Service image
          Positioned(
            left: 12,
            right: 12,
            top: 72,
            bottom: 44,
            child: Image.asset(
              item.imageAsset,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          // Header row: icon + title/time + arrow
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: item.headerIconAsset != null
                        ? Image.asset(
                            item.headerIconAsset!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            item.headerIcon,
                            size: 24,
                            color: const Color(0xFF333333),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          color: const Color(0xFF1D1D1D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 12, color: Color(0xFF7A7A7A)),
                          const SizedBox(width: 4),
                          Text(
                            item.duration,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6F6F6F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east,
                    size: 16,
                    color: Color(0xFF3E3E3E),
                  ),
                ),
              ],
            ),
          ),
          // Footer: label + add button
          Positioned(
            left: 14,
            right: 12,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(item.footerIcon, size: 15, color: const Color(0xFF171717)),
                const SizedBox(width: 6),
                Text(
                  item.footerLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF171717),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  const _BottomBookingBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF4F4F4),
          border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0 Services Selected',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Q 0.00',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF151515),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 168,
              height: 44,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF4A4A4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Book All Services',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
