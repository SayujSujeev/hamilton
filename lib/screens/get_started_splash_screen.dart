import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/get_started_primary_button.dart';
import '../widgets/hamilton_splash_background.dart';
import 'phone_registration_screen.dart';

/// Second splash: same backdrop + logo, with bottom [Get Started] CTA.
class GetStartedSplashScreen extends StatelessWidget {
  const GetStartedSplashScreen({super.key});

  static const double _logoMax = 320;
  static const double _logoMin = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HamiltonSplashBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final side = (constraints.maxWidth * 0.62)
                            .clamp(_logoMin, _logoMax)
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
                ),
                // Figma: left 16, top 20 (gap above button); button 358×48.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final btnW = math.min(
                        GetStartedPrimaryButton.designWidth,
                        maxW,
                      );
                      return Center(
                        child: GetStartedPrimaryButton(
                          width: btnW,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder<void>(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const PhoneRegistrationScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
