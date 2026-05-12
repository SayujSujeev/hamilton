import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/booking_cart_line.dart';
import '../models/vehicle_model.dart';
import '../utils/brand_display_name.dart';
import '../widgets/brand_logo_badge.dart';
import '../widgets/get_started_primary_button.dart';
import '../widgets/select_tyre_brand_sheet.dart';
import 'add_new_vehicle_screen.dart';
import 'booking_datetime_screen.dart';

String _servicesFormatLicensePlate(String plate) {
  final t = plate.trim();
  if (t.isEmpty) return '—';
  return t.replaceAll(' ', '').toUpperCase();
}

String _servicesVehicleTitleLine(VehicleModel v) {
  final brand =
      v.brandName.trim().isEmpty ? '' : displayMakeNameForUi(v.brandName);
  final model = v.name.trim().isEmpty ? '' : displayMakeNameForUi(v.name);
  final year = v.manufacturedYear.trim();
  final brandModel = [brand, model].where((e) => e.isNotEmpty).join(' ');
  if (brandModel.isEmpty) {
    return year.isEmpty ? 'Your vehicle' : year;
  }
  if (year.isEmpty) return brandModel;
  return '$brandModel  •  $year';
}

String _servicesVehicleSecondLine(VehicleModel v) {
  final plate = _servicesFormatLicensePlate(v.licensePlate);
  final note = v.noteText?.trim();
  if (note == null || note.isEmpty) return plate;
  return '$plate  •  $note';
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    this.vehicles = const [],
    this.userVehicleId,
  });

  /// Garage vehicles for this user (drives the vehicle card + booking `vehicle` id).
  final List<VehicleModel> vehicles;
  /// Initially selected vehicle row id (`VehicleModel.id`); defaults to first in [vehicles].
  final String? userVehicleId;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late int _selectedVehicleIndex;

  @override
  void initState() {
    super.initState();
    _selectedVehicleIndex = _initialVehicleIndex();
  }

  int _initialVehicleIndex() {
    final list = widget.vehicles;
    if (list.isEmpty) return 0;
    final id = widget.userVehicleId;
    if (id == null || id.isEmpty) return 0;
    final idx = list.indexWhere((v) => v.id == id);
    return idx >= 0 ? idx : 0;
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicles != widget.vehicles ||
        oldWidget.userVehicleId != widget.userVehicleId) {
      final n = widget.vehicles.length;
      setState(() {
        if (n == 0) {
          _selectedVehicleIndex = 0;
        } else {
          if (_selectedVehicleIndex >= n) {
            _selectedVehicleIndex = n - 1;
          }
          final id = widget.userVehicleId;
          if (id != null && id.isNotEmpty) {
            final idx = widget.vehicles.indexWhere((v) => v.id == id);
            if (idx >= 0) _selectedVehicleIndex = idx;
          }
        }
      });
    }
  }

  VehicleModel? get _selectedVehicle {
    final list = widget.vehicles;
    if (list.isEmpty) return null;
    final i = _selectedVehicleIndex.clamp(0, list.length - 1);
    return list[i];
  }

  String? get _selectedVehicleUserRowId => _selectedVehicle?.id;

  void _showVehiclePickerSheet(BuildContext context) {
    final vehicles = widget.vehicles;
    if (vehicles.isEmpty) return;

    final sheetHeight = MediaQuery.sizeOf(context).height * 0.62;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: Text(
                      'Your Garage',
                      style: GoogleFonts.dmSerifText(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1B1B1B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 22, color: Color(0xFFE9E9E9)),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        final selected = index == _selectedVehicleIndex;
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedVehicleIndex = index);
                            Navigator.of(sheetContext).pop();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                BrandLogoBadge(
                                  brandName: v.brandName,
                                  brandLogoUrl: v.brandLogoUrl,
                                  size: 22,
                                  backgroundColor: const Color(0xFFFFF5E9),
                                  initialTextStyle: GoogleFonts.dmSans(
                                    fontSize: 22 * 0.45,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF8A4E12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _servicesVehicleTitleLine(v),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F1F1F),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _servicesVehicleSecondLine(v),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF8C8C8C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF08A34D),
                                    size: 20,
                                  )
                                else
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFB5B5B5),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
                    ),
                    child: GetStartedPrimaryButton(
                      width: double.infinity,
                      height: 48,
                      label: '+ Add New Vehicle',
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AddNewVehicleScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
      fixedBookPrice: null,
      apiServiceTypeId: null,
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
      fixedBookPrice: 320,
      apiServiceTypeId: null,
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
      fixedBookPrice: 280,
      apiServiceTypeId: null,
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
      fixedBookPrice: 280,
      apiServiceTypeId: null,
    ),
  ];

  final Map<String, BookingCartLine> _cart = {};

  int get _selectedCount => _cart.length;

  double get _cartTotal =>
      _cart.values.fold<double>(0, (sum, line) => sum + line.amount);

  Future<void> _handleAddToCart(_ServiceItemData item) async {
    if (item.fixedBookPrice == null) {
      final result = await showSelectTyreBrandSheet(context);
      if (!mounted || result == null) return;
      setState(() {
        _cart[item.title] = BookingCartLine(
          title: item.title,
          amount: result.lineTotal,
          subtitle: '${result.brandName} × ${result.quantity}',
          serviceTypeId: item.apiServiceTypeId,
        );
      });
      return;
    }

    setState(() {
      _cart[item.title] = BookingCartLine(
        title: item.title,
        amount: item.fixedBookPrice!,
        serviceTypeId: item.apiServiceTypeId,
      );
    });
  }

  void _handleRemoveFromCart(String title) {
    setState(() => _cart.remove(title));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const _ServicesHeader(),
                  Transform.translate(
                    offset: const Offset(0, -26),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedVehicle != null)
                            _CurrentVehicleCard(
                              vehicle: _selectedVehicle!,
                              onChangeTap: () =>
                                  _showVehiclePickerSheet(context),
                            )
                          else
                            _NoVehicleServicesCard(
                              onAddVehicle: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const AddNewVehicleScreen(),
                                  ),
                                );
                              },
                            ),
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
                          for (int index = 0; index < _services.length; index++) ...[
                            if (index > 0) const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final item = _services[index];
                                final selected = _cart.containsKey(item.title);
                                return _ServiceCard(
                                  item: item,
                                  selected: selected,
                                  onAddTap: selected
                                      ? null
                                      : () => _handleAddToCart(item),
                                  onRemoveTap: selected
                                      ? () => _handleRemoveFromCart(item.title)
                                      : null,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BottomBookingBar(
            selectedCount: _selectedCount,
            total: _cartTotal,
            lines: _cart.values.toList(growable: false),
            onBookAll: _selectedCount > 0
                ? () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => BookingDateTimeScreen(
                          cartLines:
                              _cart.values.toList(growable: false),
                          total: _cartTotal,
                          userVehicleId: _selectedVehicleUserRowId,
                        ),
                      ),
                    );
                  }
                : null,
          ),
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF000000),
                  Color(0xFF1A0608),
                  Color(0xFF330808),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            right: -48,
            top: -12,
            bottom: -28,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/services_header_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          SafeArea(
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
        ],
      ),
    );
  }
}

