import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/gas_data.dart';
import '../services/api_service.dart';
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
      'https://agas-backend-agtlp.ondigitalocean.app/api/gas-data';

  final SocketService _socketService = SocketService();

  GasData? gasData;
  bool isConnected = false;
  bool isApiHealthy = false;
  String healthStatus = 'unknown';
  String backendSystemStatus = 'unknown';
  bool fanOn = false;
  bool valveOpen = true;
  bool sensorOnline = true;
  String serverUrl = _normalizeServerUrl(_defaultApiEndpoint);
  double co2WarningLevel = 1000;
  double co2CriticalLevel = 1500;
  double gasWarningLevel = 10;
  double gasCriticalLevel = 20;
  bool enableAlerts = true;
  bool enableSound = true;
  bool enableVibration = false;
  bool autoFanControl = false;
  final List<GasAlert> alerts = [];
  final List<double> co2History = [];
  final List<ActivityItem> activity = [];

  bool _isInitialized = false;
  Timer? _healthTimer;
  Timer? _backendSyncTimer;

  bool get isBackendOnline => isConnected && isApiHealthy;

  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[AppState] $message');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _log('initialize()');
    _isInitialized = true;

    await refreshAllFromBackend(notify: false);
    connectSocket();
    await checkBackendHealth(notify: false);

    _backendSyncTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      await refreshAllFromBackend();
    });

    _healthTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await checkBackendHealth();
      if (!isConnected) {
        connectSocket();
      }
    });
    notifyListeners();
  }

  Future<void> refreshAllFromBackend({bool notify = true}) async {
    _log('refreshAllFromBackend()');

    final results = await Future.wait([
      ApiService.fetchCurrentMetrics(serverUrl: serverUrl),
      ApiService.fetchControlState(serverUrl: serverUrl),
      ApiService.fetchAlerts(serverUrl: serverUrl, limit: 50),
    ]);

    final metrics = results[0];
    final control = results[1];
    final alertsResponse = results[2];

    _applyCurrentMetrics(metrics);
    _applyControlState(control);
    _applyAlerts(alertsResponse);

    if (notify) {
      notifyListeners();
    }
  }

  void _applyCurrentMetrics(Map<String, dynamic> response) {
    if ((response['status'] ?? '').toString().toLowerCase() != 'success') {
      return;
    }

    final data = _mapFrom(response['data']);
    if (data.isEmpty) return;

    final readings = _mapFrom(data['readings']);
    final payload = <String, dynamic>{
      'timestamp': data['timestamp'],
      'sensorId': data['sensorId'] ?? data['sensor_id'] ?? 'Main Sensor Hub',
      'co2': readings['co2'] ?? data['co2'],
      'gas_level': readings['gas_level'] ?? data['gas_level'],
      'system_status': data['system_status'],
    };

    _handleGasUpdate(payload, trackActivity: false);
  }

  void _applyControlState(Map<String, dynamic> response) {
    if ((response['status'] ?? '').toString().toLowerCase() != 'success') {
      return;
    }

    final data = _mapFrom(response['data']);
    if (data.isEmpty) return;

    final fan = _boolFrom(data, const ['fan_active']);
    if (fan != null) fanOn = fan;

    final valve = _boolFrom(data, const ['valve_open']);
    if (valve != null) valveOpen = valve;
  }

  void _applyAlerts(Map<String, dynamic> response) {
    if ((response['status'] ?? '').toString().toLowerCase() != 'success') {
      return;
    }

    final list = response['data'];
    if (list is! List) return;

    final parsed = <GasAlert>[];
    for (final item in list) {
      if (item is! Map) continue;
      final map = item.map((k, v) => MapEntry('$k', v));
      final title =
          (map['message'] ?? map['title'] ?? map['type'] ?? 'Gas Alert')
              .toString();
      final timestamp =
          (map['created_at'] ??
                  map['timestamp'] ??
                  DateTime.now().toIso8601String())
              .toString();
      final value = map['value'];
      final co2 = value is num
          ? value.toDouble()
          : double.tryParse('$value') ?? 0;

      parsed.add(GasAlert(title: title, timestamp: timestamp, co2: co2));
      if (parsed.length >= 50) break;
    }

    alerts
      ..clear()
      ..addAll(parsed);
  }

  void connectSocket() {
    _log('connectSocket(serverUrl=$serverUrl)');
    _socketService.connect(
      serverUrl: serverUrl,
      onGasUpdate: _handleGasUpdate,
      onConnectionChanged: (connected) {
        _log('onConnectionChanged(connected=$connected)');
        isConnected = connected;
        if (connected) {
          _log('requesting startup state sync');
          _socketService.requestCurrentState(_gasDataEndpoint);
        }
        notifyListeners();
      },
      onAlert: _handleIncomingAlert,
      onStateUpdate: _handleStateUpdate,
    );
  }

  String get _gasDataEndpoint {
    final parsed = Uri.tryParse(serverUrl);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return parsed.resolve('/api/gas-data').toString();
    }

    final normalized = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    return '$normalized/api/gas-data';
  }

  Future<void> checkBackendHealth({bool notify = true}) async {
    _log('checkBackendHealth()');
    final health = await ApiService.fetchHealth(serverUrl: serverUrl);

    final nextApiHealthy = health['status'] == 'ok';
    final nextHealthStatus = (health['status'] ?? 'down').toString();

    isApiHealthy = nextApiHealthy;
    healthStatus = nextHealthStatus;
    _log('health result: status=$healthStatus, isApiHealthy=$isApiHealthy');

    if (notify) {
      notifyListeners();
    }
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

  void _handleGasUpdate(dynamic payload, {bool trackActivity = true}) {
    if (payload is! Map) {
      _log('ignored gas update payload type=${payload.runtimeType}');
      return;
    }

    _log('gas update payload=$payload');

    final map = payload.map((k, v) => MapEntry('$k', v));
    final parsed = GasData.fromJson(map);

    final hasCo2 = _hasNumeric(map, const ['co2']);
    final hasGasLevel = _hasNumeric(map, const ['gasLevel', 'gas_level']);

    final previous = gasData;
    gasData = GasData(
      timestamp: parsed.timestamp,
      co2: hasCo2 ? parsed.co2 : (previous?.co2 ?? parsed.co2),
      gasLevel: hasGasLevel
          ? parsed.gasLevel
          : (previous?.gasLevel ?? parsed.gasLevel),
      sensorId: parsed.sensorId == 'Main Sensor Hub' && previous != null
          ? previous.sensorId
          : parsed.sensorId,
    );

    final payloadRoot = _mapFrom(map['payload']);
    final systemStatusRaw =
        (payloadRoot['system_status'] ?? map['system_status'])?.toString();
    if (systemStatusRaw != null && systemStatusRaw.trim().isNotEmpty) {
      backendSystemStatus = systemStatusRaw.trim().toLowerCase();
      _log('backendSystemStatus updated to $backendSystemStatus');
    }

    final controlState = _mapFrom(payloadRoot['control_state']);
    final fan = _boolFrom(controlState, const ['fan_active']);
    if (fan != null) {
      fanOn = fan;
      _log('fanOn updated to $fanOn from control_state');
    }
    final valve = _boolFrom(controlState, const ['valve_open']);
    if (valve != null) {
      valveOpen = valve;
      _log('valveOpen updated to $valveOpen from control_state');
    }

    co2History.add(gasData!.co2);
    if (co2History.length > 20) {
      co2History.removeAt(0);
    }

    if (trackActivity) {
      _addActivity('Sensor readings updated', 'Just now', true);
    }

    if (autoFanControl &&
        (gasData!.co2 >= co2WarningLevel ||
            gasData!.gasLevel >= gasWarningLevel) &&
        !fanOn) {
      setFan(true);
      if (trackActivity) {
        _addActivity('Fan activated automatically', 'Just now', true);
      }
    }

    if (gasData!.co2 >= co2CriticalLevel ||
        gasData!.gasLevel >= gasCriticalLevel) {
      _addAlert('Gas leak detected', gasData!.co2, gasData!.timestamp);
      if (trackActivity) {
        _addActivity('Critical condition detected', 'Just now', false);
      }
    } else if (gasData!.co2 >= co2WarningLevel ||
        gasData!.gasLevel >= gasWarningLevel) {
      _addAlert('High gas level', gasData!.co2, gasData!.timestamp);
      if (trackActivity) {
        _addActivity('High gas level warning', 'Just now', false);
      }
    }

    notifyListeners();
  }

  void _handleIncomingAlert(dynamic payload) {
    if (payload is! Map<String, dynamic>) return;

    _log('incoming alert payload=$payload');

    final title = (payload['title'] ?? 'Gas Alert').toString();
    final co2 = ((payload['co2'] ?? 0) as num).toDouble();
    final timestamp = (payload['timestamp'] ?? DateTime.now().toIso8601String())
        .toString();

    _addAlert(title, co2, timestamp);
    _addActivity(title, 'Just now', false);
    notifyListeners();
  }

  void _handleStateUpdate(dynamic payload) {
    if (payload is! Map) return;

    _log('state update payload=$payload');

    final map = payload.map((k, v) => MapEntry('$k', v));
    final state = _mapFrom(map['state']);
    final data = _mapFrom(map['data']);
    final root = state.isNotEmpty ? state : (data.isNotEmpty ? data : map);
    final controlState = _mapFrom(root['control_state']);

    final fan =
        _boolFrom(root, const ['fanOn', 'fan', 'fanStatus']) ??
        _boolFrom(controlState, const ['fan_active']);
    if (fan != null) {
      fanOn = fan;
      _log('fanOn updated to $fanOn from state payload');
    }

    final valve =
        _boolFrom(root, const [
          'valveOpen',
          'valve',
          'valveStatus',
        ], openCloseText: true) ??
        _boolFrom(controlState, const ['valve_open']);
    if (valve != null) {
      valveOpen = valve;
      _log('valveOpen updated to $valveOpen from state payload');
    }

    final sensor =
        _boolFrom(root, const ['sensorOnline', 'sensorStatus']) ??
        _boolFrom(controlState, const ['sensor_online']);
    if (sensor != null) {
      sensorOnline = sensor;
      _log('sensorOnline updated to $sensorOnline from state payload');
    }

    final statusRaw = (root['system_status'] ?? controlState['system_status'])
        ?.toString();
    if (statusRaw != null && statusRaw.trim().isNotEmpty) {
      backendSystemStatus = statusRaw.trim().toLowerCase();
      _log(
        'backendSystemStatus updated to $backendSystemStatus from state payload',
      );
    }

    // Some backends include a latest reading in status snapshots.
    if (_hasAny(root, const ['co2', 'gasLevel', 'gas_level', 'timestamp'])) {
      _log(
        'state payload contains reading snapshot, forwarding to gas handler',
      );
      _handleGasUpdate(root);
      return;
    }

    notifyListeners();
  }

  Map<String, dynamic> _mapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  bool _hasAny(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) return true;
    }
    return false;
  }

  bool _hasNumeric(Map<String, dynamic> map, List<String> keys) {
    final data = _mapFrom(map['data']);
    final payload = _mapFrom(map['payload']);
    final readingsFromData = _mapFrom(data['readings']);
    final readingsFromPayload = _mapFrom(payload['readings']);

    for (final key in keys) {
      final value =
          readingsFromData[key] ??
          readingsFromPayload[key] ??
          data[key] ??
          payload[key] ??
          map[key];

      if (value is num) return true;
      if (value is String && double.tryParse(value) != null) return true;
    }
    return false;
  }

  bool? _boolFrom(
    Map<String, dynamic> map,
    List<String> keys, {
    bool openCloseText = false,
  }) {
    for (final key in keys) {
      if (!map.containsKey(key)) continue;

      final value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final text = value.trim().toLowerCase();
        if (text == 'true' || text == 'on' || text == 'online' || text == '1') {
          return true;
        }
        if (text == 'false' ||
            text == 'off' ||
            text == 'offline' ||
            text == '0') {
          return false;
        }
        if (openCloseText) {
          if (text == 'open') return true;
          if (text == 'close' || text == 'closed') return false;
        }
      }
    }
    return null;
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
    if (backendSystemStatus == 'danger' || backendSystemStatus == 'critical') {
      return 'DANGER';
    }
    if (backendSystemStatus == 'warning') {
      return 'WARNING';
    }
    if (backendSystemStatus == 'safe') {
      return 'SAFE';
    }

    if (gasData == null) {
      return 'NO DATA';
    }

    final currentCo2 = gasData?.co2 ?? 0;
    final currentGasLevel = gasData?.gasLevel ?? 0;
    if (currentCo2 >= co2CriticalLevel || currentGasLevel >= gasCriticalLevel) {
      return 'DANGER';
    }
    if (currentCo2 >= co2WarningLevel || currentGasLevel >= gasWarningLevel) {
      return 'WARNING';
    }
    return 'SAFE';
  }

  void setFan(bool value) {
    _log('setFan($value)');
    fanOn = value;
    _socketService.setFan(value);
    notifyListeners();
  }

  void setValve(bool open) {
    _log('setValve($open)');
    valveOpen = open;
    _socketService.setValve(open);
    notifyListeners();
  }

  void updateSettings({
    required String server,
    required double warningLevel,
    required double criticalLevel,
    required double gasWarning,
    required double gasCritical,
    required bool alertsEnabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
    required bool autoFanEnabled,
  }) {
    _log('updateSettings(server=$server)');
    final normalizedServer = _normalizeServerUrl(server);
    final shouldReconnect = normalizedServer != serverUrl;

    serverUrl = normalizedServer;
    co2WarningLevel = warningLevel;
    co2CriticalLevel = criticalLevel;
    gasWarningLevel = gasWarning;
    gasCriticalLevel = gasCritical;
    enableAlerts = alertsEnabled;
    enableSound = soundEnabled;
    enableVibration = vibrationEnabled;
    autoFanControl = autoFanEnabled;

    if (shouldReconnect) {
      _log('server changed, reconnecting socket');
      connectSocket();
      checkBackendHealth(notify: false);
    } else if (isConnected) {
      _log('server unchanged, requesting current state refresh');
      _socketService.requestCurrentState(_gasDataEndpoint);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _backendSyncTimer?.cancel();
    _healthTimer?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
