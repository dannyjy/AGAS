import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/device_button.dart';
import '../widgets/gas_data_card.dart';
import '../widgets/status_indicator.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final gasData = appState.gasData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gas Monitoring Dashboard'),
            actions: [
              Row(
                children: [
                  Icon(
                    appState.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: appState.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
          body: gasData == null
              ? const Center(child: Text('Waiting for data...'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          GasDataCard(
                            icon: Icons.thermostat,
                            title: 'Temperature',
                            value:
                                '${gasData.temperature.toStringAsFixed(1)} C',
                          ),
                          GasDataCard(
                            icon: Icons.co2,
                            title: 'CO2',
                            value: '${gasData.co2.toStringAsFixed(0)} ppm',
                          ),
                          GasDataCard(
                            icon: Icons.water_drop,
                            title: 'Humidity',
                            value: '${gasData.humidity.toStringAsFixed(1)} %',
                          ),
                          GasDataCard(
                            icon: Icons.speed,
                            title: 'Pressure',
                            value: '${gasData.pressure.toStringAsFixed(1)} hPa',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'System Status',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              StatusIndicator(status: appState.safetyStatus),
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
                              Text('Fan: ${appState.fanOn ? 'ON' : 'OFF'}'),
                              const SizedBox(height: 4),
                              Text(
                                'Valve: ${appState.valveOpen ? 'OPEN' : 'CLOSED'}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sensor: ${appState.sensorOnline ? 'ONLINE' : 'OFFLINE'}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DeviceButton(
                            icon: Icons.air,
                            label: appState.fanOn
                                ? 'Turn Fan Off'
                                : 'Turn Fan On',
                            onTap: () => appState.setFan(!appState.fanOn),
                          ),
                          const SizedBox(width: 8),
                          DeviceButton(
                            icon: Icons.notification_important,
                            label: 'Test Alert',
                            color: Colors.orange,
                            onTap: appState.testAlert,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Last Update: ${gasData.timestamp}'),
                      Text('Source: ${gasData.source}'),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
