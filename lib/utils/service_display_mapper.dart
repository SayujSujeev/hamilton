import 'package:flutter/material.dart';

import '../models/workshop_service.dart';

String titleCaseServiceName(String name) {
  return name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) {
        if (w.length == 1) return w.toUpperCase();
        return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
      })
      .join(' ');
}

String formatApproxServiceDuration(int hours) {
  if (hours <= 0) return 'Duration varies';
  if (hours == 1) return '~1 hour';
  return '~$hours hours';
}

/// Visual defaults for a service card (assets/colors by name keywords).
class ServiceCardPresentation {
  const ServiceCardPresentation({
    required this.imageAsset,
    required this.footerLabel,
    required this.footerIcon,
    required this.glowColor,
    required this.gradientEndColor,
    this.headerIconAsset,
    this.opensTyreBrandSheet = false,
  });

  final String imageAsset;
  final String? headerIconAsset;
  final String footerLabel;
  final IconData footerIcon;
  final Color glowColor;
  final Color gradientEndColor;
  final bool opensTyreBrandSheet;
}

ServiceCardPresentation presentationForWorkshopService(WorkshopService s) {
  final name = s.name.toLowerCase();
  final capacityLabel = s.capacity == 1
      ? '1 bay available'
      : 'Up to ${s.capacity} bays';

  if (name.contains('tyre') || name.contains('tire')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_tyre_replacement.png',
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
      footerLabel: s.description?.trim().isNotEmpty == true
          ? s.description!.trim()
          : capacityLabel,
      footerIcon: Icons.info_outline,
      glowColor: const Color(0xFF88F8E9),
      gradientEndColor: const Color(0xFFE4FBF8),
      opensTyreBrandSheet: true,
    );
  }

  if (name.contains('oil') || name.contains('lubric')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_lubricants.png',
      headerIconAsset: 'assets/images/lubrihand_headericon.png',
      footerLabel: s.description?.trim().isNotEmpty == true
          ? s.description!.trim()
          : capacityLabel,
      footerIcon: Icons.info_outline,
      glowColor: const Color(0xFFFFA8B1),
      gradientEndColor: const Color(0xFFFFF1F1),
    );
  }

  if (name.contains('align')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_wheel_alignment.png',
      headerIconAsset: 'assets/images/wheelalignment_headericon.png',
      footerLabel: capacityLabel,
      footerIcon: Icons.local_offer_outlined,
      glowColor: const Color(0xFFFCF3AB),
      gradientEndColor: const Color(0xFFFBF6DC),
    );
  }

  if (name.contains('balance')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_wheel_balance.png',
      headerIconAsset: 'assets/images/service_tyre_header_icon.png',
      footerLabel: capacityLabel,
      footerIcon: Icons.local_offer_outlined,
      glowColor: const Color(0xFFA8B9FF),
      gradientEndColor: const Color(0xFFE4E8FF),
    );
  }

  if (name.contains('brake')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_tyre_replacement.png',
      footerLabel: s.description?.trim().isNotEmpty == true
          ? s.description!.trim()
          : capacityLabel,
      footerIcon: Icons.build_outlined,
      glowColor: const Color(0xFFFFC4A8),
      gradientEndColor: const Color(0xFFFFF0E8),
    );
  }

  if (name.contains('suspension')) {
    return ServiceCardPresentation(
      imageAsset: 'assets/images/service_wheel_alignment.png',
      footerLabel: capacityLabel,
      footerIcon: Icons.build_outlined,
      glowColor: const Color(0xFFD4A8FF),
      gradientEndColor: const Color(0xFFF3E8FF),
    );
  }

  return ServiceCardPresentation(
    imageAsset: 'assets/images/service_tyre_replacement.png',
    footerLabel: s.description?.trim().isNotEmpty == true
        ? s.description!.trim()
        : capacityLabel,
    footerIcon: Icons.info_outline,
    glowColor: const Color(0xFFE0E0E0),
    gradientEndColor: const Color(0xFFF5F5F5),
  );
}
