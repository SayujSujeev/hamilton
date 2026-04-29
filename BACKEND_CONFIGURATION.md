# Backend Configuration - IMPORTANT UPDATE

## Current Backend Behavior

Based on your API documentation, the callback endpoint currently returns:

```json
{
  "access_token": "eyJhbGciOiJIUzI1Ni..."
}
```

**This won't work for mobile app deep links!**

---

## Required Changes for Mobile App

For the mobile app to receive the token via deep link, the backend **MUST redirect** instead of returning JSON.

### Option 1: Detect User-Agent (Recommended)

Update the callback endpoint to detect if the request is from a mobile app and redirect accordingly:

```javascript
app.get('/api/v1/auth/google/callback', async (req, res) => {
  try {
    const { code } = req.query;
    
    // Exchange code for tokens with Google
    const googleTokens = await exchangeCodeForTokens(code);
    const googleUser = await getUserInfo(googleTokens.access_token);
    const user = await createOrUpdateUser(googleUser);
    const jwtToken = generateJWT(user);
    
    // Check if request is from mobile app
    const userAgent = req.headers['user-agent'] || '';
    const isMobile = userAgent.includes('okhttp') || 
                     userAgent.includes('Dart') || 
                     userAgent.includes('Flutter');
    
    if (isMobile) {
      // Redirect to mobile app with token
      return res.redirect(`hamiltoncarservice://oauth?access_token=${jwtToken}`);
    } else {
      // Return JSON for web/API clients
      return res.json({ access_token: jwtToken });
    }
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Option 2: Separate Mobile Endpoint

Create a dedicated mobile callback endpoint:

