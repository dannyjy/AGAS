import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://backend-agas.vercel.app';

  static Future<String> sendGasData(
    Map<String, dynamic> data, {
    String? serverUrl,
  }) async {
    final rawUrl = (serverUrl ?? baseUrl).trim();
    final parsed = Uri.tryParse(rawUrl);

    Uri endpoint;
    if (parsed != null && parsed.path.endsWith('/api/gas-data')) {
      endpoint = parsed;
    } else {
      endpoint = Uri.parse('$rawUrl/api/gas-data');
    }

    final response = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response.body;
  }
}
