import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/get_started_primary_button.dart';
import 'services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Must match the height of [_HeroImageArea].
  static const double _heroImageHeight = 408.0;

  /// Must match the laid-out height of [_HeroDetailsSection].
  static const double _heroDetailsHeight = 106.0;

  /// Gap between the white stats block and the action buttons.
  static const double _gapBelowHeroDetails = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ✅ Hero + Stats fixed behind everything
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _HeroImageArea(),
                ),

                // ✅ Stats strip fixed just below hero (gets covered when scrolling)
                Positioned(
                  top: _heroImageHeight,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.white,
                    elevation: 0,
                    child: const _HeroDetailsSection(),
                  ),
                ),

                // ✅ Scroll content slides OVER both hero AND stats
                Positioned.fill(
                  child: SingleChildScrollView(
                    hitTestBehavior: HitTestBehavior.deferToChild,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Spacer = hero + stats height so card starts just below stats
                        const SizedBox(
                          height:
                              _heroImageHeight +
                              _heroDetailsHeight +
                              _gapBelowHeroDetails,
                        ),
                        // ✅ White card — covers stats when scrolled up
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _ActionButtonsRow(),
                                SizedBox(height: 14),
                                _PromoCard(),
                                SizedBox(height: 14),
                                _CarouselDots(),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _BottomNavBar(),
        ],
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF4F4F4),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: Stack(
  //             clipBehavior: Clip.hardEdge,
  //             children: [
  //               // Hero stays fixed behind scroll.
  //               const Positioned(
  //                 top: 0,
  //                 left: 0,
  //                 right: 0,
  //                 child: _HeroImageArea(),
  //               ),
  //               // Stats strip + buttons + promo scroll together.
  //               Positioned.fill(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: [
  //                     const SizedBox(height: _heroImageHeight),
  //                     Expanded(
  //                       child: ClipRect(
  //                         child: SingleChildScrollView(
  //                           padding: EdgeInsets.zero,
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.stretch,
  //                             children: [
  //                               Material(
  //                                 color: Colors.white,
  //                                 elevation: 2,
  //                                 shadowColor: Colors.black26,
  //                                 child: const _HeroDetailsSection(),
  //                               ),
  //                               const SizedBox(height: _gapBelowHeroDetails),
  //                               Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   horizontal: 16,
  //                                 ),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.stretch,
  //                                   children: const [
  //                                     _ActionButtonsRow(),
  //                                     SizedBox(height: 14),
  //                                     _PromoCard(),
  //                                     SizedBox(height: 14),
  //                                     _CarouselDots(),
  //                                     SizedBox(height: 24),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const _BottomNavBar(),
  //       ],
  //     ),
  //   );
  // }
}

// ─────────────────────────────────────────────────────────
// HERO DETAILS SECTION  (stats + view-details — scrolls with content)
// ─────────────────────────────────────────────────────────
class _HeroDetailsSection extends StatelessWidget {
  const _HeroDetailsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ServiceStatsRow(),
          SizedBox(height: 12),
          _ViewDetailsButton(),
        ],
      ),
    );
  }
}

class _HeroImageArea extends StatelessWidget {
  const _HeroImageArea();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 408,
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFF43001E))),
          Positioned.fill(
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/home_hero_bg.png',
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.sizeOf(context).width,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TopBadgesRow(),
                  SizedBox(height: 8),
                  _CarHeroBody(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBadgesRow extends StatelessWidget {
  const _TopBadgesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 32,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/home_profile_picture.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showChangeVehiclePopup(context),
                borderRadius: BorderRadius.circular(100),
                child: Ink(
                  width: 117,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/bmwsvg.svg',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'QA 1234',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
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

void _showChangeVehiclePopup(BuildContext context) {
  final sheetHeight = MediaQuery.sizeOf(context).height * 0.74;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    transitionAnimationController: BottomSheet.createAnimationController(
      Navigator.of(context),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    ),
    builder: (context) {
      return SizedBox(
        height: sheetHeight,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Garage',
                          style: GoogleFonts.dmSerifText(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _VehicleOptionTile(
                          plate: 'QA 1234',
                          details: 'BMW X5  •  2023  •  18,500 km',
                          iconType: _VehicleIconType.bmw,
                          selected: true,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Divider(height: 24, color: Color(0xFFE9E9E9)),
                        _VehicleOptionTile(
                          plate: 'QA 9876',
                          details: 'Porsche Cayenne  •  2022  •  3000 km',
                          iconType: _VehicleIconType.porsche,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Divider(height: 24, color: Color(0xFFE9E9E9)),
                        _VehicleOptionTile(
                          plate: 'QA 9876',
                          details: 'BMW X7  •  2024  •  16,000 km',
                          iconType: _VehicleIconType.bmw,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
                const _AddVehicleBottomAction(),
              ],
            ),
          ),
        ),
      );
    },
  );
}

enum _VehicleIconType { bmw, porsche }

class _VehicleOptionTile extends StatelessWidget {
  const _VehicleOptionTile({
    required this.plate,
    required this.details,
    required this.onTap,
    required this.iconType,
    this.selected = false,
  });

  final String plate;
  final String details;
  final VoidCallback onTap;
  final _VehicleIconType iconType;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          _VehicleBrandBadge(iconType: iconType),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plate,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8C8C8C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (selected)
            const Icon(Icons.check_circle, color: Color(0xFF08A34D), size: 18)
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB5B5B5), width: 1.2),
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleBrandBadge extends StatelessWidget {
  const _VehicleBrandBadge({required this.iconType});

  final _VehicleIconType iconType;

  @override
  Widget build(BuildContext context) {
    if (iconType == _VehicleIconType.bmw) {
      return SvgPicture.asset(
        'assets/images/bmwsvg.svg',
        width: 20,
        height: 20,
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF5E9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'P',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8A4E12),
        ),
      ),
    );
  }
}