```javascript
// Web callback (returns JSON)
app.get('/api/v1/auth/google/callback', async (req, res) => {
  // ... existing code ...
  res.json({ access_token: jwtToken });
});

// Mobile callback (redirects to app)
app.get('/api/v1/auth/google/callback/mobile', async (req, res) => {
  try {
    const { code } = req.query;
    
    const googleTokens = await exchangeCodeForTokens(code);
    const googleUser = await getUserInfo(googleTokens.access_token);
    const user = await createOrUpdateUser(googleUser);
    const jwtToken = generateJWT(user);
    
    // Redirect to mobile app
    res.redirect(`hamiltoncarservice://oauth?access_token=${jwtToken}`);
    
  } catch (error) {
    res.redirect(`hamiltoncarservice://oauth?error=${error.message}`);
  }
});
```

Then update the mobile app to use:
```dart
String getGoogleAuthUrl() {
  // Use mobile-specific callback
  return '$_baseUrl$_authEndpoint?redirect_uri=$_baseUrl/api/v1/auth/google/callback/mobile';
}
```

### Option 3: Query Parameter Flag

Add a query parameter to indicate mobile request:

```javascript
app.get('/api/v1/auth/google/callback', async (req, res) => {
  try {
    const { code, mobile } = req.query;
    
    const googleTokens = await exchangeCodeForTokens(code);
    const googleUser = await getUserInfo(googleTokens.access_token);
    const user = await createOrUpdateUser(googleUser);
    const jwtToken = generateJWT(user);
    
    if (mobile === 'true') {
      // Mobile app request - redirect to app
      return res.redirect(`hamiltoncarservice://oauth?access_token=${jwtToken}`);
    } else {
      // Web request - return JSON
      return res.json({ access_token: jwtToken });
    }
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

---

## Google OAuth Console Configuration

### Redirect URIs to Add

Depending on which option you choose:

**Option 1 (User-Agent detection):**
- Keep existing: `https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback`

**Option 2 (Separate endpoint):**
- Add: `https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback/mobile`

**Option 3 (Query parameter):**
- Keep existing: `https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback`

---

## Why Redirect is Required

### Current Flow (Won't Work)
```
1. Mobile app opens browser
2. User signs in with Google
3. Google redirects to callback
4. Backend returns JSON {"access_token": "..."}
5. ❌ Browser shows JSON - app doesn't reopen!
```

### Correct Flow (Will Work)
```
1. Mobile app opens browser
2. User signs in with Google
3. Google redirects to callback
4. Backend redirects to: hamiltoncarservice://oauth?access_token=...
5. ✅ Deep link opens mobile app with token!
```

---

## Testing Your Changes

### Test 1: Web Browser (Should Return JSON)
```bash
# Open in browser:
https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?code=FAKE_CODE

# Expected: JSON response with access_token
```

### Test 2: Mobile Flow (Should Redirect)
```bash
# Open in browser:
https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?code=FAKE_CODE&mobile=true

# Expected: Browser redirects to hamiltoncarservice://oauth?access_token=...
```

### Test 3: Check Redirect Header
```bash
curl -I "https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?code=test&mobile=true"

# Expected:
# HTTP/1.1 302 Found
# Location: hamiltoncarservice://oauth?access_token=eyJhbGc...
```

---

## Mobile App Updates

The mobile app code is already updated to handle `access_token`:

```dart
// Checks for multiple token field names:
- access_token  ✅ (your backend's format)
- token         ✅ (fallback)
- jwt           ✅ (fallback)
```

---

## Complete Example (Option 1 - Recommended)

```javascript
const express = require('express');
const axios = require('axios');
const jwt = require('jsonwebtoken');

app.get('/api/v1/auth/google/callback', async (req, res) => {
  try {
    const { code } = req.query;
    
    if (!code) {
      return res.status(400).json({ error: 'Missing authorization code' });
    }
    
    // 1. Exchange code for tokens with Google
    const tokenResponse = await axios.post('https://oauth2.googleapis.com/token', {
      code,
      client_id: process.env.GOOGLE_CLIENT_ID,
      client_secret: process.env.GOOGLE_CLIENT_SECRET,
      redirect_uri: 'https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback',
      grant_type: 'authorization_code',
    });
    
    const { access_token: googleAccessToken } = tokenResponse.data;
    
    // 2. Get user info from Google
    const userResponse = await axios.get('https://www.googleapis.com/oauth2/v2/userinfo', {
      headers: { Authorization: `Bearer ${googleAccessToken}` },
    });
    
    const googleUser = userResponse.data;
    
    // 3. Create or update user in your database
    const user = await User.findOrCreate({
      where: { googleId: googleUser.id },
      defaults: {
        email: googleUser.email,
        name: googleUser.name,
        picture: googleUser.picture,
      },
    });
    
    // 4. Generate your JWT token
    const jwtToken = jwt.sign(
      {
        sub: user.id,
        email: user.email,
        name: user.name,
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    // 5. Detect if mobile app and redirect accordingly
    const userAgent = req.headers['user-agent'] || '';
    const isMobile = userAgent.toLowerCase().includes('dart') || 
                     userAgent.toLowerCase().includes('okhttp');
    
    if (isMobile) {
      // Mobile app - redirect to deep link
      return res.redirect(`hamiltoncarservice://oauth?access_token=${jwtToken}`);
    } else {
      // Web/API client - return JSON
      return res.json({
        access_token: jwtToken,
        token_type: 'Bearer',
        expires_in: 604800, // 7 days in seconds
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
        },
      });
    }
    
  } catch (error) {
    console.error('OAuth callback error:', error);
    
    const userAgent = req.headers['user-agent'] || '';
    const isMobile = userAgent.toLowerCase().includes('dart');
    
    if (isMobile) {
      return res.redirect(`hamiltoncarservice://oauth?error=${encodeURIComponent(error.message)}`);
    } else {
      return res.status(500).json({ error: error.message });
    }
  }
});
```

---

## Summary

1. **Current backend returns JSON** - won't reopen mobile app
2. **Backend must redirect** to `hamiltoncarservice://oauth?access_token=...`
3. **Use User-Agent detection** or separate mobile endpoint
4. **Mobile app already handles** `access_token` field name
5. **Test redirect** before deploying

---

## Quick Test

After updating backend, test with:

```bash
# Should redirect to app
curl -L -H "User-Agent: Dart/3.0 Flutter" \
  "https://hamilton-be-dev.vercel.app/api/v1/auth/google/callback?code=test"
```

Expected: Redirect to `hamiltoncarservice://oauth?access_token=...`

---

**Status**: Backend update required for mobile OAuth to work
**Priority**: High - Mobile app can't receive token without redirect
**Estimated Time**: 15-30 minutes
