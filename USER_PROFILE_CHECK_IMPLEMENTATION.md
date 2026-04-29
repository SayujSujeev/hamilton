# ✅ OAuth Flow with User Profile Check - Complete

## What Was Implemented

After successful Google OAuth authentication, the app now:

1. **Stores the access token** securely (KeyStore/Keychain)
2. **Calls `/api/v1/user`** to get current user profile
3. **Checks if user has completed registration**:
   - If profile is complete (has firstname, lastname, email) → **Navigate to Home Screen**
   - If profile is incomplete or API fails → **Navigate to Personal Details Screen**

---

## Flow Diagram

```
User completes Google OAuth
        ↓
Access token received
        ↓
Token saved securely
        ↓
Call GET /api/v1/user
        ↓
Check response
        ↓
    ┌───────┴───────┐
    ↓               ↓
Profile Complete   Profile Incomplete
firstname exists   or API Error
lastname exists
email exists
    ↓               ↓
Home Screen    Personal Details
```

---

## Files Modified

### 1. `lib/services/api_client.dart`

**Added:**
```dart
/// Get current user (self)
Future<Map<String, dynamic>> getCurrentUser() async {
  final response = await get('/api/v1/user');
  return parseJson(response);
}
```

This method:
- Calls `/api/v1/user` endpoint
- Automatically includes `Authorization: Bearer <token>` header
- Returns parsed JSON response

### 2. `lib/screens/continue_with_google_screen.dart`

**Updated `_handleCallback` method:**

```dart
// 1. Save token
await _authService.saveToken(token);

// 2. Check user profile
final userResponse = await _apiClient.getCurrentUser();
final userData = userResponse['data'];

// 3. Check if profile is complete
final bool isProfileComplete = userData != null &&
    userData['firstname'] != null &&
    userData['lastname'] != null &&
    userData['email'] != null;

// 4. Navigate based on profile status
if (isProfileComplete) {
  // Go to Home Screen
  Navigator.pushReplacement(...HomeScreen());
} else {
  // Go to Personal Details Screen
  Navigator.pushReplacement(...PersonalDetailsScreen());
}
```

**Error Handling:**
- If `/api/v1/user` returns 401 (unauthorized) → Go to Personal Details
- If network error → Go to Personal Details
- If any other error → Go to Personal Details

This ensures users always land somewhere, even if API fails.

---

## API Integration

### Endpoint Used
```
GET /api/v1/user
Authorization: Bearer <access_token>
```

### Expected Response (Success)
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

### Expected Response (Unauthorized)
```json
{
  "message": "error",
  "error": "Invalid or missing authentication token",
  "statusCode": 401,
  "data": null
}
```

---

## Profile Completeness Check

A profile is considered **complete** if it has:
- ✅ `firstname` is not null
- ✅ `lastname` is not null
- ✅ `email` is not null

You can add more fields to this check if needed (e.g., gender, address, phone).

---

## Navigation Logic

| Condition | Destination | Reason |
|-----------|-------------|--------|
| Profile has firstname, lastname, email | **Home Screen** | User is fully registered |
| Profile missing required fields | **Personal Details** | User needs to complete profile |
| API returns 401 | **Personal Details** | New user, no profile yet |
| Network error | **Personal Details** | Safe fallback |
| Any other error | **Personal Details** | Safe fallback |

---

## Testing

### Test Case 1: Existing User (Complete Profile)
1. Login with Google
2. Token saved
3. API returns user data with firstname, lastname, email
4. ✅ Navigate to **Home Screen**

### Test Case 2: New User (No Profile)
1. Login with Google
2. Token saved
3. API returns 401 or empty data
4. ✅ Navigate to **Personal Details Screen**

### Test Case 3: Network Error
1. Login with Google
2. Token saved
3. API call fails (network timeout)
4. ✅ Navigate to **Personal Details Screen** (safe fallback)

---

## Security

- ✅ Access token stored in secure storage (KeyStore/Keychain)
- ✅ Token automatically included in API headers
- ✅ 401 errors handled gracefully
- ✅ User never gets stuck (always navigates somewhere)

---

## Token Storage

The access token is stored securely and can be accessed:

```dart
final authService = AuthService();
final token = await authService.getToken();
```

This token is automatically used by `ApiClient` for all API requests:

```dart
final apiClient = ApiClient();
final user = await apiClient.getCurrentUser();
```

---

## Next Steps

After backend implements the redirect:

1. **Test with existing user**:
   - Login with Google
   - Should go directly to Home Screen

2. **Test with new user**:
   - Login with Google for first time
   - Should go to Personal Details Screen
   - Complete profile
   - Then should see Home Screen

3. **Test error scenarios**:
   - Disconnect network
   - Login with Google
   - Should still navigate to Personal Details (safe fallback)

---

## Backend Requirements

### Critical: Redirect After OAuth

Backend must redirect with token (not return JSON):

```javascript
// After successful Google OAuth:
const redirectUri = req.query.app_redirect_uri || 'hamiltoncarservice://oauth';
res.redirect(`${redirectUri}?access_token=${jwtToken}`);
```

### API Endpoint Requirements

The `/api/v1/user` endpoint should:
- Accept `Authorization: Bearer <token>` header
- Return 200 with user data if token is valid
- Return 401 if token is invalid or missing
- Include all user profile fields in `data` object

---

## Status

- ✅ OAuth flow complete
- ✅ Token storage implemented
- ✅ User profile check implemented
- ✅ Smart navigation logic implemented
- ✅ Error handling implemented
- ⏳ **Waiting for backend redirect fix**

Once backend redirects properly, the entire flow will work end-to-end!

---

**Last Updated**: 2026-04-28
**Status**: Mobile app ready, backend redirect pending
