# API Integration Quick Start

## What Was Done

The following API endpoints have been integrated into your Flutter app:

1. ✅ `POST /api/v1/auth/google/app` - Google authentication
2. ✅ `GET /api/v1/user` - Get current user profile
3. ✅ `PATCH /api/v1/user` - Update user profile
4. ✅ `GET /api/v1/user/vehicle` - Get user's vehicles

## Files Created

### Models (Data Structures)
- `lib/models/user_model.dart` - User data model
- `lib/models/vehicle_model.dart` - Vehicle data model

### Services (API Layer)
- `lib/services/user_service.dart` - High-level API for user & vehicles
- `lib/services/api_client.dart` - Updated with new endpoints

### Screens
- `lib/screens/home_screen_wrapper.dart` - Wraps HomeScreen with API integration

### Examples & Documentation
- `lib/examples/api_integration_example.dart` - Complete working example
- `API_INTEGRATION.md` - Comprehensive API documentation

## How to Use

### Step 1: Test with Example Screen

Add this to your app to test the integration:

```dart
// In your main.dart or any screen
import 'package:flutter/material.dart';
import 'examples/api_integration_example.dart';

// Add a button to test
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApiIntegrationExample(),
      ),
    );
  },
  child: const Text('Test API Integration'),
)
```

### Step 2: Use HomeScreenWrapper

Replace your home screen route with the wrapper:

```dart
// In your MaterialApp routes
MaterialApp(
  routes: {
    '/home': (context) => const HomeScreenWrapper(), // Use wrapper instead of HomeScreen
    // ... other routes
  },
);
```

The wrapper will:
- Automatically fetch user's vehicles on load
- Show loading indicator while fetching
- Display HomeScreen(hasVehicle: true) if vehicles exist
- Display HomeScreen(hasVehicle: false) if no vehicles
- Handle errors and authentication issues

### Step 3: Use Services Directly

To fetch data in any screen:

```dart
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

// In your StatefulWidget
final UserService _userService = UserService();

// Get user profile
Future<void> loadUser() async {
  try {
    final UserModel user = await _userService.getCurrentUser();
    print('User: ${user.firstname} ${user.lastname}');
  } catch (e) {
    print('Error: $e');
  }
}

// Get user vehicles
Future<void> loadVehicles() async {
  try {
    final List<VehicleModel> vehicles = await _userService.getUserVehicles();
    print('Found ${vehicles.length} vehicles');
  } catch (e) {
    print('Error: $e');
  }
}

// Update user profile
Future<void> updateProfile() async {
  try {
    final UserModel updatedUser = await _userService.updateUserProfile(
      firstname: 'New Name',
      mobileNo: '+1234567890',
    );
    print('Updated: ${updatedUser.firstname}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Complete Example Flow

Here's how the complete authentication and data flow works:

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class CompleteFlowExample extends StatefulWidget {
  const CompleteFlowExample({super.key});

  @override
  State<CompleteFlowExample> createState() => _CompleteFlowExampleState();
}

class _CompleteFlowExampleState extends State<CompleteFlowExample> {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();
  final UserService _userService = UserService();

  String _status = 'Ready';

  Future<void> _completeFlow() async {
    try {
      // Step 1: Sign in with Google
      setState(() => _status = 'Signing in with Google...');
      final idToken = await _authService.getGoogleIdToken();
      
      if (idToken == null) {
        setState(() => _status = 'Sign-in cancelled');
        return;
      }

      // Step 2: Authenticate with backend
      setState(() => _status = 'Authenticating with backend...');
      final jwtToken = await _apiClient.authenticateWithGoogleToken(idToken);
      
      if (jwtToken == null) {
        setState(() => _status = 'Backend authentication failed');
        return;
      }

      // Step 3: Save JWT token
      await _authService.saveToken(jwtToken);
      setState(() => _status = 'Authenticated successfully!');

      // Step 4: Fetch user profile
      setState(() => _status = 'Fetching user profile...');
      final UserModel user = await _userService.getCurrentUser();
      setState(() => _status = 'Welcome ${user.firstname}!');

      // Step 5: Fetch user vehicles
      setState(() => _status = 'Fetching vehicles...');
      final List<VehicleModel> vehicles = await _userService.getUserVehicles();
      setState(() => _status = 'Found ${vehicles.length} vehicle(s)');

      // Step 6: Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Flow Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _completeFlow,
              child: const Text('Start Complete Flow'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Authentication Status Check

Check if user is authenticated before making API calls:

```dart
import '../services/auth_service.dart';

Future<void> checkAuth(BuildContext context) async {
  final authService = AuthService();
  final isAuth = await authService.isAuthenticated();
  
  if (!isAuth) {
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
    return;
  }
  
  // User is authenticated, proceed with API calls
}
```

## Error Handling Patterns

### Pattern 1: Show SnackBar

```dart
try {
  final user = await _userService.getCurrentUser();
  // Success
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### Pattern 2: Redirect on Auth Error

```dart
try {
  final vehicles = await _userService.getUserVehicles();
  // Success
} catch (e) {
  if (e.toString().contains('Authentication expired')) {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  } else {
    // Handle other errors
  }
}
```

### Pattern 3: Show Error UI

```dart
String? _errorMessage;

try {
  final user = await _userService.getCurrentUser();
  setState(() => _errorMessage = null);
} catch (e) {
  setState(() => _errorMessage = e.toString());
}

// In build()
if (_errorMessage != null) {
  return ErrorWidget(_errorMessage!);
}
```

## Testing Checklist

- [ ] Test Google Sign-In flow
- [ ] Verify JWT token is stored
- [ ] Test GET user profile
- [ ] Test GET user vehicles
- [ ] Test PATCH user profile update
- [ ] Test error handling (401, network errors)
- [ ] Test authentication expiry flow
- [ ] Test with no vehicles (empty list)
- [ ] Test with multiple vehicles

## Common Issues

### Issue: "Invalid or missing authentication token"

**Solution:** User needs to login again. The app automatically clears the token and you should redirect to login screen.

### Issue: "Network error"

**Solution:** Check internet connectivity and ensure backend URL is correct.

### Issue: Google Sign-In fails

**Solution:** Verify `webClientId` in `auth_service.dart` matches your Google Cloud Console configuration.

## Next Steps

1. Test the integration using `ApiIntegrationExample`
2. Update your home screen to use `HomeScreenWrapper`
3. Add API calls to other screens as needed
4. Implement error handling UI
5. Add loading states
6. Implement pull-to-refresh

## Getting Help

- See `API_INTEGRATION.md` for comprehensive documentation
- Check `lib/examples/api_integration_example.dart` for working code
- Review existing services in `lib/services/` for patterns

## Summary

You now have:
- ✅ Complete Google authentication flow
- ✅ User profile fetch and update
- ✅ Vehicle list fetch
- ✅ Error handling with automatic token cleanup
- ✅ Type-safe models for all data
- ✅ High-level service layer for easy use
- ✅ Example screens showing best practices
- ✅ Comprehensive documentation

Start with `HomeScreenWrapper` or `ApiIntegrationExample` to see it in action!
