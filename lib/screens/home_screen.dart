import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/live_service.dart';
import '../models/vehicle_model.dart';
import '../services/auth_service.dart';
import '../services/live_service_service.dart';
import '../utils/brand_display_name.dart';
import '../widgets/brand_logo_badge.dart';
import '../widgets/get_started_primary_button.dart';
import '../widgets/live_service_mini_card.dart';
import 'add_first_vehicle_screen.dart';
import 'add_new_vehicle_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';
import 'upcoming_booking_detail_screen.dart';
import 'vehicle_detail_screen.dart';

String _formatLicensePlate(String plate) {
  final t = plate.trim();
  if (t.isEmpty) return '—';
  return t.replaceAll(' ', '').toUpperCase();
}

String _formatOdometerKm(int km) {
  if (km <= 0) return '—';
  final s = km.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${buf.toString()} km';
}

/// Short label for the hero vehicle chip: `make · plate` (or nickname · plate).
String _vehicleHeroChipLabel(VehicleModel v) {
  final plate = _formatLicensePlate(v.licensePlate);
  final vehicleName = v.name.trim();
  final nick = v.nickname?.trim();
  if (nick != null && nick.isNotEmpty) {
    final lead = nick.toLowerCase() == vehicleName.toLowerCase()
        ? displayMakeNameForUi(nick)
        : nick;
    return '$lead · $plate';
  }
  final brand = v.brandName.trim();
  if (brand.isEmpty) {
    if (vehicleName.isNotEmpty) {
      return '${displayMakeNameForUi(vehicleName)} · $plate';
    }
    return plate;
  }
  return '${displayMakeNameForUi(brand)} · $plate';
}

String _vehicleGarageSubtitle(VehicleModel v) {
  final year = v.manufacturedYear.trim().isEmpty ? '—' : v.manufacturedYear.trim();
  final odo = _formatOdometerKm(v.odoReading);
  final brand = v.brandName.trim().isEmpty
      ? '—'
      : displayMakeNameForUi(v.brandName);
  return '$brand  •  $year  •  $odo';
}

