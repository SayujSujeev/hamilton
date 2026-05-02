# Hamilton 44 Car Services

A Flutter mobile application for Hamilton 44 Car Services customers. This app allows users to manage their vehicles, book services, and track their car maintenance history.

## 🚀 Features

- ✅ Google Sign-In authentication
- ✅ User profile management
- ✅ Vehicle management
- ✅ Service booking
- ✅ Maintenance tracking
- ✅ Real-time updates

## 📱 Platforms

- Android
- iOS  
- Web (coming soon)

## 🔧 Tech Stack

- **Framework:** Flutter 3.11+
- **Language:** Dart
- **State Management:** StatefulWidget
- **Authentication:** Google Sign-In + JWT
- **Storage:** Flutter Secure Storage
- **HTTP Client:** http package
- **Backend:** Hamilton Backend API

## 📋 Prerequisites

- Flutter SDK (^3.11.0)
- Dart SDK (^3.11.0)
- Android Studio / Xcode (for mobile development)
- Google Cloud Console account (for OAuth setup)

## 🚦 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd hamilton_car_service
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Google Sign-In

Update the Web Client ID in `lib/services/auth_service.dart`:

```dart
static const String _webClientId = 'YOUR_WEB_CLIENT_ID_HERE';
```

See [GOOGLE_AUTH_INTEGRATION.md](GOOGLE_AUTH_INTEGRATION.md) for detailed setup instructions.

### 4. Run the App

```bash
flutter run
```

## 📚 Documentation

### API Integration

- **[🎯 INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** - High-level overview of API integration
- **[⚡ QUICK_START.md](QUICK_START.md)** - Quick start guide for using the APIs
- **[📖 API_INTEGRATION.md](API_INTEGRATION.md)** - Comprehensive API documentation
- **[🏗️ PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Project organization and architecture

### Authentication

- **[🔐 GOOGLE_AUTH_INTEGRATION.md](GOOGLE_AUTH_INTEGRATION.md)** - Google Sign-In setup guide

## 🎨 Project Structure

```
lib/
├── models/              # Data models (User, Vehicle)
├── services/            # API services & authentication
├── screens/             # UI screens
├── widgets/             # Reusable UI components
├── examples/            # Code examples & demos
└── utils/               # Utility functions
```

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed structure.

## 🔌 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/google/app` | POST | Authenticate with Google |
| `/api/v1/user` | GET | Get user profile |
| `/api/v1/user` | PATCH | Update user profile |
| `/api/v1/user/vehicle` | GET | Get user vehicles |

**Base URL:** `https://hamilton-be-dev.vercel.app`

## 💻 Usage Examples

### Fetch User Profile

```dart
import 'package:hamilton_car_service/services/user_service.dart';

final userService = UserService();
final user = await userService.getCurrentUser();
print('Welcome ${user.firstname}!');
```

### Fetch User Vehicles

```dart
final vehicles = await userService.getUserVehicles();
print('You have ${vehicles.length} vehicle(s)');
```

### Test API Integration

```dart
import 'package:hamilton_car_service/examples/api_integration_example.dart';

// Navigate to example screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ApiIntegrationExample(),
  ),
);
```

See [QUICK_START.md](QUICK_START.md) for more examples.

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Test API Integration

Use the built-in example screen:

```dart
import 'package:hamilton_car_service/examples/api_integration_example.dart';
```

## 🔒 Security

- JWT tokens stored securely using `flutter_secure_storage`
- HTTPS enforced for all API communications
- Automatic token cleanup on authentication errors
- Google OAuth 2.0 for authentication

## 📦 Dependencies

Main dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  google_sign_in: ^7.2.0
  google_fonts: ^6.2.1
  flutter_svg: ^2.2.4
```

## 🛠️ Development

### Add New API Endpoint

1. Add method to `lib/services/api_client.dart`
2. Create model in `lib/models/` (if needed)
3. Add method to service layer
4. Use in your screen

### Create New Screen

1. Create screen in `lib/screens/`
2. Import required services
3. Implement API calls with error handling
4. Add loading states

## 🐛 Troubleshooting

### Authentication Issues

- Verify `webClientId` in `auth_service.dart`
- Check Google Cloud Console configuration
- Ensure SHA-1/SHA-256 fingerprints registered

### API Errors

- Check internet connectivity
- Verify backend URL is correct
- Check token validity

See [API_INTEGRATION.md](API_INTEGRATION.md#troubleshooting) for detailed troubleshooting.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

[Add your license here]

## 📞 Support

For questions or issues:

1. Check the documentation files
2. Review example code in `lib/examples/`
3. Contact the development team

## 🎯 Roadmap

- [x] Google Sign-In integration
- [x] User profile management
- [x] Vehicle list display
- [ ] Vehicle CRUD operations
- [ ] Service booking
- [ ] Maintenance history
- [ ] Push notifications
- [ ] Offline support

## 📖 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [HTTP Package](https://pub.dev/packages/http)

---

**Built with ❤️ using Flutter**
