class GasData {
  final String timestamp;
  final double temperature;
  final double co2;
  final double humidity;
  final double pressure;
  final String source;

  GasData({
    required this.timestamp,
    required this.temperature,
    required this.co2,
    required this.humidity,
    required this.pressure,
    required this.source,
  });

  factory GasData.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final readings =
        (data['readings'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    double parseValue(String key) {
      final value =
          readings[key] ?? data[key] ?? json[key] ?? data[key.toLowerCase()];
      if (value is num) return value.toDouble();
      return 0;
    }

    return GasData(
      timestamp: (json['timestamp'] ?? DateTime.now().toIso8601String())
          .toString(),
      temperature: parseValue('temperature'),
      co2: parseValue('co2'),
      humidity: parseValue('humidity'),
      pressure: parseValue('pressure'),
      source: (json['source'] ?? 'unknown').toString(),
    );
  }
}
