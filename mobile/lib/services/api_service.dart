import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://localhost:3000';

  static Future<String> sendGasData(
    Map<String, dynamic> data, {
    String? serverUrl,
  }) async {
    final url = serverUrl ?? baseUrl;

    final response = await http.post(
      Uri.parse('$url/api/gas-data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return response.body;
  }
}
