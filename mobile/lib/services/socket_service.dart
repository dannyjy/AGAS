import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String serverUrl,
    required void Function(dynamic data) onGasUpdate,
    required void Function(bool connected) onConnectionChanged,
    required void Function(dynamic data) onAlert,
  }) {
    _socket?.dispose();

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      onConnectionChanged(true);
    });

    _socket?.on('gas-data-update', (data) {
      onGasUpdate(data);
    });

    _socket?.on('gas-alert', (data) {
      onAlert(data);
    });

    _socket?.onDisconnect((_) {
      onConnectionChanged(false);
    });

    _socket?.onError((_) {
      onConnectionChanged(false);
    });
  }

  void fetchFromApi(String url) {
    _socket?.emit('fetch-gas-data', {'apiUrl': url});
  }

  void setFan(bool on) {
    _socket?.emit('fan-control', {'state': on ? 'on' : 'off'});
  }

  void setValve(bool open) {
    _socket?.emit('valve-control', {'state': open ? 'open' : 'close'});
  }

  void sendTestAlert() {
    _socket?.emit('test-alert');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
