# Hamilton Car Service - Project Structure

## 📁 Project Organization

```
hamilton_car_service/
│
├── lib/
│   ├── models/                    # Data Models (Type-safe)
│   │   ├── user_model.dart       # User profile model
│   │   └── vehicle_model.dart    # Vehicle model
│   │
│   ├── services/                  # API & Business Logic
│   │   ├── auth_service.dart     # Google Sign-In & token storage
│   │   ├── api_client.dart       # HTTP client (low-level)
│   │   └── user_service.dart     # User & vehicle APIs (high-level)
│   │
│   ├── screens/                   # UI Screens
│   │   ├── splash_screen.dart
│   │   ├── continue_with_google_screen.dart
│   │   ├── home_screen.dart
│   │   ├── home_screen_wrapper.dart  # ⭐ API-integrated home
│   │   ├── add_first_vehicle_screen.dart
│   │   ├── add_new_vehicle_screen.dart
│   │   ├── personal_details_screen.dart
│   │   └── services_screen.dart
│   │
│   ├── widgets/                   # Reusable UI Components
│   │   └── get_started_primary_button.dart
│   │
│   ├── examples/                  # Code Examples
│   │   ├── auth_usage_examples.dart
│   │   └── api_integration_example.dart  # ⭐ Complete API demo
│   │
│   ├── utils/                     # Utilities
│   │   └── auth_guard.dart
│   │
│   └── main.dart                  # App Entry Point
│
├── assets/                        # Images, Icons, etc.
│   └── images/
│
├── android/                       # Android native code
├── ios/                          # iOS native code
├── windows/                      # Windows native code
├── linux/                        # Linux native code
│
├── Documentation/
│   ├── INTEGRATION_SUMMARY.md    # ⭐ High-level overview
│   ├── API_INTEGRATION.md        # ⭐ Comprehensive API docs
│   └── QUICK_START.md            # ⭐ Quick start guide
│
└── pubspec.yaml                  # Dependencies
```

---

## 🚀 API Integration

### Quick Access Points

1. **Test the APIs:**
   - Screen: `lib/examples/api_integration_example.dart`
   - Documentation: `QUICK_START.md`

2. **Use in Your App:**
   - Wrapper: `lib/screens/home_screen_wrapper.dart`
   - Service: `lib/services/user_service.dart`

3. **Documentation:**
   - Summary: `INTEGRATION_SUMMARY.md`
   - Full Docs: `API_INTEGRATION.md`
   - Quick Start: `QUICK_START.md`

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────┐
│              UI Layer (Screens)              │
│  home_screen_wrapper, api_integration_example│
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│         Service Layer (Business Logic)       │
│     user_service.dart (High-level APIs)      │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│           API Client Layer                   │
│    api_client.dart (HTTP + Auth Headers)     │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│         Authentication Layer                 │
│  auth_service.dart (Google + Token Storage)  │
└─────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│              Data Models                     │
│    user_model.dart, vehicle_model.dart       │
└─────────────────────────────────────────────┘
```

---

## 🔑 Key Files

### Models (Type-Safe Data)
- `lib/models/user_model.dart` - User profile data structure
- `lib/models/vehicle_model.dart` - Vehicle data structure

### Services (API Integration)
- `lib/services/auth_service.dart` - Authentication & token management
- `lib/services/api_client.dart` - HTTP client with auto auth headers
- `lib/services/user_service.dart` - **⭐ Main API service (use this!)**

### Screens (UI)
- `lib/screens/home_screen_wrapper.dart` - **⭐ API-integrated home**
- `lib/examples/api_integration_example.dart` - **⭐ Complete demo**

---

## 💡 Usage Patterns

### Pattern 1: Using the Wrapper (Recommended)

```dart
// Just use the wrapper - it handles everything
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HomeScreenWrapper(),
  ),
);
```

### Pattern 2: Direct Service Usage

```dart
import 'package:hamilton_car_service/services/user_service.dart';

final userService = UserService();

// Fetch data
final user = await userService.getCurrentUser();
final vehicles = await userService.getUserVehicles();

// Update profile
final updated = await userService.updateUserProfile(
  firstname: 'John',
  lastname: 'Doe',
);
```

### Pattern 3: Testing & Examples

```dart
import 'package:hamilton_car_service/examples/api_integration_example.dart';

// View complete working example
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ApiIntegrationExample(),
  ),
);
```

---

## 📝 Coding Conventions

### Service Layer
- Services are singletons accessible via constructor
- All API calls return typed models (not raw JSON)
- Errors are thrown as exceptions
- Authentication is handled automatically

### Models
- Immutable data classes
- `fromJson()` for deserialization
- `toJson()` for serialization
- Optional fields use nullable types

### Screens
- StatefulWidget for API-integrated screens
- Loading states during API calls
- Error handling with user feedback
- Pull-to-refresh support

---

## 🛠️ Development Workflow

### 1. To Add a New API Endpoint

1. Add method to `api_client.dart` (low-level)
2. Create model in `models/` (if needed)
3. Add method to appropriate service (high-level)
4. Use in your screen

### 2. To Create a New Screen with API

1. Create StatefulWidget
2. Import `user_service.dart`
3. Call API methods in `initState()` or button handlers
4. Handle loading/error states
5. Display data using models

### 3. To Test Changes

```dart
// Option A: Use example screen
const ApiIntegrationExample()

// Option B: Use wrapper
const HomeScreenWrapper()
```

---

## 📚 Learning Resources

1. **New to the project?** 
   → Start with `QUICK_START.md`

2. **Need API details?**
   → Read `API_INTEGRATION.md`

3. **Want overview?**
   → Read `INTEGRATION_SUMMARY.md`

4. **Need code examples?**
   → Check `lib/examples/api_integration_example.dart`

---

## 🔐 Security Notes

- JWT tokens stored in secure storage
- Never log or expose tokens
- Auto token cleanup on 401 errors
- HTTPS enforced for all API calls
- Google OAuth for authentication

---

## 🎯 Current Status

✅ **Completed:**
- Google Sign-In integration
- User profile API (GET, PATCH)
- Vehicle list API (GET)
- Type-safe models
- Error handling
- Example screens
- Documentation

🚧 **To Do:**
- Vehicle CRUD operations (create, update, delete)
- Service booking APIs
- Notifications
- Offline caching
- Real-time updates

---

## 🤝 Contributing

When adding new features:
1. Follow existing patterns in services
2. Create type-safe models for data
3. Handle errors gracefully
4. Add loading states
5. Update documentation

---

## 📖 Quick Links

- **Test APIs:** Run `ApiIntegrationExample`
- **Use APIs:** Import `UserService`
- **Documentation:** See `API_INTEGRATION.md`
- **Examples:** Check `lib/examples/`

---

**Questions?** Check the documentation files in the root directory!
