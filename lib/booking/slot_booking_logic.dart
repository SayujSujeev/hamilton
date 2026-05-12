import 'package:flutter/material.dart';

import '../models/booking_cart_line.dart';
import '../models/workshop_slot.dart';

class SlotBookingLogic {
  SlotBookingLogic._();

  /// `YYYY-MM-DD` for API query/body.
  static String formatDateApi(DateTime date) {
    final d = DateUtils.dateOnly(date);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static TimeOfDay? parseSlotTiming(String slotTiming) {
    final parts = slotTiming.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static int minutesSinceMidnight(TimeOfDay t) => t.hour * 60 + t.minute;

  static List<WorkshopSlot> sortedByTime(List<WorkshopSlot> slots) {
    final copy = [...slots];
    copy.sort((a, b) {
      final ta = parseSlotTiming(a.slotTiming);
      final tb = parseSlotTiming(b.slotTiming);
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return minutesSinceMidnight(ta).compareTo(minutesSinceMidnight(tb));
    });
    return copy;
  }

  /// Infer minutes between consecutive slot starts (falls back to 45).
  static int inferSlotStepMinutes(List<WorkshopSlot> sorted) {
    if (sorted.length < 2) return 45;
    final t0 = parseSlotTiming(sorted[0].slotTiming);
    final t1 = parseSlotTiming(sorted[1].slotTiming);
    if (t0 == null || t1 == null) return 45;
    final delta =
        minutesSinceMidnight(t1) - minutesSinceMidnight(t0);
    return delta > 0 ? delta : 45;
  }

  /// Build lowercase service_name → service_id from a day's slots.
  static Map<String, String> serviceNameCatalog(List<WorkshopSlot> slots) {
    final map = <String, String>{};
    for (final s in slots) {
      for (final row in s.serviceAvailability) {
        final key = row.serviceName.toLowerCase().trim();
        if (key.isEmpty || row.serviceId.isEmpty) continue;
        map.putIfAbsent(key, () => row.serviceId);
      }
    }
    return map;
  }

  /// Match cart title to API [service_name] keys when [line.serviceTypeId] is absent.
  static String? resolveServiceTypeId(
    BookingCartLine line,
    Map<String, String> nameCatalog,
  ) {
    final explicit = line.serviceTypeId?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final title = line.title.toLowerCase().trim();

    if (nameCatalog.containsKey(title)) {
      return nameCatalog[title];
    }

    for (final e in nameCatalog.entries) {
      if (e.key == title ||
          e.key.contains(title) ||
          title.contains(e.key)) {
        return e.value;
      }
    }

    const aliases = <String, List<String>>{
      'tyre replacement': ['tyre', 'tire', 'replacement'],
      'wheel alignment': ['alignment'],
      'wheel balance': ['balance'],
      'lubricants': ['lubricant', 'oil', 'lube'],
    };

    final hints = aliases[title];
    if (hints != null) {
      for (final e in nameCatalog.entries) {
        for (final hint in hints) {
          if (e.key.contains(hint)) return e.value;
        }
      }
    }

    return null;
  }

  /// Ordered UUIDs for cart lines; null entry means unresolved.
  static List<String?> resolveOrderedServiceIds(
    List<BookingCartLine> lines,
    Map<String, String> nameCatalog,
  ) {
    return lines
        .map((line) => resolveServiceTypeId(line, nameCatalog))
        .toList(growable: false);
  }

  /// First slots where each of [orderedServiceIds] has capacity on consecutive rows.
  static List<WorkshopSlot> eligibleStartSlots({
    required List<WorkshopSlot> sortedSlots,
    required List<String> orderedServiceIds,
  }) {
    if (sortedSlots.isEmpty || orderedServiceIds.isEmpty) return [];
    final k = orderedServiceIds.length;
    if (k == 1) {
      final id = orderedServiceIds.first;
      return [
        for (final s in sortedSlots)
          if (s.capacityForServiceId(id)) s,
      ];
    }

    final out = <WorkshopSlot>[];
    for (var i = 0; i <= sortedSlots.length - k; i++) {
      var ok = true;
      for (var j = 0; j < k; j++) {
        if (!sortedSlots[i + j].capacityForServiceId(orderedServiceIds[j])) {
          ok = false;
          break;
        }
      }
      if (ok) out.add(sortedSlots[i]);
    }
    return out;
  }

  static String formatTime(TimeOfDay t) {
    final h = t.hour;
    final m = t.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final mm = m.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }

  static String formatSlotRangeFromApi(
    WorkshopSlot firstSlot,
    int serviceCount,
    int stepMinutes,
    List<WorkshopSlot> sortedSlots,
  ) {
    final start = parseSlotTiming(firstSlot.slotTiming);
    if (start == null || serviceCount < 1) return firstSlot.slotTiming;

    final idx = sortedSlots.indexWhere((s) => s.slotId == firstSlot.slotId);
    if (idx < 0) return '${formatTime(start)} (${firstSlot.slotTiming})';

    if (serviceCount == 1) {
      return formatTime(start);
    }

    final lastIdx = idx + serviceCount - 1;
    if (lastIdx >= sortedSlots.length) {
      return formatTime(start);
    }

    final lastStart = parseSlotTiming(sortedSlots[lastIdx].slotTiming);
    if (lastStart == null) return formatTime(start);

    final endMt = minutesSinceMidnight(lastStart) + stepMinutes;
    final wrapped = endMt % (24 * 60);
    final end = TimeOfDay(hour: wrapped ~/ 60, minute: wrapped % 60);

    return '${formatTime(start)} – ${formatTime(end)}';
  }
}
