import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../utils/auth_guard.dart';
import '../screens/home_screen.dart';
import '../models/vehicle_model.dart';

/// Example of how to use the authentication system in your app

// Example 1: Protecting a route with AuthGuard widget
class ProtectedScreen extends StatelessWidget {
  const ProtectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      loadingWidget: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      child: const HomeScreen(),
    );
  }
}

// Example 2: Using AuthenticatedRoute in navigation
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamilton Car Service',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return AuthenticatedRoute(
              builder: (context) => const HomeScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}

// Example 3: Manual authentication check
class ManualAuthCheck extends StatefulWidget {
  const ManualAuthCheck({super.key});

  @override
  State<ManualAuthCheck> createState() => _ManualAuthCheckState();
}

class _ManualAuthCheckState extends State<ManualAuthCheck> {
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await _authService.isAuthenticated();
    
    if (!isAuthenticated) {
      // Navigate to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

// Example 4: Using API client with authentication
class UserProfileExample extends StatefulWidget {
  const UserProfileExample({super.key});

  @override
  State<UserProfileExample> createState() => _UserProfileExampleState();
}

class _UserProfileExampleState extends State<UserProfileExample> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final json = await _apiClient.handleAuthErrors(
        () => _apiClient.getCurrentUser(),
      );
      final data = json['data'] as Map<String, dynamic>?;
      if (mounted) {
        setState(() {
          _userProfile = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _apiClient.handleAuthErrors(
        () => _apiClient.updateCurrentUser({
          'firstname': 'John',
          'lastname': 'Doe',
        }),
      );
      
      // Reload profile
      await _loadUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('No profile data')),
      );
    }

    final profile = _userProfile!;
    final displayName =
        '${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}'.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Name: ${displayName.isEmpty ? 'N/A' : displayName}'),
          Text('Email: ${profile['email'] ?? 'N/A'}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateProfile,
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}

// Example 5: Delete account functionality
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final authService = AuthService();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n'
          'This action is permanent and will remove all your data from KR4ALL. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Placeholder until account deletion API is available.
      await authService.clearToken();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been successfully deleted.'),
          ),
        );
      }
      
      // Navigate to login
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _deleteAccount(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('Delete Account'),
    );
  }
}

// Example 6: Custom API call with error handling
class VehiclesListExample extends StatefulWidget {
  const VehiclesListExample({super.key});

  @override
  State<VehiclesListExample> createState() => _VehiclesListExampleState();
}

class _VehiclesListExampleState extends State<VehiclesListExample> {
  final ApiClient _apiClient = ApiClient();
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _apiClient.handleAuthErrors(
        () => _apiClient.getUserVehicles(),
      );
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('Authentication expired')) {
        // Token expired, navigate to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        // Other error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      body: _vehicles.isEmpty
          ? const Center(child: Text('No vehicles found'))
          : ListView.builder(
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];
                return ListTile(
                  title: Text(vehicle.name),
                  subtitle: Text(vehicle.licensePlate),
                );
              },
            ),
    );
  }
}
