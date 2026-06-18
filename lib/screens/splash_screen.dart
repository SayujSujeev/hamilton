import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/phone_registration_screen.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';
import '../utils/jwt_utils.dart';
import '../widgets/hamilton_splash_background.dart';

/// Full-screen splash — decides where to go based on stored JWT claims.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.displayDuration = const Duration(seconds: 3),
  });

  final Duration displayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_goNext());
  }

  Future<Widget> _resolveDestination() async {
    final authService = AuthService();
    final token = await authService.getToken();

    // No token stored → user has never logged in (or was logged out).
    if (token == null) return const PhoneRegistrationScreen();

    // Token expired → clear it and send to login.
    if (JwtClaims.isExpiredToken(token)) {
      await authService.clearToken();
      return const PhoneRegistrationScreen();
    }

    // Validate the token against the backend.
    try {
      await ApiClient().getCurrentUser();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') ||
          msg.contains('403') ||
          msg.contains('Authentication expired')) {
        await authService.clearToken();
        return const PhoneRegistrationScreen();
      }
      // Network error etc. — token may still be fine, proceed.
    }

    // Token is valid — read claims and route accordingly.
    return authDestinationForToken(token);
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(widget.displayDuration);
    if (!mounted) return;

    final destination = await _resolveDestination();
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HamiltonSplashBackground(),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = (constraints.maxWidth * 0.62)
                    .clamp(180.0, 320.0)
                    .toDouble();
                return Image.asset(
                  'assets/images/hamilton_logo.png',
                  width: side,
                  height: side,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
