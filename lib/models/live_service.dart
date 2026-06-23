import 'package:flutter/foundation.dart';

class LiveServiceHistoryEntry {
  const LiveServiceHistoryEntry({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String status;
  final String? remarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayStatus => LiveServiceStatus.labelFor(status);

  factory LiveServiceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return LiveServiceHistoryEntry(
      id: _pickString(json, const ['id']),
      status: _pickString(json, const ['status']),
      remarks: _pickNullableString(json, const ['remarks', 'remark']),
      createdAt: _pickDateTime(json, const ['created_at', 'createdAt']),
      updatedAt: _pickDateTime(json, const ['updated_at', 'updatedAt']),
    );
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return '';
  }

  static String? _pickNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      return v.toString();
    }
    return null;
  }

  static DateTime? _pickDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    }
    return null;
  }
}

abstract final class LiveServiceStatus {
  static String labelFor(String raw) {
    final key = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (key) {
      'in_progress' => 'Servicing In Progress',
      'vehicle_arrived' => 'Vehicle Arrived',
      'inspection' => 'Inspection',
      'work_started' => 'Work Started',
      'work_in_progress' => 'Work In Progress',
      'quality_check' => 'Quality Check',
      'ready_for_pickup' => 'Ready for Pickup',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => raw
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
          .join(' '),
    };
  }

  static bool isActive(String raw) {
    final key = raw.trim().toLowerCase();
    return key == 'in_progress' ||
        key == 'work_in_progress' ||
        key == 'work_started' ||
        key == 'inspection' ||
        key == 'vehicle_arrived';
  }
}

class LiveServiceItem {
  const LiveServiceItem({
    required this.sparePartId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.note,
  });

  final String sparePartId;
  final String itemName;
  /// 'labour' or 'spare'
  final String type;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String note;

  bool get isLabour => type.toLowerCase() == 'labour';

  factory LiveServiceItem.fromJson(Map<String, dynamic> json) {
    return LiveServiceItem(
      sparePartId: _pickString(json, const [
        'spare_part_id',
        'sparePartId',
        'id',
      ]),
      itemName: _pickString(json, const [
        'item_name',
        'itemName',
        'name',
        'title',
      ]),
      type: _pickString(json, const ['type', 'item_type', 'itemType']),
      quantity: _pickInt(json, const ['quantity', 'qty']) ?? 0,
      unitPrice: _pickDouble(json, const ['unit_price', 'unitPrice']) ?? 0,
      totalPrice: _pickDouble(json, const [
            'total_price',
            'totalPrice',
            'amount',
          ]) ??
          0,
      note: _pickString(json, const ['note', 'description']),
    );
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return '';
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
    }
    return null;
  }

  static double? _pickDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
    }
    return null;
  }
}

class LiveService {
  const LiveService({
    required this.id,
    required this.vehicleId,
    required this.licensePlate,
    required this.odoReading,
    required this.firstname,
    required this.lastname,
    this.mobileNo,
    this.whatsappNo,
    this.serviceInTime,
    this.serviceOutTime,
    required this.serviceStatus,
    required this.serviceHistory,
    required this.items,
    required this.totalPartsCost,
    required this.totalLaborCost,
    required this.grandTotal,
    required this.discount,
  });

  final String id;
  final String vehicleId;
  final String licensePlate;
  final int odoReading;
  final String firstname;
  final String lastname;
  final String? mobileNo;
  final String? whatsappNo;
  final DateTime? serviceInTime;
  final DateTime? serviceOutTime;
  final String serviceStatus;
  final List<LiveServiceHistoryEntry> serviceHistory;
  final List<LiveServiceItem> items;
  final double totalPartsCost;
  final double totalLaborCost;
  final double grandTotal;
  final double discount;

  String get statusLabel => LiveServiceStatus.labelFor(serviceStatus);

  bool get isActive => LiveServiceStatus.isActive(serviceStatus);

