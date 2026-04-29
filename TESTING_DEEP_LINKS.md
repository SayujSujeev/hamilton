# Deep Link Testing Guide

## Test 1: Verify Deep Link Configuration

Run this command to test if your app can handle deep links:

```bash
# Test custom scheme (should open your app)
adb shell am start -a android.intent.action.VIEW -d "hamiltoncarservice://oauth?token=test_token_123"
```

**Expected Result**: Your app should open and try to process the token.

## Test 2: Test HTTPS App Link

```bash
# Test https scheme (should open your app)
adb shell am start -a android.intent.action.VIEW -d "https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?token=test_token_456"
```

**Expected Result**: Your app should open (if app links are properly configured).

## Test 3: Check Installed Deep Links

```bash
# List all deep links registered by your app
adb shell dumpsys package com.hamilton.car.hamilton_car_service | grep -A 10 "filter"
```

**Expected Result**: You should see your intent filters listed.

## Test 4: Full OAuth Flow Test

1. **Open the app**
2. **Click "Continue with Google"**
3. **Observe**:
   - Chrome/system browser opens
   - You see Google sign-in page (no error 403)
4. **Sign in with Google**
5. **Observe**:
   - After signing in, check if app reopens automatically
   - If not, check browser URL - does it match your callback URL?

## Debugging Tips

### If deep link doesn't work:

1. **Reinstall the app** (deep links register on install):
   ```bash
   flutter clean
   flutter run
   ```

2. **Check AndroidManifest.xml**:
   - Verify intent filters are present
   - Check scheme, host, pathPrefix match your backend

3. **Check backend redirect**:
   - After OAuth, where does Google redirect?
   - Does it match your deep link configuration?

4. **View app logs**:
   ```bash
   adb logcat | grep -i "hamilton\|oauth\|deeplink"
   ```

### If browser opens but shows "No app found to handle this URL":

**Solution**: Use the custom scheme instead of https:

Backend should redirect to:
```
hamiltoncarservice://oauth?token=YOUR_JWT_TOKEN
```

Instead of:
```
https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?token=YOUR_JWT_TOKEN
```

## Manual Deep Link Injection (for testing)

If you want to test the callback handling without going through OAuth:

```dart
// In your app, you can manually trigger:
final authService = AuthService();
await authService.saveToken('test_token_123');

// Check if it's saved:
final token = await authService.getToken();
print('Saved token: $token');
```

## Expected Console Output (Success)

When deep link works correctly, you should see logs like:

```
D/FlutterActivity: Handling deep link: hamiltoncarservice://oauth?token=...
I/flutter: Received OAuth callback
I/flutter: Token extracted successfully
I/flutter: Navigating to next screen
```

## Common Issues

### 1. "App doesn't reopen after OAuth"
- **Cause**: Backend not redirecting to app
- **Fix**: Update backend to redirect to your deep link URL

### 2. "Multiple apps handle the URL"
- **Cause**: Another app uses same scheme
- **Fix**: Use unique custom scheme or configure app links

### 3. "Token is null"
- **Cause**: Token not in callback URL
- **Fix**: Backend must include token in URL query parameter

## Backend Callback Examples

### ✅ Correct (Token in URL):
```
hamiltoncarservice://oauth?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### ❌ Incorrect (No token):
```
hamiltoncarservice://oauth?status=success
```

### ✅ Also Correct (HTTPS with token):
```
https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?token=eyJhbGc...
```

## Testing Checklist

- [ ] App opens when running custom scheme command
- [ ] Deep links show in `dumpsys package` output
- [ ] Browser opens when clicking "Continue with Google"
- [ ] No error 403 in browser
- [ ] Google sign-in page loads
- [ ] After signing in, app reopens automatically
- [ ] Token is saved (check with AuthService)
- [ ] Navigate to next screen successfully

---

**Need Help?**
Check `FIX_GOOGLE_OAUTH_ERROR.md` and `GOOGLE_AUTH_INTEGRATION.md` for more details.
