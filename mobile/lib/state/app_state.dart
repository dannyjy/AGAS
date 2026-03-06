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

class AppState extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  GasData? gasData;
  bool isConnected = false;
  bool fanOn = false;
  bool valveOpen = true;
  bool sensorOnline = true;
  String serverUrl = 'http://localhost:3000';
  double co2WarningLevel = 800;
  double co2CriticalLevel = 1000;
  bool enableAlerts = true;
  bool enableSound = true;
  final List<GasAlert> alerts = [];

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

  void _handleGasUpdate(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      return;
    }

    gasData = GasData.fromJson(payload);

    if (gasData!.co2 >= co2CriticalLevel) {
      _addAlert('Gas leak detected', gasData!.co2, gasData!.timestamp);
    } else if (gasData!.co2 >= co2WarningLevel) {
      _addAlert('High gas level', gasData!.co2, gasData!.timestamp);
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
    notifyListeners();
  }

  void _addAlert(String title, double co2, String timestamp) {
    alerts.insert(0, GasAlert(title: title, co2: co2, timestamp: timestamp));

    if (alerts.length > 50) {
      alerts.removeRange(50, alerts.length);
    }
  }

  String get safetyStatus {
    final currentCo2 = gasData?.co2 ?? 0;
    if (currentCo2 >= co2CriticalLevel) return 'DANGER';
    if (currentCo2 >= co2WarningLevel) return 'WARNING';
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
    notifyListeners();
  }

  void updateSettings({
    required String server,
    required double warningLevel,
    required double criticalLevel,
    required bool alertsEnabled,
    required bool soundEnabled,
  }) {
    final shouldReconnect = server.trim() != serverUrl;

    serverUrl = server.trim();
    co2WarningLevel = warningLevel;
    co2CriticalLevel = criticalLevel;
    enableAlerts = alertsEnabled;
    enableSound = soundEnabled;

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