class _CurrentVehicleCard extends StatelessWidget {
  const _CurrentVehicleCard({
    required this.vehicle,
    required this.onChangeTap,
  });

  final VehicleModel vehicle;
  final VoidCallback onChangeTap;

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
          BrandLogoBadge(
            brandName: vehicle.brandName,
            brandLogoUrl: vehicle.brandLogoUrl,
            size: 28,
            backgroundColor: const Color(0xFFFFF5E9),
            initialTextStyle: GoogleFonts.dmSans(
              fontSize: 28 * 0.45,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A4E12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _servicesVehicleTitleLine(vehicle),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _servicesVehicleSecondLine(vehicle),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onChangeTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Change',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFAA5757),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoVehicleServicesCard extends StatelessWidget {
  const _NoVehicleServicesCard({required this.onAddVehicle});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No vehicle on your profile',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a vehicle to book services and assign the booking to your car.',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF888888),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onAddVehicle,
              child: Text(
                'Add vehicle',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFAA5757),
                ),
              ),
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
    required this.fixedBookPrice,
    this.headerIconAsset,
    this.apiServiceTypeId,
  });

  final String title;
  final String duration;
  final String imageAsset;
  final String footerLabel;
  final IconData footerIcon;
  final Color glowColor;
  final Color gradientEndColor;
  final String? headerIconAsset;
  /// When null, booking opens the tyre brand sheet; otherwise tap adds this price.
  final double? fixedBookPrice;
  /// Backend `service_type` UUID when known (optional).
  final String? apiServiceTypeId;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.item,
    required this.selected,
    this.onAddTap,
    this.onRemoveTap,
  });

  final _ServiceItemData item;
  final bool selected;
  final VoidCallback? onAddTap;
  final VoidCallback? onRemoveTap;

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
                        : const Icon(
                            Icons.settings_outlined,
                            size: 24,
                            color: Color(0xFF333333),
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
                selected
                    ? Material(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: onRemoveTap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Remove',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.black,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onAddTap,
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(Icons.add, size: 20, color: Colors.white),
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

class _BottomBookingBar extends StatefulWidget {
  const _BottomBookingBar({
    required this.selectedCount,
    required this.total,
    required this.lines,
    this.onBookAll,
  });

  final int selectedCount;
  final double total;
  final List<BookingCartLine> lines;
  final VoidCallback? onBookAll;

  @override
  State<_BottomBookingBar> createState() => _BottomBookingBarState();
}

class _BottomBookingBarState extends State<_BottomBookingBar> {
  bool _expanded = false;

  @override
  void didUpdateWidget(_BottomBookingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCount == 0 && _expanded) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.selectedCount > 0;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F4F4),
          border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.selectedCount} Service${widget.selectedCount == 1 ? '' : 's'} Selected',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6D6D6D),
                                ),
                              ),
                            ),
                            if (hasSelection) ...[
                              InkWell(
                                onTap: () =>
                                    setState(() => _expanded = !_expanded),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Icon(
                                    _expanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 20,
                                    color: const Color(0xFF6D6D6D),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Q ${widget.total.toStringAsFixed(2)}',
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
                    child: hasSelection
                        ? GetStartedPrimaryButton(
                            width: 168,
                            height: 44,
                            label: 'Book All Services',
                            onPressed: widget.onBookAll,
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF9E9E9E),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                'Book All Services',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (_expanded && widget.lines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    ...widget.lines.map((line) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  if (line.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      line.subtitle!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF888888),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              'Q ${line.amount.toStringAsFixed(2)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF151515),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
