import 'package:flutter/material.dart';

/// Shared wave / fabric texture used on splash screens.
class HamiltonSplashBackground extends StatelessWidget {
  const HamiltonSplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        // Shows through where the texture is faded.
        color: Color(0xFFF5F5F5),
        image: DecorationImage(
          image: AssetImage('assets/images/splash_background.png'),
          fit: BoxFit.cover,
          opacity: 0.45,
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
