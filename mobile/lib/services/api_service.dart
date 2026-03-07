import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://agas-backend-agtlp.ondigitalocean.app';

  static void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[ApiService] $message');
  }

  static Uri _resolveEndpoint(String rawUrl, String path) {
    final parsed = Uri.tryParse(rawUrl);

    if (parsed != null && parsed.path.endsWith(path)) {
      return parsed;
    }

    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return parsed.resolve(path);
    }

    final normalized = rawUrl.endsWith('/')
        ? rawUrl.substring(0, rawUrl.length - 1)
        : rawUrl;
    return Uri.parse('$normalized$path');
  }

  static Future<String> sendGasData(
    Map<String, dynamic> data, {
    String? serverUrl,
  }) async {
    final rawUrl = (serverUrl ?? baseUrl).trim();
    final endpoint = _resolveEndpoint(rawUrl, '/api/gas-data');
    _log('POST $endpoint payload=${jsonEncode(data)}');

    final response = await http
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 10));

    _log('POST $endpoint -> ${response.statusCode} ${response.body}');

    return response.body;
  }

  static Future<Map<String, dynamic>> fetchHealth({String? serverUrl}) async {
    final rawUrl = (serverUrl ?? baseUrl).trim();
    final candidates = <Uri>[
      _resolveEndpoint(rawUrl, '/health'),
      _resolveEndpoint(rawUrl, '/api/health'),
    ];

    for (final endpoint in candidates) {
      try {
        _log('GET $endpoint');
        final response = await http
            .get(endpoint)
            .timeout(const Duration(seconds: 8));

        _log('GET $endpoint -> ${response.statusCode} ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          if (decoded is Map) {
            return decoded.map((k, v) => MapEntry('$k', v));
          }
          return {'status': 'ok'};
        }
      } catch (_) {
        _log('GET $endpoint -> failed');
        continue;
      }
    }

    return {'status': 'down'};
  }

  static Future<Map<String, dynamic>> _getJson(
    String path, {
    String? serverUrl,
  }) async {
    final rawUrl = (serverUrl ?? baseUrl).trim();
    final endpoint = _resolveEndpoint(rawUrl, path);

    _log('GET $endpoint');
    final response = await http
        .get(endpoint)
        .timeout(const Duration(seconds: 8));
    _log('GET $endpoint -> ${response.statusCode} ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {'status': 'error'};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry('$k', v));
    }

    return {'status': 'error'};
  }

  static Future<Map<String, dynamic>> fetchCurrentMetrics({
    String? serverUrl,
  }) async {
    try {
      return await _getJson('/v1/metrics/current', serverUrl: serverUrl);
    } catch (_) {
      return {'status': 'error'};
    }
  }

  static Future<Map<String, dynamic>> fetchControlState({
    String? serverUrl,
  }) async {
    try {
      return await _getJson('/v1/control/state', serverUrl: serverUrl);
    } catch (_) {
      return {'status': 'error'};
    }
  }

  static Future<Map<String, dynamic>> fetchAlerts({
    String? serverUrl,
    int limit = 50,
  }) async {
    final safeLimit = limit.clamp(1, 200);
    try {
      return await _getJson(
        '/v1/alerts?status=all&limit=$safeLimit',
        serverUrl: serverUrl,
      );
    } catch (_) {
      return {'status': 'error'};
    }
  }
}
