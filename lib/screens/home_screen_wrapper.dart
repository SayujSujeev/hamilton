import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'service_history_screen.dart';
import 'services_screen.dart';

/// Loads user data and hosts the main tab shell (Home / Services / History).
class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  List<VehicleModel>? _vehicles;
  String? _profileImageUrl;
  bool _isLoading = true;
  String? _errorMessage;
  MainTab _currentTab = MainTab.home;
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (!isAuthenticated) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final vehicles = await _userService.getUserVehicles();

      String? profileImageUrl;
      try {
        final user = await _userService.getCurrentUser();
        profileImageUrl = user.imageUrl;
      } catch (_) {
        // Profile is optional for home — vehicles can still render.
      }

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _profileImageUrl = profileImageUrl;
          _selectedVehicleId =
              vehicles.isNotEmpty ? vehicles.first.id : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }

      if (e.toString().contains('Authentication expired')) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    }
  }

  void _onSelectedVehicleChanged(String? vehicleId) {
    if (_selectedVehicleId == vehicleId) return;
    setState(() => _selectedVehicleId = vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load vehicles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadVehicles,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vehicles = _vehicles ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentTab.index,
              children: [
                HomeScreen(
                  vehicles: vehicles,
                  profileImageUrl: _profileImageUrl,
                  onOpenServices: () =>
                      setState(() => _currentTab = MainTab.services),
                  onSelectedVehicleChanged: _onSelectedVehicleChanged,
                ),
                ServicesScreen(
                  vehicles: vehicles,
                  userVehicleId: _selectedVehicleId,
                ),
                const ServiceHistoryScreen(),
              ],
            ),
          ),
          AppBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: (tab) => setState(() => _currentTab = tab),
          ),
        ],
      ),
    );
  }
}
