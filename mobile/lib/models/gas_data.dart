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

    return GasData(
      timestamp: (json['timestamp'] ?? DateTime.now().toIso8601String())
          .toString(),
      temperature: ((data['temperature'] ?? 0) as num).toDouble(),
      co2: ((data['co2'] ?? 0) as num).toDouble(),
      humidity: ((data['humidity'] ?? 0) as num).toDouble(),
      pressure: ((data['pressure'] ?? 0) as num).toDouble(),
      source: (json['source'] ?? 'unknown').toString(),
    );
  }
}
