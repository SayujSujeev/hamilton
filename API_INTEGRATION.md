# API Integration Documentation

## Overview

This document explains how to integrate and use the Hamilton Car Service backend APIs in the Flutter app.

## Base URL

```
https://hamilton-be-dev.vercel.app
```

## Authentication

### Google Sign-In Flow

1. User signs in with Google using the native SDK
2. App receives an `id_token` from Google
3. App sends `id_token` to backend at `POST /api/v1/auth/google/app`
4. Backend validates the token and returns a JWT `access_token`
5. App stores the JWT securely using `flutter_secure_storage`
6. App includes JWT in `Authorization: Bearer <token>` header for all subsequent requests

### Code Example

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  final authService = AuthService();
  final apiClient = ApiClient();

  try {
    // Step 1: Get Google ID token
    final idToken = await authService.getGoogleIdToken();
    
    if (idToken == null) {
      // User cancelled sign-in
      return;
    }

    // Step 2: Authenticate with backend
    final jwtToken = await apiClient.authenticateWithGoogleToken(idToken);
    
    if (jwtToken == null) {
      throw Exception('Failed to authenticate with backend');
    }

    // Step 3: Save JWT token
    await authService.saveToken(jwtToken);

    // Step 4: Navigate to home screen
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    }
  }
}
```

## Available APIs

### 1. User Profile APIs

#### Get Current User Profile

**Endpoint:** `GET /api/v1/user`

**Description:** Fetches the profile of the currently authenticated user.

**Response:**
```json
{
  "message": "success",
  "error": null,
  "statusCode": 200,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "hamilton_dev",
    "firstname": "Hamilton",
    "lastname": "Engineer",
    "email": "hamilton@example.com",
    "gender": "male",
    "image_url": "https://api.dicebear.com/...",
    "role_id": 1,
    "address": "123, MG Road, Thrissur, Kerala, 680001, India",
    "is_active": true,
    "created_at": "2026-03-25T10:00:00Z",
    "updated_at": "2026-03-25T10:00:00Z"
  }
}
```

**Code Example:**

```dart
import '../services/user_service.dart';
import '../models/user_model.dart';

Future<void> loadUserProfile() async {
  final userService = UserService();
  
  try {
    final UserModel user = await userService.getCurrentUser();
    
    print('User: ${user.firstname} ${user.lastname}');
    print('Email: ${user.email}');
  } catch (e) {
    print('Error loading user: $e');
  }
}
```

#### Update Current User Profile

**Endpoint:** `PATCH /api/v1/user`

**Description:** Updates the profile of the currently authenticated user.

**Request Body:**
```json
{
  "firstname": "Hamilton",
  "lastname": "Dev",
  "gender": "male",
  "dob": "1998-01-01",
  "image_url": "https://avatar.url/image.png",
  "mobile_no": "973642687687",
  "whatsapp_no": "973642687687",
  "note": "any specific details",
  "address": "123, MG Road, Thrissur, Kerala, 680001, India"
}
```

**Response:** Same format as GET user (returns updated user object)

**Code Example:**

```dart
import '../services/user_service.dart';
import '../models/user_model.dart';

Future<void> updateUserProfile() async {
  final userService = UserService();
  
  try {
    final UserModel updatedUser = await userService.updateUserProfile(
      firstname: 'John',
      lastname: 'Doe',
      mobileNo: '+1234567890',
      address: '456 New Street, City, Country',
    );
    
    print('Profile updated: ${updatedUser.firstname}');
  } catch (e) {
    print('Error updating profile: $e');
  }
}
```

### 2. Vehicle APIs

#### Get User Vehicles

**Endpoint:** `GET /api/v1/user/vehicle`

**Description:** Fetches all vehicles belonging to the currently authenticated user.

**Response:**
```json
{
  "message": "success",
  "error": null,
  "statusCode": 200,
  "data": [
    {
      "id": "64f1c2af-ff9b-4996-8aaa-67d542edd9bb",
      "name": "Golf",
      "nickname": "Weekend Cruiser",
      "brand_name": "Volkswagen Group",
      "image_url": "https://example.com/images/car2.jpg",
      "note": "Used for highway trips.",
      "license_plate": "kl07a111",
      "manufactured_year": "2017",
      "odo_reading": 20222,
      "m_vehicle_id": "7637790d-a95a-4da2-8ebb-64cf31bec934",
      "t_user_id": "5a76f1ee-bc45-4132-8c9b-25cffb3b8eec",
      "created_by": "5a76f1ee-bc45-4132-8c9b-25cffb3b8eec",
      "updated_by": "5a76f1ee-bc45-4132-8c9b-25cffb3b8eec",
      "created_at": "2026-04-08T18:12:46.928Z",
      "updated_at": "2026-04-08T18:12:46.928Z",
      "is_active": true
    }
  ]
}
```

**Code Example:**

```dart
import '../services/user_service.dart';
import '../models/vehicle_model.dart';

