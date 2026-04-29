# Google Login Integration - Quick Start Guide

## Summary

The Google OAuth2 login integration has been successfully implemented in the Hamilton Car Service app. The integration uses a backend API to handle OAuth flow and returns a JWT token for authenticated requests.

## What Was Implemented

### 1. **Dependencies Added** (pubspec.yaml)
- `webview_flutter: ^4.5.0` - For OAuth WebView
- `http: ^1.2.0` - For HTTP requests
- `flutter_secure_storage: ^9.0.0` - For secure token storage

### 2. **Services Created**

#### AuthService (`lib/services/auth_service.dart`)
Core authentication service that handles:
- Google OAuth URL generation
- JWT token storage and retrieval
- Authentication status checks
- Token extraction from OAuth callback
- Logout functionality

#### ApiClient (`lib/services/api_client.dart`)
Generic API client for authenticated HTTP requests:
- Automatic JWT token inclusion in headers
- HTTP methods: GET, POST, PUT, DELETE
- Error handling with automatic token cleanup on 401/403
- Helper methods for JSON parsing

### 3. **Screens Created/Updated**

#### ContinueWithGoogleScreen (Updated)
- Changed from StatelessWidget to StatefulWidget
- Added `_handleGoogleSignIn()` method
- Shows loading indicator during authentication
- Handles OAuth flow navigation
- Displays error messages on failure

#### GoogleOAuthWebViewScreen (New)
- Full-screen WebView for OAuth flow
- Monitors navigation for callback URL
- Extracts JWT token from callback
- Shows loading indicator
- Handles errors gracefully

### 4. **Utilities Created**

#### AuthGuard (`lib/utils/auth_guard.dart`)
- Widget wrapper for protected routes
- Automatic redirect to login if not authenticated
- Custom loading widget support
- AuthenticatedRoute for route-based protection

### 5. **Configuration Updates**

#### Android (AndroidManifest.xml)
Added required permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 6. **Documentation**
- `GOOGLE_AUTH_INTEGRATION.md` - Full integration documentation
- `lib/examples/auth_usage_examples.dart` - Usage examples

## How to Use

### Basic Authentication Flow

1. **User clicks "Continue with Google"**
   ```dart
   // This is already implemented in ContinueWithGoogleScreen
   ```

2. **WebView opens with Google OAuth**
   ```dart
   // Automatically handled by GoogleOAuthWebViewScreen
   ```

3. **JWT token is stored securely**
   ```dart
   final authService = AuthService();
   final token = await authService.getToken();
   ```

### Making Authenticated API Calls

```dart
final apiClient = ApiClient();

// Get data
final response = await apiClient.get('/api/v1/user/profile');
final data = apiClient.parseJson(response);

// Post data
final response = await apiClient.post('/api/v1/vehicles', body: {
  'make': 'BMW',
  'model': 'X5',
});
```

### Protecting Routes

```dart
// Using AuthGuard widget
AuthGuard(
  child: const HomeScreen(),
)

// Using AuthenticatedRoute
AuthenticatedRoute(
  builder: (context) => const HomeScreen(),
)
```

### Logout

```dart
final authService = AuthService();
await authService.clearToken();
Navigator.of(context).pushReplacementNamed('/login');
```

## API Endpoints Used

- **Initiate OAuth**: `GET https://hamilton-be-dev.vercel.app/api/v1/auth/google`
- **OAuth Callback**: `GET https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback`

## Testing the Integration

1. Run the app:
   ```bash
   flutter run
   ```

2. Navigate to the "Continue with Google" screen

3. Click the "Continue with Google" button

4. Complete Google authentication

5. Verify redirection to PersonalDetailsScreen

6. Check token storage:
   ```dart
   final authService = AuthService();
   final token = await authService.getToken();
   print('Token: $token');
   ```

## Security Features

✅ JWT tokens stored in secure storage (Keychain/KeyStore)
✅ HTTPS-only communication
✅ Automatic token cleanup on authentication errors
✅ No token exposure in logs (use secure storage)

## Files Modified/Created

### Created:
- `lib/services/auth_service.dart`
- `lib/services/api_client.dart`
- `lib/screens/google_oauth_webview_screen.dart`
- `lib/utils/auth_guard.dart`
- `lib/examples/auth_usage_examples.dart`
- `GOOGLE_AUTH_INTEGRATION.md`
- `QUICKSTART.md` (this file)

### Modified:
- `pubspec.yaml` - Added dependencies
- `lib/screens/continue_with_google_screen.dart` - Implemented OAuth flow
- `android/app/src/main/AndroidManifest.xml` - Added permissions

## Next Steps

1. **Test the integration** with a real device or emulator
2. **Implement token refresh** if your backend supports it
3. **Add error logging** for production monitoring
4. **Test error scenarios** (network failures, token expiration)
5. **Add biometric authentication** for enhanced security (optional)

## Troubleshooting

### WebView not loading?
- Check INTERNET permission in AndroidManifest.xml
- Verify network connectivity
- Ensure API URL is correct

### Token not saving?
- Check device storage permissions
- Verify flutter_secure_storage initialization
- Look for exceptions in console logs

### Authentication fails?
- Verify backend API is running and accessible
- Check callback URL configuration
- Inspect WebView console for errors

### iOS specific issues?
- Add NSAppTransportSecurity to Info.plist
- For development, allow arbitrary loads

## Support

For detailed documentation, see `GOOGLE_AUTH_INTEGRATION.md`

For usage examples, see `lib/examples/auth_usage_examples.dart`