  String get customerName {
    final fn = firstname.trim();
    final ln = lastname.trim();
    if (fn.isEmpty && ln.isEmpty) return '—';
    if (ln.isEmpty) return fn;
    if (fn.isEmpty) return ln;
    return '$fn $ln';
  }

  factory LiveService.fromJson(Map<String, dynamic> json) {
    final vehicleDetail = _asMap(json['vehicle_detail'] ?? json['vehicleDetail']);
    final vehicle = _asMap(json['vehicle']);
    final user = _asMap(json['user'] ?? json['user_detail'] ?? json['userDetail']);
    final customer = _asMap(json['customer']);
    final costSummary = _asMap(json['cost_summary'] ?? json['costSummary']);

    final vehicleId = _pickString(json, const ['vehicle_id', 'vehicleId'])
        .ifEmptyTry(() {
      for (final source in [vehicleDetail, vehicle]) {
        if (source == null) continue;
        final v = _pickString(source, const ['id', 'vehicle_id', 'vehicleId']);
        if (v.isNotEmpty) return v;
      }
      return '';
    });

    final serviceInTime = _pickDateTime(json, const [
      'service_in_time',
      'serviceInTime',
      'checked_in_at',
      'checkedInAt',
    ]);

    final serviceOutTime = _pickDateTime(json, const [
      'service_out_time',
      'serviceOutTime',
      'checked_out_at',
      'checkedOutAt',
    ]);

    final serviceStatus = _pickString(json, const [
      'service_status',
      'serviceStatus',
      'status',
    ]);

    final serviceHistory = _pickServiceHistory(json);

    final licensePlate = _pickString(json, const [
      'license_plate',
      'licensePlate',
      'plate',
    ]).ifEmptyTry(() {
      for (final source in [vehicleDetail, vehicle]) {
        if (source == null) continue;
        final v = _pickString(source, const [
          'license_plate',
          'licensePlate',
          'plate',
        ]);
        if (v.isNotEmpty) return v;
      }
      return '';
    });

    final odoReading = _pickInt(json, const ['odo_reading', 'odoReading']) ??
        _pickIntFrom(vehicleDetail, const ['odo_reading', 'odoReading']) ??
        _pickIntFrom(vehicle, const ['odo_reading', 'odoReading']) ??
        0;

    final firstname = _pickString(json, const ['firstname', 'first_name', 'firstName'])
        .ifEmptyTry(() {
      for (final source in [user, customer]) {
        if (source == null) continue;
        final v = _pickString(source, const [
          'firstname',
          'first_name',
          'firstName',
          'name',
        ]);
        if (v.isNotEmpty) return v;
      }
      return '';
    });

    final lastname = _pickString(json, const ['lastname', 'last_name', 'lastName'])
        .ifEmptyTry(() {
      for (final source in [user, customer]) {
        if (source == null) continue;
        final v = _pickString(source, const [
          'lastname',
          'last_name',
          'lastName',
        ]);
        if (v.isNotEmpty) return v;
      }
      return '';
    });

    final mobileNo = _pickNullableString(json, const ['mobile_no', 'mobileNo']) ??
        _pickNullableStringFrom(user, const ['mobile_no', 'mobileNo']) ??
        _pickNullableStringFrom(customer, const ['mobile_no', 'mobileNo']);

    final whatsappNo = _pickNullableString(json, const [
          'whatsapp_no',
          'whatsappNo',
        ]) ??
        _pickNullableStringFrom(user, const ['whatsapp_no', 'whatsappNo']) ??
        _pickNullableStringFrom(customer, const ['whatsapp_no', 'whatsappNo']);

    final items = _pickItems(json);

    final totalPartsCost = _pickDouble(json, const [
          'total_parts_cost',
          'totalPartsCost',
          'parts_total',
          'partsTotal',
        ]) ??
        _pickDoubleFrom(costSummary, const [
          'total_parts_cost',
          'totalPartsCost',
          'parts_total',
        ]) ??
        0;

    final totalLaborCost = _pickDouble(json, const [
          'total_labor_cost',
          'totalLaborCost',
          'total_labour_cost',
          'totalLabourCost',
          'labor_total',
          'labour_total',
        ]) ??
        _pickDoubleFrom(costSummary, const [
          'total_labor_cost',
          'totalLaborCost',
          'total_labour_cost',
          'labor_total',
        ]) ??
        0;

    final grandTotal = _pickDouble(json, const [
          'grand_total',
          'grandTotal',
          'total',
        ]) ??
        _pickDoubleFrom(costSummary, const ['grand_total', 'grandTotal']) ??
        0;

    final discount = _pickDouble(json, const ['discount']) ??
        _pickDoubleFrom(costSummary, const ['discount']) ??
        0;

    if (kDebugMode) {
      debugPrint(
        '[LiveService.fromJson] id=${_pickString(json, const ['id']).isEmpty ? "?" : _pickString(json, const ['id']).substring(0, 8)} '
        'plate=$licensePlate odo=$odoReading '
        'name=$firstname $lastname items=${items.length} '
        'grandTotal=$grandTotal',
      );
    }

    return LiveService(
      id: _pickString(json, const ['id', 'service_id', 'booking_id']),
      vehicleId: vehicleId,
      licensePlate: licensePlate,
      odoReading: odoReading,
      firstname: firstname,
      lastname: lastname,
      mobileNo: mobileNo,
      whatsappNo: whatsappNo,
      serviceInTime: serviceInTime,
      serviceOutTime: serviceOutTime,
      serviceStatus: serviceStatus,
      serviceHistory: serviceHistory,
      items: items,
      totalPartsCost: totalPartsCost,
      totalLaborCost: totalLaborCost,
      grandTotal: grandTotal,
      discount: discount,
    );
  }

