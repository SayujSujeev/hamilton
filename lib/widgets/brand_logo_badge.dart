import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/brand_display_name.dart';

String brandLogoInitialLetter(String brandName) {
  final t = displayMakeNameForUi(brandName).trim();
  if (t.isEmpty) return '?';
  return t[0].toUpperCase();
}

/// Vehicle make badge: optional [brandLogoUrl] (HTTPS to your CDN), else BMW
/// asset if the name matches, else a single-letter fallback.
class BrandLogoBadge extends StatelessWidget {
  const BrandLogoBadge({
    super.key,
    required this.brandName,
    this.brandLogoUrl,
    required this.size,
    required this.backgroundColor,
    required this.initialTextStyle,
  });

  final String brandName;
  final String? brandLogoUrl;
  final double size;
  final Color backgroundColor;
  final TextStyle initialTextStyle;

  bool get _isBmw => brandName.toLowerCase().contains('bmw');

  Widget _bmwSvg() => SvgPicture.asset(
        'assets/images/bmwsvg.svg',
        width: size,
        height: size,
      );

  Widget _initialCircle() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        brandLogoInitialLetter(brandName),
        style: initialTextStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = brandLogoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Container(
          width: size,
          height: size,
          color: backgroundColor,
          alignment: Alignment.center,
          child: Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              if (_isBmw) return _bmwSvg();
              return Text(
                brandLogoInitialLetter(brandName),
                style: initialTextStyle,
              );
            },
          ),
        ),
      );
    }

    if (_isBmw) return _bmwSvg();

    return _initialCircle();
  }
}
