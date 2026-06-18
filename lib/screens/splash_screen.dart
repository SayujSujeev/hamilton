import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/phone_registration_screen.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';
import '../widgets/hamilton_splash_background.dart';

/// Full-screen splash — routes based on stored JWT + live API checks.
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

    try {
      return await resolveAuthDestination(token: token);
    } on AuthExpiredException {
      await authService.clearToken();
      return const PhoneRegistrationScreen();
    } catch (e) {
      if (_isAuthError(e)) {
        await authService.clearToken();
        return const PhoneRegistrationScreen();
      }
      // Network error — if we still have a token, try JWT-only routing.
      if (token != null) {
        return authDestinationForToken(token);
      }
      return const PhoneRegistrationScreen();
    }
  }

  bool _isAuthError(Object e) {
    final msg = e.toString();
    return msg.contains('401') || msg.contains('Authentication expired');
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
