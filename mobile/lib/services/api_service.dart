import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://agas-backend-agtlp.ondigitalocean.app';

  static Future<String> sendGasData(
    Map<String, dynamic> data, {
    String? serverUrl,
  }) async {
    final rawUrl = (serverUrl ?? baseUrl).trim();
    final parsed = Uri.tryParse(rawUrl);

    Uri endpoint;
    if (parsed != null && parsed.path.endsWith('/api/gas-data')) {
      endpoint = parsed;
    } else if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      endpoint = parsed.resolve('/api/gas-data');
    } else {
      final normalized = rawUrl.endsWith('/')
          ? rawUrl.substring(0, rawUrl.length - 1)
          : rawUrl;
      endpoint = Uri.parse('$normalized/api/gas-data');
    }

    final response = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response.body;
  }
}
