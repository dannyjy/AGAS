import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/device_button.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('System Controls')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fan Status: ${appState.fanOn ? 'ON' : 'OFF'}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            DeviceButton(
                              icon: Icons.power,
                              label: 'Turn On',
                              onTap: () => appState.setFan(true),
                            ),
                            const SizedBox(width: 8),
                            DeviceButton(
                              icon: Icons.power_off,
                              label: 'Turn Off',
                              onTap: () => appState.setFan(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gas Valve: ${appState.valveOpen ? 'OPEN' : 'CLOSED'}',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            DeviceButton(
                              icon: Icons.lock_open,
                              label: 'Open Valve',
                              onTap: () => appState.setValve(true),
                            ),
                            const SizedBox(width: 8),
                            DeviceButton(
                              icon: Icons.lock,
                              label: 'Close Valve',
                              onTap: () => appState.setValve(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: const Text('Sensor Test'),
                    subtitle: const Text(
                      'Send test alert to verify the notification flow.',
                    ),
                    trailing: IconButton(
                      onPressed: appState.testAlert,
                      icon: const Icon(Icons.science),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
