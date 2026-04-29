import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/get_started_primary_button.dart';
import 'add_new_vehicle_screen.dart';
import 'home_screen.dart';

class AddFirstVehicleScreen extends StatelessWidget {
  const AddFirstVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            const _TopHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  children: const [
                    _BenefitTile(
                      title: 'Full Service History',
                      subtitle:
                          'Track all your services in one place, all in one click',
                      icon: Icons.receipt_long_outlined,
                    ),
                    SizedBox(height: 12),
                    _BenefitTile(
                      title: 'Smart Reminders',
                      subtitle:
                          'Never miss registration renewal due date',
                      icon: Icons.notifications_none_outlined,
                    ),
                    SizedBox(height: 12),
                    _BenefitTile(
                      title: 'Priority Pickup',
                      subtitle: 'Schedule driver pickup with no waiting',
                      icon: Icons.local_shipping_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSkipPopup(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    foregroundColor: const Color(0xFF2B2B2B),
                  ),
                  child: Text(
                    'Skip For Now',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GetStartedPrimaryButton(
                  width: double.infinity,
                  height: 48,
                  label: 'Add Vehicle',
                  onPressed: () => _goToAddVehicle(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  static void _goToAddVehicle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddNewVehicleScreen()),
    );
  }

  static Future<void> _showSkipPopup(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8B8B8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFA14E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.priority_high_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Skip For Now?',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Without a vehicle, you can\'t book services\nor request pickup. Add your vehicle from\nthe Home screen.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A8A8A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _goToHome(context);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              side: const BorderSide(color: Color(0xFFBBBBBB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              foregroundColor: const Color(0xFF2F2F2F),
                            ),
                            child: Text(
                              'Go to Home',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GetStartedPrimaryButton(
                            width: double.infinity,
                            height: 40,
                            label: '+ Add Vehicle',
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              _goToAddVehicle(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 255,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/registration_header_background.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
              ),
            ),
          ),
          Positioned(
            right: -90,
            top: 18,
            child: Image.asset(
              'assets/images/registration_hero_car.png',
              width: 300,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 24,
            child: IconButton(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Your First\nVehicle Now !',
                  style: GoogleFonts.dmSerifText(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Unlock service booking, history tracking\nand priority support.',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
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

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF535353)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF1F1F1F),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF828282),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
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
