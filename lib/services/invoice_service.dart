import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/service_history.dart';
import 'api_client.dart';

class InvoiceService {
  InvoiceService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// GET /api/v1/invoice/{id} — full invoice / bill data.
  Future<ServiceHistory> fetchInvoice(String invoiceId) async {
    return _api.handleAuthErrors(() async {
      return await _api.getInvoice(invoiceId);
    });
  }

  /// Opens the bill for a service record using invoice download, bill URL, or detail.
  Future<void> openBill(ServiceHistory record) async {
    final invoiceId = record.effectiveInvoiceId;
    if (invoiceId != null) {
      try {
        await _openInvoiceDownload(invoiceId);
        return;
      } catch (_) {
        // Fall through to bill URL when download is unavailable.
      }
    }

    final url = record.billUrl?.trim();
    if (url == null || url.isEmpty) {
      throw Exception('Bill is not available for this service yet.');
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Bill link is invalid.');
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception('Could not open bill.');
    }
  }

  Future<void> _openInvoiceDownload(String invoiceId) async {
    final response = await _api.handleAuthErrors(
      () => _api.downloadInvoice(invoiceId),
    );

    if (!_api.isSuccessful(response)) {
      throw Exception(
        'Invoice download failed: ${response.statusCode} - ${response.body}',
      );
    }

    final contentType = response.headers['content-type']?.toLowerCase() ?? '';

    if (contentType.contains('application/json')) {
      final url = _extractDownloadUrl(response);
      if (url == null) {
        throw Exception('Invoice download URL missing in response.');
      }
      final uri = Uri.tryParse(url);
      if (uri == null) {
        throw Exception('Invoice download URL is invalid.');
      }
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Could not open invoice.');
      }
      return;
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('Invoice file is empty.');
    }

    final extension = contentType.contains('pdf') ? 'pdf' : 'bin';
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/invoice_$invoiceId.$extension');
    await file.writeAsBytes(response.bodyBytes, flush: true);

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  String? _extractDownloadUrl(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return null;

      final data = json['data'];
      if (data is String && data.trim().isNotEmpty) return data.trim();
      if (data is Map<String, dynamic>) {
        for (final key in const [
          'url',
          'download_url',
          'downloadUrl',
          'invoice_url',
          'invoiceUrl',
          'bill_url',
          'billUrl',
          'pdf_url',
          'pdfUrl',
        ]) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) return value.trim();
        }
      }

      for (final key in const [
        'url',
        'download_url',
        'downloadUrl',
        'invoice_url',
        'invoiceUrl',
      ]) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
