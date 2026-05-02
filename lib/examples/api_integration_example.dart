import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

/// Example widget demonstrating API integration
class ApiIntegrationExample extends StatefulWidget {
  const ApiIntegrationExample({super.key});

  @override
  State<ApiIntegrationExample> createState() => _ApiIntegrationExampleState();
}

class _ApiIntegrationExampleState extends State<ApiIntegrationExample> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (!isAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Not authenticated. Please login.';
        });
        return;
      }

      final user = await _userService.getCurrentUser();
      final vehicles = await _userService.getUserVehicles();

      setState(() {
        _currentUser = user;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (e.toString().contains('Authentication expired')) {
        _handleAuthenticationExpired();
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = await _userService.updateUserProfile(
        firstname: 'Updated Name',
        lastname: _currentUser!.lastname,
      );

      setState(() {
        _currentUser = updatedUser;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _handleAuthenticationExpired() {
    if (!mounted) return;
    
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentUser != null) ...[
                _buildUserSection(),
                const SizedBox(height: 24),
              ],
              _buildVehiclesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    final user = _currentUser!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _updateProfile,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (user.imageUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.imageUrl!),
              ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', '${user.firstname} ${user.lastname}'),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Username', user.username),
            if (user.mobileNo != null)
              _buildInfoRow('Mobile', user.mobileNo!),
            if (user.address != null)
              _buildInfoRow('Address', user.address!),
            _buildInfoRow('Status', user.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicles (${_vehicles.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_vehicles.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No vehicles found'),
              ),
            ),
          )
        else
          ..._vehicles.map((vehicle) => _buildVehicleCard(vehicle)),
      ],
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (vehicle.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      vehicle.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.directions_car, size: 80),
                    ),
                  )
                else
                  const Icon(Icons.directions_car, size: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicle.nickname != null)
                        Text(
                          vehicle.nickname!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(vehicle.brandName),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('License Plate', vehicle.licensePlate.toUpperCase()),
            _buildInfoRow('Year', vehicle.manufacturedYear),
            _buildInfoRow('Odometer', '${vehicle.odoReading} km'),
            if (vehicle.note != null)
              _buildInfoRow('Note', vehicle.note!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