Future<void> loadUserVehicles() async {
  final userService = UserService();
  
  try {
    final List<VehicleModel> vehicles = await userService.getUserVehicles();
    
    if (vehicles.isEmpty) {
      print('No vehicles found');
    } else {
      for (var vehicle in vehicles) {
        print('Vehicle: ${vehicle.name} (${vehicle.brandName})');
        print('License: ${vehicle.licensePlate}');
      }
    }
  } catch (e) {
    print('Error loading vehicles: $e');
  }
}
```

## Error Handling

### Common Error Codes

- `401` - Invalid or missing authentication token (user needs to login again)
- `403` - Forbidden (insufficient permissions)
- `404` - Resource not found
- `500` - Server error

### Error Response Format

```json
{
  "message": "error",
  "error": "Invalid or missing authentication token",
  "statusCode": 401,
  "data": null
}
```

### Handling Authentication Errors

The `ApiClient` includes automatic error handling that clears the token and throws an exception when authentication fails:

```dart
import '../services/user_service.dart';
import '../services/auth_service.dart';

Future<void> loadDataWithErrorHandling(BuildContext context) async {
  final userService = UserService();
  final authService = AuthService();
  
  try {
    final user = await userService.getCurrentUser();
    // Use the user data
  } catch (e) {
    if (e.toString().contains('Authentication expired')) {
      // Token was cleared automatically
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // Handle other errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
```

## Complete Integration Example

Here's a complete example showing how to integrate the APIs in a screen:

```dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../services/user_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserService _userService = UserService();
  
  UserModel? _user;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _userService.getCurrentUser();
      final vehicles = await _userService.getUserVehicles();
      
      setState(() {
        _user = user;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (e.toString().contains('Authentication expired')) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
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
      appBar: AppBar(
        title: Text('Welcome ${_user?.firstname ?? ''}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            if (_user != null) _buildUserCard(_user!),
            if (_vehicles.isNotEmpty) ..._vehicles.map(_buildVehicleCard),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return ListTile(
      leading: user.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(user.imageUrl!))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text('${user.firstname} ${user.lastname}'),
      subtitle: Text(user.email),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return ListTile(
      leading: const Icon(Icons.directions_car),
      title: Text('${vehicle.brandName} ${vehicle.name}'),
      subtitle: Text(vehicle.licensePlate.toUpperCase()),
      trailing: Text('${vehicle.odoReading} km'),
    );
  }
}
```

## File Structure

```
lib/
├── models/
│   ├── user_model.dart          # User data model
│   └── vehicle_model.dart       # Vehicle data model
├── services/
│   ├── auth_service.dart        # Google Sign-In & token storage
│   ├── api_client.dart          # Low-level HTTP client
│   └── user_service.dart        # High-level user/vehicle APIs
├── screens/
│   ├── home_screen.dart         # UI for home screen
│   └── home_screen_wrapper.dart # API integration wrapper
└── examples/
    └── api_integration_example.dart # Complete example

```

## Usage in Your App

### Option 1: Use HomeScreenWrapper (Recommended)

Update your routing to use the wrapper:

```dart
MaterialApp(
  routes: {
    '/home': (context) => const HomeScreenWrapper(),
    // ... other routes
  },
);
```

### Option 2: Manual Integration

If you prefer manual control, use the services directly:

```dart
import '../services/user_service.dart';

final userService = UserService();

// In your stateful widget
Future<void> _loadVehicles() async {
  final vehicles = await userService.getUserVehicles();
  setState(() {
    // Update your state
  });
}
```

## Testing

You can test the APIs using the provided example screen:

```dart
import 'examples/api_integration_example.dart';

// Navigate to the example
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ApiIntegrationExample(),
  ),
);
```

## Troubleshooting

### 401 Unauthorized Error

**Problem:** Getting "Invalid or missing authentication token"

**Solutions:**
1. Ensure user is logged in: `await authService.isAuthenticated()`
2. Check if token exists: `await authService.getToken()`
3. Re-authenticate if token expired

### Network Errors

**Problem:** API calls failing with network errors

**Solutions:**
1. Check internet connectivity
2. Verify base URL is correct in `api_client.dart`
3. Ensure backend is running and accessible

### Google Sign-In Fails

**Problem:** Google sign-in not working

**Solutions:**
1. Verify `webClientId` is correct in `auth_service.dart`
2. Check Google Cloud Console configuration
3. Ensure SHA-1/SHA-256 fingerprints are registered for Android

## Security Best Practices

1. JWT tokens are stored securely using `flutter_secure_storage`
2. Tokens are automatically included in API requests
3. Tokens are cleared on 401 errors
4. Never log or expose JWT tokens
5. Use HTTPS for all API communications (enforced by base URL)

## Next Steps

1. Implement remaining CRUD operations for vehicles
2. Add booking/service scheduling APIs
3. Implement real-time notifications
4. Add offline support with local caching
5. Implement API error retry logic
