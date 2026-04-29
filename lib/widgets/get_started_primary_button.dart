import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Primary CTA button using the exact branded image background.
class GetStartedPrimaryButton extends StatelessWidget {
  const GetStartedPrimaryButton({
    super.key,
    required this.onPressed,
    this.width = designWidth,
    this.height = designHeight,
    this.label = 'Get Started',
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final double width;
  final double height;
  final String label;
  final bool enabled;

  static const double designWidth = 358;
  static const double designHeight = 48;
  static const double _radius = 1000;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = math.max(width, 0.0).toDouble();
    final effectiveHeight = math.max(height, 0.0).toDouble();
    final clipRadius = BorderRadius.circular(_radius);
    final isEnabled = enabled && onPressed != null;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: clipRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: clipRadius,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.55,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Exact branded button image stretched to fill.
                Image.asset(
                  'assets/images/primary_button_bg.png',
                  fit: BoxFit.fill,
                  width: effectiveWidth,
                  height: effectiveHeight,
                ),
                // Label centered.
                if (label.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          shadows: const [
                            Shadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 0.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
