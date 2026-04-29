import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/hamilton_splash_background.dart';

/// Full-screen splash: wave background with centered Hamilton logo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.nextScreen,
    this.displayDuration = const Duration(seconds: 3),
  });

  final Widget nextScreen;
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

  Future<void> _goNext() async {
    await Future<void>.delayed(widget.displayDuration);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
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
