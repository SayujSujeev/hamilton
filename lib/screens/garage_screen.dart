import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/get_started_primary_button.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
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
                    _VehicleListTile(
                      plate: 'QA 1234',
                      details: 'BMW X5  •  2023  •  18,500 km',
                      brandAsset: 'assets/images/bmwsvg.svg',
                      isSelected: true,
                    ),
                    const SizedBox(height: 14),
                    const _VehicleListTile(
                      plate: 'QA 9876',
                      details: 'Porsche Cayenne  •  2022  •  3000 km',
                      fallbackBadgeLabel: 'P',
                      isSelected: false,
                    ),
                    const SizedBox(height: 14),
                    _VehicleListTile(
                      plate: 'QA 9876',
                      details: 'BMW X7  •  2024  •  16,000 km',
                      brandAsset: 'assets/images/bmwsvg.svg',
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ),
            const _AddVehicleBottomAction(),
          ],
        ),
      ),
    );
  }
}

class _VehicleListTile extends StatelessWidget {
  const _VehicleListTile({
    required this.plate,
    required this.details,
    required this.isSelected,
    this.brandAsset,
    this.fallbackBadgeLabel,
  });

  final String plate;
  final String details;
  final bool isSelected;
  final String? brandAsset;
  final String? fallbackBadgeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BrandBadge(assetPath: brandAsset, label: fallbackBadgeLabel ?? 'B'),
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
        _VehicleSelectionIndicator(selected: isSelected),
      ],
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.assetPath, required this.label});

  final String? assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: assetPath == null
          ? Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7A7A7A),
              ),
            )
          : SvgPicture.asset(
              assetPath!,
              width: 16,
              height: 16,
            ),
    );
  }
}

class _VehicleSelectionIndicator extends StatelessWidget {
  const _VehicleSelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return const Icon(Icons.check_circle, color: Color(0xFF0BA854), size: 18);
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFB5B5B5),
          width: 1.2,
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: const GetStartedPrimaryButton(
        width: 358,
        height: 48,
        label: '+ Add New Vehicle',
        onPressed: _onAddVehiclePressed,
      ),
    );
  }

  static void _onAddVehiclePressed() {}
}