class _AddVehicleBottomAction extends StatelessWidget {
  const _AddVehicleBottomAction();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: GetStartedPrimaryButton(
        width: 358,
        height: 48,
        label: '+ Add New Vehicle',
        onPressed: () {},
      ),
    );
  }
}

class _CarHeroBody extends StatelessWidget {
  const _CarHeroBody();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 20,
            child: SizedBox(
              width: 147,
              height: 128,
              child: Text(
                'BMW\nX5',
                style: GoogleFonts.dmSerifText(
                  fontSize: 64,
                  color: Colors.white,
                  height: 1.0,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 40,
            top: 132,
            width: 249,
            height: 180,
            child: Image.asset(
              'assets/images/home_bmw_x5.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFB3001E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Positioned(
          //   left: 86,
          //   right: 22,
          //   bottom: 12,
          //   child: Container(
          //     height: 10,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(100),
          //       color: const Color(0xFF2A0016).withValues(alpha: 0.30),
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFF2A0016).withValues(alpha: 0.22),
          //           blurRadius: 18,
          //           spreadRadius: 3,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _ServiceStatsRow extends StatelessWidget {
  const _ServiceStatsRow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 358,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _StatItem(
              title: 'Last Serviced On',
              value: '12 Oct 2025',
              titleWidth: 95,
              titleHeight: 14,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StatItem(title: 'Last Service Time', value: '1 h 32 mins'),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _StatItem(title: 'Avg. Service Time', value: '1 h 32 mins'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
    this.titleWidth,
    this.titleHeight,
  });

  final String title;
  final String value;
  final double? titleWidth;
  final double? titleHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: titleWidth,
          height: titleHeight,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 358,
      height: 40,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF222222),
          side: const BorderSide(color: Color(0xFFBEBEBE), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View Vehicle Details',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────────────────
class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 157,
          child: _DarkActionButton(
            icon: Icons.calendar_month_outlined,
            label: 'Book Service',
            imageAsset: 'assets/images/home_btn_book_service.png',
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 163,
          child: _DarkActionButton(
            icon: Icons.local_shipping_outlined,
            label: 'Schedule Pickup',
            imageAsset: 'assets/images/home_btn_schedule_pickup.png',
          ),
        ),
      ],
    );
  }
}

class _DarkActionButton extends StatelessWidget {
  const _DarkActionButton({
    required this.icon,
    required this.label,
    this.imageAsset,
  });

  final IconData icon;
  final String label;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          GetStartedPrimaryButton(
            width: double.infinity,
            height: 70,
            label: '',
            onPressed: () {},
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────
// PROMO CARD
// ─────────────────────────────────────────────────────────
class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 197,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_promo_bg_custom.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Car image on the right
            Positioned(
              right: -20,
              bottom: 0,
              top: 6,
              child: Image.asset(
                'assets/images/home_promo_car_custom.png',
                width: 178,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
            // Promo text block
            Positioned(
              left: 24,
              top: 40,
              child: SizedBox(
                width: 176,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get 20% Off Your\nFirst Service!',
                      style: GoogleFonts.dmSerifText(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        height: 1.3,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// CAROUSEL DOTS
// ─────────────────────────────────────────────────────────
class _CarouselDots extends StatelessWidget {
  const _CarouselDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: true),
        SizedBox(width: 5),
        _Dot(),
        SizedBox(width: 5),
        _Dot(),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 18 : 18,
      height: 5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1A1A1A) : const Color(0xFFBBBBBB),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              active: true,
            ),
            _NavItem(
              icon: Icons.handyman_outlined,
              label: 'Services',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ServicesScreen(),
                  ),
                );
              },
            ),
            const _NavItem(icon: Icons.shopping_bag_outlined, label: 'Shop'),
            const _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF111111) : const Color(0xFF999999);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