  static List<LiveServiceHistoryEntry> _pickServiceHistory(
    Map<String, dynamic> json,
  ) {
    final entries = <LiveServiceHistoryEntry>[];
    final raw = json['service_history'] ?? json['serviceHistory'];
    if (raw is! List) return entries;

    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        entries.add(LiveServiceHistoryEntry.fromJson(entry));
      }
    }

    entries.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });

    return entries;
  }

  static DateTime? _pickDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    return raw is Map<String, dynamic> ? raw : null;
  }

  static List<LiveServiceItem> _pickItems(Map<String, dynamic> json) {
    final items = <LiveServiceItem>[];

    void addFromList(dynamic raw) {
      if (raw is! List) return;
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          items.add(LiveServiceItem.fromJson(entry));
        }
      }
    }

    addFromList(json['items']);
    if (items.isEmpty) addFromList(json['service_items']);
    if (items.isEmpty) addFromList(json['serviceItems']);
    if (items.isEmpty) addFromList(json['line_items']);
    if (items.isEmpty) addFromList(json['lineItems']);

    // PostgreSQL json_build_object alias used elsewhere in this API.
    if (items.isEmpty) {
      for (final key in const ['json_build_object', 'service_object']) {
        final raw = json[key];
        if (raw is List) {
          addFromList(raw);
        } else if (raw is Map<String, dynamic>) {
          items.add(LiveServiceItem.fromJson(raw));
        }
        if (items.isNotEmpty) break;
      }
    }

    return items;
  }

  static String _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return '';
  }

  static String? _pickNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      return v.toString();
    }
    return null;
  }

  static String? _pickNullableStringFrom(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    if (json == null) return null;
    return _pickNullableString(json, keys);
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
    }
    return null;
  }

  static int? _pickIntFrom(Map<String, dynamic>? json, List<String> keys) {
    if (json == null) return null;
    return _pickInt(json, keys);
  }

  static double? _pickDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim());
    }
    return null;
  }

  static double? _pickDoubleFrom(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    if (json == null) return null;
    return _pickDouble(json, keys);
  }
}

extension _IfEmptyTry on String {
  String ifEmptyTry(String Function() fallback) =>
      isEmpty ? fallback() : this;
}
