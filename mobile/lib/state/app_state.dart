import 'package:flutter/foundation.dart';

import '../models/gas_data.dart';
import '../services/socket_service.dart';

class GasAlert {
  final String title;
  final String timestamp;
  final double co2;

  const GasAlert({
    required this.title,
    required this.timestamp,
    required this.co2,
  });
}

class ActivityItem {
  final String message;
  final String timeAgo;
  final bool success;

  const ActivityItem({
    required this.message,
    required this.timeAgo,
    required this.success,
  });
}

class AppState extends ChangeNotifier {
  static const String _defaultApiEndpoint =
      'https://backend-agas.vercel.app/api/gas-data';

  final SocketService _socketService = SocketService();

  GasData? gasData;
  bool isConnected = false;
  bool fanOn = false;
  bool valveOpen = true;
  bool sensorOnline = true;
  String serverUrl = _normalizeServerUrl(_defaultApiEndpoint);
  double co2WarningLevel = 800;
  double co2CriticalLevel = 1000;
  double temperatureWarningLevel = 28;
  double temperatureCriticalLevel = 32;
  bool enableAlerts = true;
  bool enableSound = true;
  bool enableVibration = false;
  bool autoFanControl = false;
  final List<GasAlert> alerts = [];
  final List<double> co2History = [
    340,
    338,
    336,
    340,
    342,
    339,
    341,
    340,
    345,
    355,
    368,
    375,
    386,
    395,
    402,
    410,
    418,
    430,
  ];
  final List<ActivityItem> activity = [
    const ActivityItem(
      message: 'Sensor readings normal',
      timeAgo: 'Just now',
      success: true,
    ),
    const ActivityItem(
      message: 'System initialized',
      timeAgo: '5 min ago',
      success: true,
    ),
  ];

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    connectSocket();
  }

  void connectSocket() {
    _socketService.connect(
      serverUrl: serverUrl,
      onGasUpdate: _handleGasUpdate,
      onConnectionChanged: (connected) {
        isConnected = connected;
        notifyListeners();
      },
      onAlert: _handleIncomingAlert,
    );
  }

  static String _normalizeServerUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return 'http://localhost:3000';

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return trimmed;
    }

    // If a full endpoint like /api/gas-data is provided, keep only origin for sockets.
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  void _handleGasUpdate(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return;
    }

    gasData = GasData.fromJson(payload);

    co2History.add(gasData!.co2);
    if (co2History.length > 20) {
      co2History.removeAt(0);
    }

    _addActivity('Sensor readings updated', 'Just now', true);

    if (autoFanControl &&
        (gasData!.co2 >= co2WarningLevel ||
            gasData!.temperature >= temperatureWarningLevel) &&
        !fanOn) {
      setFan(true);
      _addActivity('Fan activated automatically', 'Just now', true);
    }

    if (gasData!.co2 >= co2CriticalLevel ||
        gasData!.temperature >= temperatureCriticalLevel) {
      _addAlert('Gas leak detected', gasData!.co2, gasData!.timestamp);
      _addActivity('Critical condition detected', 'Just now', false);
    } else if (gasData!.co2 >= co2WarningLevel) {
      _addAlert('High gas level', gasData!.co2, gasData!.timestamp);
      _addActivity('High gas level warning', 'Just now', false);
    }

    notifyListeners();
  }

  void _handleIncomingAlert(dynamic payload) {
    if (payload is! Map<String, dynamic>) return;

    final title = (payload['title'] ?? 'Gas Alert').toString();
    final co2 = ((payload['co2'] ?? 0) as num).toDouble();
    final timestamp = (payload['timestamp'] ?? DateTime.now().toIso8601String())
        .toString();

    _addAlert(title, co2, timestamp);
    _addActivity(title, 'Just now', false);
    notifyListeners();
  }

  void _addAlert(String title, double co2, String timestamp) {
    alerts.insert(0, GasAlert(title: title, co2: co2, timestamp: timestamp));

    if (alerts.length > 50) {
      alerts.removeRange(50, alerts.length);
    }
  }

  void _addActivity(String message, String timeAgo, bool success) {
    activity.insert(
      0,
      ActivityItem(message: message, timeAgo: timeAgo, success: success),
    );

    if (activity.length > 10) {
      activity.removeRange(10, activity.length);
    }
  }

  String get safetyStatus {
    final currentTemperature = gasData?.temperature ?? 0;
    final currentCo2 = gasData?.co2 ?? 0;
    if (currentCo2 >= co2CriticalLevel ||
        currentTemperature >= temperatureCriticalLevel) {
      return 'DANGER';
    }
    if (currentCo2 >= co2WarningLevel ||
        currentTemperature >= temperatureWarningLevel) {
      return 'WARNING';
    }
    return 'SAFE';
  }

  void setFan(bool value) {
    fanOn = value;
    _socketService.setFan(value);
    notifyListeners();
  }

  void setValve(bool open) {
    valveOpen = open;
    _socketService.setValve(open);
    notifyListeners();
  }

  void testAlert() {
    _socketService.sendTestAlert();
    _addAlert(
      'Test alert',
      gasData?.co2 ?? 0,
      DateTime.now().toIso8601String(),
    );
    _addActivity('Test alert sent', 'Just now', true);
    notifyListeners();
  }

  void updateSettings({
    required String server,
    required double warningLevel,
    required double criticalLevel,
    required double temperatureWarning,
    required double temperatureCritical,
    required bool alertsEnabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
    required bool autoFanEnabled,
  }) {
    final normalizedServer = _normalizeServerUrl(server);
    final shouldReconnect = normalizedServer != serverUrl;

    serverUrl = normalizedServer;
    co2WarningLevel = warningLevel;
    co2CriticalLevel = criticalLevel;
    temperatureWarningLevel = temperatureWarning;
    temperatureCriticalLevel = temperatureCritical;
    enableAlerts = alertsEnabled;
    enableSound = soundEnabled;
    enableVibration = vibrationEnabled;
    autoFanControl = autoFanEnabled;

    if (shouldReconnect) {
      connectSocket();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
