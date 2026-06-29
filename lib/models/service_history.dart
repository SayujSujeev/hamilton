import 'live_service.dart';

/// One row from GET /api/v1/user/service-history (list or detail).
class ServiceHistory {
  const ServiceHistory({
    required this.id,
    required this.serviceDate,
    required this.grandTotal,
    required this.vehicleId,
    required this.odoReading,
    required this.vehicleName,
    this.licensePlate = '',
    this.totalPartsCost = 0,
    this.totalLaborCost = 0,
    this.discount = 0,
    this.serviceNames = const [],
    this.items = const [],
    this.billUrl,
    this.invoiceId,
    this.serviceInTime,
    this.serviceOutTime,
  });

  final String id;
  final DateTime? serviceDate;
  final double grandTotal;
  final String vehicleId;
  final int odoReading;
  final String vehicleName;
  final String licensePlate;
  final double totalPartsCost;
  final double totalLaborCost;
  final double discount;
  final List<String> serviceNames;
  final List<LiveServiceItem> items;
  final String? billUrl;
  final String? invoiceId;
  final DateTime? serviceInTime;
  final DateTime? serviceOutTime;

  bool get hasBillUrl => billUrl != null && billUrl!.trim().isNotEmpty;

  bool get hasInvoiceId => invoiceId != null && invoiceId!.trim().isNotEmpty;

  /// Invoice API id when present, otherwise the service history id.
  String? get effectiveInvoiceId {
    if (hasInvoiceId) return invoiceId!.trim();
    if (id.trim().isNotEmpty) return id.trim();
    return null;
  }

  bool get hasCostBreakdown =>
      totalPartsCost > 0 || totalLaborCost > 0 || discount > 0;

  bool get hasItems => items.isNotEmpty;

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    final rawDate = json['service_date'] ?? json['serviceDate'];
    DateTime? serviceDate;
    if (rawDate is String && rawDate.isNotEmpty) {
      serviceDate = DateTime.tryParse(rawDate);
    }

    final vehicle = _asMap(json['vehicle'] ?? json['vehicle_detail']);
    final costSummary = _asMap(json['cost_summary'] ?? json['costSummary']);

    final vehicleId = _pickString(json, const ['vehicle_id', 'vehicleId'])
        .ifEmptyTry(() {
      if (vehicle == null) return '';
      return _pickString(vehicle, const ['id', 'vehicle_id', 'vehicleId']);
    });

    final vehicleName = _pickString(
      json,
      const ['vehicle_name', 'vehicleName', 'name'],
    ).ifEmptyTry(() {
      if (vehicle == null) return '';
      return _pickString(vehicle, const [
        'vehicle_name',
        'vehicleName',
        'name',
        'model',
      ]);
    });

    final odoReading = _pickInt(json, const ['odo_reading', 'odoReading']) ??
        _pickIntFrom(vehicle, const ['odo_reading', 'odoReading']) ??
        0;

    final licensePlate = _pickString(json, const [
      'license_plate',
      'licensePlate',
      'plate',
    ]).ifEmptyTry(() {
      if (vehicle == null) return '';
      return _pickString(vehicle, const [
        'license_plate',
        'licensePlate',
        'plate',
      ]);
    });

    final totalPartsCost = _pickDouble(json, const [
          'total_parts_cost',
          'totalPartsCost',
          'parts_total',
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

    return ServiceHistory(
      id: _pickString(json, const ['id', 'service_history_id']),
      serviceDate: serviceDate,
      grandTotal: grandTotal,
      vehicleId: vehicleId,
      odoReading: odoReading,
      vehicleName: vehicleName,
      licensePlate: licensePlate,
      totalPartsCost: totalPartsCost,
      totalLaborCost: totalLaborCost,
      discount: discount,
      serviceNames: _pickServiceNames(json),
      items: _pickItems(json),
      billUrl: _pickNullableString(json, const [
        'bill_url',
        'billUrl',
        'invoice_url',
        'invoiceUrl',
        'pdf_url',
        'pdfUrl',
      ]),
      invoiceId: _pickInvoiceId(json),
      serviceInTime: _pickDateTime(json, const [
        'service_in_time',
        'serviceInTime',
        'checked_in_at',
      ]),
      serviceOutTime: _pickDateTime(json, const [
        'service_out_time',
        'serviceOutTime',
        'checked_out_at',
      ]),
    );
  }

  static String? _pickInvoiceId(Map<String, dynamic> json) {
    final direct = _pickNullableString(json, const [
      'invoice_id',
      'invoiceId',
    ]);
    if (direct != null) return direct;

    final invoice = _asMap(json['invoice']);
    if (invoice != null) {
      final nested = _pickNullableString(invoice, const ['id', 'invoice_id']);
      if (nested != null) return nested;
    }

    return null;
  }

  static List<String> _pickServiceNames(Map<String, dynamic> json) {
    final names = <String>[];

    void addName(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      if (!names.contains(trimmed)) names.add(trimmed);
    }

    final services = json['services'] ?? json['service_list'] ?? json['booked_services'];
    if (services is List) {
      for (final entry in services) {
        if (entry is String) {
          addName(entry);
        } else if (entry is Map<String, dynamic>) {
          addName(_pickString(entry, const [
            'service_name',
            'serviceName',
            'name',
            'title',
          ]));
        }
      }
    }

    final single = _pickNullableString(json, const [
      'service_name',
      'serviceName',
      'description',
    ]);
    addName(single);

    return names;
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

  static Map<String, dynamic>? _asMap(dynamic raw) {
    return raw is Map<String, dynamic> ? raw : null;
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
      return v.toString().trim();
    }
    return null;
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

  static DateTime? _pickDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    }
    return null;
  }
}

extension _ServiceHistoryStringFallback on String {
  String ifEmptyTry(String Function() fallback) {
    if (isNotEmpty) return this;
    return fallback();
  }
}
