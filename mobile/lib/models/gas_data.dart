class GasData {
  final String timestamp;
  final double co2;
  final double gasLevel;
  final String sensorId;
  final String deviceName;
  final String source;

  GasData({
    required this.timestamp,
    required this.co2,
    required this.gasLevel,
    required this.sensorId,
    required this.deviceName,
    required this.source,
  });

  factory GasData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapFrom(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return value.map((k, v) => MapEntry('$k', v));
      return <String, dynamic>{};
    }

    final data = mapFrom(json['data']);
    final payload = mapFrom(json['payload']);
    final root = data.isNotEmpty ? data : payload;
    final readings = mapFrom(root['readings']);

    double parseNum(List<String> keys) {
      for (final key in keys) {
        final value = readings[key] ?? root[key] ?? json[key];
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return 0;
    }

    String parseString(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = root[key] ?? json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    final sensorId = parseString(['sensorId', 'sensor_id'], 'Main Sensor Hub');

    return GasData(
      timestamp: parseString([
        'timestamp',
        'createdAt',
      ], DateTime.now().toIso8601String()),
      co2: parseNum(['co2']),
      gasLevel: parseNum(['gas_level', 'gasLevel']),
      sensorId: sensorId,
      deviceName: parseString(['deviceName', 'device_name'], sensorId),
      source: parseString(['source'], 'unknown'),
    );
  }
}
