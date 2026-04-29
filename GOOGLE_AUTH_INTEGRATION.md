# Google OAuth2 Integration - System Browser Approach

## ✅ Fixed: Google OAuth Error 403

The Google OAuth integration now uses **system browser** instead of embedded WebView to comply with Google's "Use secure browsers" policy.

## Problem Solved

**Previous Issue**: Google blocked OAuth in embedded WebView with error:
- "Access blocked: hamilton-be's request does not comply with Google's policies"
- Error 403: disallowed_useragent

**Solution**: Use system browser (Chrome Custom Tabs) with deep link callback

## How It Works Now

1. User clicks "Continue with Google"
2. **System browser opens** with OAuth URL
3. User authenticates with Google in the browser
4. Google redirects to callback URL
5. **Deep link** brings user back to app
6. JWT token is extracted and stored
7. User navigated to next screen

## API Endpoints

### 1. Initiate Google OAuth Login
- **Endpoint**: `GET /api/v1/auth/google`
- **Description**: Opens in system browser
- **Response**: HTTP 302 Redirect to Google

### 2. OAuth Callback
- **Endpoint**: `GET /api/v1/auth/google/callback`
- **Description**: Receives callback, must return JWT token
- **Deep Link Schemes**:
  - `https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback`
  - `hamiltoncarservice://oauth` (custom scheme fallback)

## Implementation Files

### Services

#### `lib/services/auth_service.dart`
Updated to use system browser:
- `openGoogleAuthInBrowser()` - Opens OAuth in system browser
- `getDeepLinkStream()` - Listens for deep link callbacks
- `startListeningForCallback()` - Start listening for OAuth callback
- `stopListeningForCallback()` - Stop listening
- `saveToken()`, `getToken()`, `clearToken()` - Token management
- `extractTokenFromCallback()` - Extracts JWT from callback

#### `lib/services/api_client.dart`
Generic API client (unchanged):
- Automatically includes JWT token in Authorization header
- Provides methods for GET, POST, PUT, DELETE requests
- Handles authentication errors

### Screens

#### `lib/screens/continue_with_google_screen.dart`
Updated to use system browser:
- Opens system browser for OAuth
- Listens for deep link callbacks
- Shows "Complete sign-in in your browser" message
- Handles callback and navigates to next screen

### Configuration

#### Android Deep Link Setup (`AndroidManifest.xml`)

Two deep link configurations:

1. **App Link** (preferred - https):
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:scheme="https"
        android:host="hamilton-be-dev.vercel.app"
        android:pathPrefix="/api/v1/auth/google/callback"/>
</intent-filter>
```

2. **Custom Scheme** (fallback):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data
        android:scheme="hamiltoncarservice"
        android:host="oauth"/>
</intent-filter>
```

## Dependencies

```yaml
dependencies:
  url_launcher: ^6.2.5      # Opens system browser
  app_links: ^6.3.2         # Handles deep links (modern replacement for uni_links)
  http: ^1.2.0              # API requests
  flutter_secure_storage: ^9.0.0  # Secure token storage
```

## Backend Requirements

### Important: Your backend must support one of these callback methods:

**Option 1: Return token in URL query parameter** (Easiest)
```
https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?token=JWT_TOKEN_HERE
```

**Option 2: Return token in JSON response body**
```json
{
  "token": "JWT_TOKEN_HERE",
  "user": { ... }
}
```

**Option 3: Custom scheme redirect** (If app links don't work)
```
hamiltoncarservice://oauth?token=JWT_TOKEN_HERE
```

### Backend Configuration Checklist

1. **Add redirect URI to Google OAuth Console**:
   - `https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback`

2. **Callback endpoint should**:
   - Accept the Google OAuth code
   - Exchange code for tokens
   - Create/update user in database
   - Generate JWT token
   - Redirect back to app with token

3. **For Android App Links** (optional but recommended):
   - Host `.well-known/assetlinks.json` file on your domain
   - See: https://developer.android.com/training/app-links/verify-android-applinks

## Usage

### Check Authentication
```dart
final authService = AuthService();
final isLoggedIn = await authService.isAuthenticated();
```

### Make API Calls
```dart
final apiClient = ApiClient();
final response = await apiClient.get('/api/v1/user/profile');
final data = apiClient.parseJson(response);
```

### Logout
```dart
final authService = AuthService();
await authService.clearToken();
```

## Testing Steps

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Click "Continue with Google"**
   - System browser should open
   - Google sign-in page loads

3. **Complete sign-in**
   - Choose Google account
   - Grant permissions

4. **App should reopen automatically**
   - Deep link callback triggers
   - Token is stored
   - Navigate to next screen

## Troubleshooting

### Browser opens but app doesn't reopen

**Problem**: Deep links not configured properly

**Solution**:
1. Verify AndroidManifest.xml has deep link intent filters
2. Check backend redirects to correct callback URL
3. Test custom scheme: `adb shell am start -a android.intent.action.VIEW -d "hamiltoncarservice://oauth?token=test123"`

### "No app found to handle URL"

**Problem**: Deep link not registered

**Solution**:
1. Reinstall the app (deep links register on install)
2. Verify AndroidManifest.xml configuration
3. Use custom scheme as fallback

### Token not extracted

**Problem**: Backend not returning token properly

**Solution**:
1. Check backend callback response format
2. Add token to URL query parameter: `?token=JWT_HERE`
3. Or return JSON: `{"token": "JWT_HERE"}`
4. Check `extractTokenFromCallback()` logic matches backend format

### iOS Configuration

For iOS, add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.hamilton.car.hamiltoncarservice</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>hamiltoncarservice</string>
        </array>
    </dict>
</array>

<!-- For App Links (https scheme) -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:hamilton-be-dev.vercel.app</string>
</array>
```

## Security

✅ Uses system browser (Google approved)
✅ JWT tokens stored in secure storage
✅ HTTPS-only communication
✅ Automatic token cleanup on auth errors
✅ No embedded WebView vulnerabilities

## Advantages Over WebView

1. **Google Compliant** - No more 403 errors
2. **More Secure** - Uses system's trusted browser
3. **Better UX** - Users can see full Google branding
4. **Auto-fill Support** - Browser password managers work
5. **Session Reuse** - If already signed into Google in browser

## Notes

- `uni_links` package is discontinued but still works
- Consider migrating to `app_links` package in future
- Deep links work differently on Android vs iOS
- Test on real device for best results

---

**Status**: ✅ Fixed Google OAuth Error 403
**Method**: System Browser + Deep Link
**Compliant**: Google "Use secure browsers" policy