String _serviceDateLabel(DateTime? d) {
  if (d == null) return '—';
  const months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.vehicles = const [],
    this.profileImageUrl,
    this.onOpenServices,
    this.onSelectedVehicleChanged,
  });

  final List<VehicleModel> vehicles;
  final String? profileImageUrl;
  final VoidCallback? onOpenServices;
  final ValueChanged<String?>? onSelectedVehicleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedVehicleIndex = 0;
  List<LiveService> _liveServices = const [];
  final LiveServiceService _liveServiceService = LiveServiceService();

  /// Poll interval — checks for active services every 30 seconds so the
  /// mini card appears/disappears without requiring an app restart.
  static const _pollInterval = Duration(seconds: 30);
  bool _polling = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveServices();
    _startPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySelectedVehicle());
  }

  void _notifySelectedVehicle() {
    widget.onSelectedVehicleChanged?.call(_selectedVehicle?.id);
  }

  @override
  void dispose() {
    _polling = false;
    super.dispose();
  }

  void _startPolling() {
    _polling = true;
    Future.doWhile(() async {
      await Future<void>.delayed(_pollInterval);
      if (!_polling || !mounted) return false;
      await _fetchLiveServices();
      return _polling && mounted;
    });
  }

  Future<void> _fetchLiveServices() async {
    try {
      final services = await _liveServiceService.fetchLiveServices();
      if (!mounted) return;
      setState(() => _liveServices = services);
    } catch (_) {
      // silently ignore — live service is non-critical for home screen
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final n = widget.vehicles.length;
    if (n == 0) {
      _selectedVehicleIndex = 0;
    } else if (_selectedVehicleIndex >= n) {
      _selectedVehicleIndex = n - 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySelectedVehicle());
  }

  VehicleModel? get _selectedVehicle {
    final list = widget.vehicles;
    if (list.isEmpty) return null;
    final i = _selectedVehicleIndex.clamp(0, list.length - 1);
    return list[i];
  }

  /// Must match the height of [_HeroImageArea].
  static double _heroImageHeight(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return (screenH * 0.48).clamp(360.0, 420.0);
  }

  @override
  Widget build(BuildContext context) {
    final v = _selectedVehicle;
    if (v == null) {
      return _HomeWithoutVehicleScaffold(
        profileImageUrl: widget.profileImageUrl,
      );
    }

    final heroHeight = _heroImageHeight(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Stack(
        children: [
          SingleChildScrollView(
            // Extra bottom padding so content isn't hidden behind
            // the floating live-service card when it is visible.
            padding: _liveServices.isNotEmpty
                ? const EdgeInsets.only(bottom: 80)
                : EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroImageArea(
                  height: heroHeight,
                  vehicle: v,
                  onOpenGarage: () => _showGarageSheet(context),
                  profileImageUrl: widget.profileImageUrl,
                ),
                ColoredBox(
                  color: Colors.white,
                  child: _HeroDetailsSection(
                    vehicle: v,
                    allVehicles: widget.vehicles,
                  ),
                ),
                const ColoredBox(
                  color: Color(0xFFF4F4F4),
                  child: SizedBox(height: 12),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ActionButtonsRow(
                          userVehicleId: v.id,
                          vehicles: widget.vehicles,
                          onOpenServices: widget.onOpenServices,
                        ),
                        const SizedBox(height: 14),
                        const _PromoCard(),
                        const SizedBox(height: 14),
                        const _CarouselDots(),
                      ],
                    ),
                  ),
                ),
                const ColoredBox(
                  color: Colors.white,
                  child: SizedBox(height: 8),
                ),
              ],
            ),
          ),
          // Swiggy-style floating live-service card — sits above the
          // bottom nav bar, outside the scroll flow, always visible.
          if (_liveServices.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _liveServices
                    .map(
                      (ls) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          elevation: 10,
                          shadowColor: Colors.black38,
                          borderRadius: BorderRadius.circular(14),
                          child: LiveServiceMiniCard(liveService: ls),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showGarageSheet(BuildContext context) {
    final vehicles = widget.vehicles;
    if (vehicles.isEmpty) return;

    final sheetHeight = MediaQuery.sizeOf(context).height * 0.74;
    final selectedIdx = _selectedVehicleIndex;

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
                          Expanded(
                            child: ListView.separated(
                              itemCount: vehicles.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 24, color: Color(0xFFE9E9E9)),
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                return _VehicleOptionTile(
                                  vehicle: vehicle,
                                  selected: index == selectedIdx,
                                  onTap: () {
                                    setState(() => _selectedVehicleIndex = index);
                                    _notifySelectedVehicle();
                                    Navigator.of(sheetContext).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _GarageAddVehicleBar(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddNewVehicleScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _debugCopyBearerToken(BuildContext context) async {
  if (!kDebugMode) return;

  final token = await AuthService().getToken();
  if (!context.mounted) return;

  if (token == null || token.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bearer token found. Please sign in.')),
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: token));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Bearer token copied to clipboard (debug).')),
  );
}

class _HomeWithoutVehicleScaffold extends StatelessWidget {
  const _HomeWithoutVehicleScaffold({this.profileImageUrl});

  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 460,
              child: Stack(
                children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Color(0xFF43001E),
                              image: DecorationImage(
                                image: AssetImage('assets/images/no_vehicle_bg.png'),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: topInset + 10,
                          child: _NoVehicleTopBar(
                            profileImageUrl: profileImageUrl,
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
                            child: Column(
                              children: [
                                const Spacer(),
                                Image.asset(
                                  'assets/images/no_vehicle_car.png',
                                  width: 236,
                                  fit: BoxFit.contain,
                                ),
                                //const SizedBox(height: 12),
                                Text(
                                  'No Vehicles Added Yet!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSerifText(
                                    fontSize: 44 / 2,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF161616),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Add a vehicle to unlock booking, service\nhistory and smart reminders.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 230,
                                  height: 46,
                                  child: GetStartedPrimaryButton(
                                    width: double.infinity,
                                    height: 46,
                                    label: '+  Add Your First Vehicle',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const AddFirstVehicleScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF4F4F4),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _NoVehiclePromoCarousel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoVehiclePromoCarousel extends StatefulWidget {
  const _NoVehiclePromoCarousel();

  @override
  State<_NoVehiclePromoCarousel> createState() => _NoVehiclePromoCarouselState();
}

class _NoVehiclePromoCarouselState extends State<_NoVehiclePromoCarousel> {
  late final PageController _controller;
  int _currentIndex = 0;

  static const int _totalItems = 3;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 197,
          child: PageView.builder(
            controller: _controller,
            itemCount: _totalItems,
            onPageChanged: (index) {
              if (mounted) {
                setState(() => _currentIndex = index);
              }
            },
            itemBuilder: (_, __) => const _PromoCard(),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _totalItems,
            (index) => Padding(
              padding: EdgeInsets.only(right: index == _totalItems - 1 ? 0 : 5),
              child: _Dot(active: _currentIndex == index),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoVehicleTopBar extends StatelessWidget {
  const _NoVehicleTopBar({this.profileImageUrl});

  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            child: _ProfileAvatar(imageUrl: profileImageUrl),
          ),
          const Spacer(),
          GestureDetector(
            onLongPress: () => _debugCopyBearerToken(context),
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

// ─────────────────────────────────────────────────────────
// HERO DETAILS SECTION  (stats + view-details — scrolls with content)
// ─────────────────────────────────────────────────────────
class _HeroDetailsSection extends StatelessWidget {
  const _HeroDetailsSection({
    required this.vehicle,
    required this.allVehicles,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> allVehicles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ServiceStatsRow(vehicle: vehicle),
          const SizedBox(height: 12),
          _ViewDetailsButton(vehicle: vehicle),
          const SizedBox(height: 8),
          _UpcomingBookingDetailButton(
            vehicle: vehicle,
            vehicles: allVehicles,
          ),
        ],
      ),
    );
  }
}

class _HeroImageArea extends StatelessWidget {
  const _HeroImageArea({
    required this.height,
    required this.vehicle,
    required this.onOpenGarage,
    this.profileImageUrl,
  });

  final double height;
  final VehicleModel vehicle;
  final VoidCallback onOpenGarage;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
                children: [
                  _TopBadgesRow(
                    vehicle: vehicle,
                    onOpenGarage: onOpenGarage,
                    profileImageUrl: profileImageUrl,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _CarHeroBody(vehicle: vehicle),
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

class _TopBadgesRow extends StatelessWidget {
  const _TopBadgesRow({
    required this.vehicle,
    required this.onOpenGarage,
    this.profileImageUrl,
  });

  final VehicleModel vehicle;
  final VoidCallback onOpenGarage;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final chipLabel = _vehicleHeroChipLabel(vehicle);
    return SizedBox(
      height: 32,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: _ProfileAvatar(imageUrl: profileImageUrl),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenGarage,
                borderRadius: BorderRadius.circular(100),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.52,
                  ),
                  child: Ink(
                    width: double.infinity,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        BrandLogoBadge(
                          brandName: vehicle.brandName,
                          brandLogoUrl: vehicle.brandLogoUrl,
                          size: 16,
                          backgroundColor: const Color(0x33FFFFFF),
                          initialTextStyle: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chipLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onLongPress: () => _debugCopyBearerToken(context),
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
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim();
    final hasNetworkImage = trimmedUrl != null && trimmedUrl.isNotEmpty;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: hasNetworkImage
            ? Image.network(
                trimmedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/home_profile_picture.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/images/home_profile_picture.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _VehicleOptionTile extends StatelessWidget {
  const _VehicleOptionTile({
    required this.vehicle,
    required this.onTap,
    this.selected = false,
  });

  final VehicleModel vehicle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          BrandLogoBadge(
            brandName: vehicle.brandName,
            brandLogoUrl: vehicle.brandLogoUrl,
            size: 20,
            backgroundColor: const Color(0xFFFFF5E9),
            initialTextStyle: GoogleFonts.dmSans(
              fontSize: 10,
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
                  _formatLicensePlate(vehicle.licensePlate),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _vehicleGarageSubtitle(vehicle),
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

class _GarageAddVehicleBar extends StatelessWidget {
  const _GarageAddVehicleBar({required this.onPressed});

  final VoidCallback onPressed;

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
        width: double.infinity,
        height: 48,
        label: '+ Add New Vehicle',
        onPressed: onPressed,
      ),
    );
  }
}

class _CarHeroBody extends StatelessWidget {
  const _CarHeroBody({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final brand = vehicle.brandName.trim().isEmpty
        ? '—'
        : displayMakeNameForUi(vehicle.brandName);
    final model = vehicle.name.trim().isEmpty
        ? '—'
        : displayMakeNameForUi(vehicle.name);
    final url = vehicle.imageUrl?.trim();
    final hasNetworkImage = url != null && url.isNotEmpty;
    final screenW = MediaQuery.sizeOf(context).width;
    final carWidth = (screenW * 0.62).clamp(200.0, 280.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight > 0 ? constraints.maxHeight : 300,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 12,
                right: screenW * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      brand,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.1,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      model,
                      style: GoogleFonts.dmSerifText(
                        fontSize: screenW < 360 ? 40 : 48,
                        color: Colors.white,
                        height: 1.05,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: SizedBox(
                    width: carWidth,
                    height: carWidth * 0.72,
                    child: hasNetworkImage
                        ? Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/home_bmw_x5.png',
                              fit: BoxFit.contain,
                            ),
                          )
                        : Image.asset(
                            'assets/images/home_bmw_x5.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceStatsRow extends StatelessWidget {
  const _ServiceStatsRow({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final sd = vehicle.serviceDetails;
    final lastDate = _serviceDateLabel(sd?.lastServiceDate);
    final lastDur = (sd?.lastServiceDuration?.trim().isNotEmpty ?? false)
        ? sd!.lastServiceDuration!.trim()
        : '—';
    final avgDur = (sd?.avrgServiceDuration?.trim().isNotEmpty ?? false)
        ? sd!.avrgServiceDuration!.trim()
        : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatItem(
              title: 'Last Serviced On',
              value: lastDate,
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(title: 'Last Service Time', value: lastDur),
          ),
          const _StatDivider(),
          Expanded(
            child: _StatItem(title: 'Avg. Service Time', value: avgDur),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: Color(0xFFE0E0E0),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 10.5,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.vehicle});

  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VehicleDetailScreen(vehicle: vehicle),
            ),
          );
        },
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

class _UpcomingBookingDetailButton extends StatelessWidget {
  const _UpcomingBookingDetailButton({
    required this.vehicle,
    required this.vehicles,
  });

  final VehicleModel vehicle;
  final List<VehicleModel> vehicles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UpcomingBookingDetailScreen(
                vehicle: vehicle,
                vehicles: vehicles,
              ),
            ),
          );
        },
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
              'Upcoming Booking Details',
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
  const _ActionButtonsRow({
    required this.userVehicleId,
    required this.vehicles,
    this.onOpenServices,
  });

  final String userVehicleId;
  final List<VehicleModel> vehicles;
  final VoidCallback? onOpenServices;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DarkActionButton(
            icon: Icons.calendar_month_outlined,
            label: 'Book Service',
            imageAsset: 'assets/images/home_btn_book_service.png',
            onPressed: () {
              if (onOpenServices != null) {
                onOpenServices!();
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ServicesScreen(
                    userVehicleId: userVehicleId,
                    vehicles: vehicles,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
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
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final String? imageAsset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          GetStartedPrimaryButton(
            width: double.infinity,
            height: 52,
            label: '',
            onPressed: onPressed ?? () {},
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
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
