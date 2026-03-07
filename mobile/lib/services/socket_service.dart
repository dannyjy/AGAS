import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';

class SocketService {
  io.Socket? _socket;

  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[SocketService] $message');
  }

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String serverUrl,
    required void Function(dynamic data) onGasUpdate,
    required void Function(bool connected) onConnectionChanged,
    required void Function(dynamic data) onAlert,
    required void Function(dynamic data) onStateUpdate,
  }) {
    _log('connect(serverUrl=$serverUrl)');
    _socket?.disconnect();
    _socket?.dispose();

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      _log('onConnect');
      onConnectionChanged(true);
    });

    _socket?.on('gas-data-update', (data) {
      _log('on gas-data-update payload=$data');
      onGasUpdate(data);
    });

    _socket?.on('sensor_update', (data) {
      _log('on sensor_update payload=$data');
      onGasUpdate(data);
    });

    _socket?.on('gas-alert', (data) {
      _log('on gas-alert payload=$data');
      onAlert(data);
    });

    _socket?.on('system-status', (data) {
      _log('on system-status payload=$data');
      onStateUpdate(data);
    });

    _socket?.on('status-update', (data) {
      _log('on status-update payload=$data');
      onStateUpdate(data);
    });

    _socket?.on('device-status', (data) {
      _log('on device-status payload=$data');
      onStateUpdate(data);
    });

    _socket?.on('state-update', (data) {
      _log('on state-update payload=$data');
      onStateUpdate(data);
    });

    _socket?.on('fan-status', (data) {
      _log('on fan-status payload=$data');
      onStateUpdate(data);
    });

    _socket?.on('valve-status', (data) {
      _log('on valve-status payload=$data');
      onStateUpdate(data);
    });

    _socket?.onDisconnect((_) {
      _log('onDisconnect');
      onConnectionChanged(false);
    });

    _socket?.onError((error) {
      _log('onError payload=$error');
      onConnectionChanged(false);
    });

    _socket?.onConnectError((error) {
      _log('onConnectError payload=$error');
      onConnectionChanged(false);
    });
  }

  void fetchFromApi(String url) {
    _log('emit fetch-gas-data payload={apiUrl: $url}');
    _socket?.emit('fetch-gas-data', {'apiUrl': url});
  }

  void requestCurrentState(String apiUrl) {
    _log('emit requestCurrentState(apiUrl=$apiUrl)');
    _socket?.emit('fetch-gas-data', {'apiUrl': apiUrl});
    _socket?.emit('get-system-status');
    _socket?.emit('get-device-status');
    _socket?.emit('get-fan-status');
    _socket?.emit('get-valve-status');
    _socket?.emit('request-current-state');
  }

  void setFan(bool on) {
    _log('emit fan-control payload={state: ${on ? 'on' : 'off'}}');
    _socket?.emit('fan-control', {'state': on ? 'on' : 'off'});
  }

  void setValve(bool open) {
    _log('emit valve-control payload={state: ${open ? 'open' : 'close'}}');
    _socket?.emit('valve-control', {'state': open ? 'open' : 'close'});
  }

  void disconnect() {
    _log('disconnect()');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
