import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gas_data.dart';
import '../state/app_state.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final gasData = appState.gasData;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 90),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181F3D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2E3A66)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appState.isConnected ? Icons.flash_on : Icons.flash_off,
                        color: appState.isConnected
                            ? const Color(0xFF00F38D)
                            : const Color(0xFF8A94B6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              appState.isConnected
                                  ? 'Connected to backend'
                                  : 'Waiting for backend connection',
                              style: const TextStyle(color: Color(0xFF9AA6C7)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        appState.isConnected ? '● Online' : '● Offline',
                        style: TextStyle(
                          color: appState.isConnected
                              ? const Color(0xFF00F38D)
                              : const Color(0xFF8A94B6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DeviceCard(
                  icon: Icons.wind_power,
                  title: 'Exhaust Fan System',
                  subtitle: 'Automated ventilation control',
                  statusLabel: appState.fanOn ? 'On' : 'Standby',
                  statusValue: appState.fanOn ? 'ON' : 'OFF',
                  active: appState.fanOn,
                  onChanged: (value) => appState.setFan(value),
                  leftMetricTitle: 'Speed',
                  leftMetricValue: appState.fanOn ? 'High' : 'Off',
                  rightMetricTitle: 'Power',
                  rightMetricValue: appState.fanOn ? '42W' : '0W',
                ),
                const SizedBox(height: 12),
                _DeviceCard(
                  icon: Icons.gas_meter,
                  title: 'Gas Valve Controller',
                  subtitle: 'Emergency shutoff system',
                  statusLabel: appState.valveOpen ? 'Open' : 'Closed',
                  statusValue: appState.valveOpen ? 'ON' : 'OFF',
                  active: appState.valveOpen,
                  onChanged: (value) => appState.setValve(value),
                  leftMetricTitle: 'State',
                  leftMetricValue: appState.valveOpen ? 'Open' : 'Closed',
                  rightMetricTitle: 'Response',
                  rightMetricValue: '< 500ms',
                ),
                const SizedBox(height: 12),
                _SensorCard(gasData: gasData),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181F3D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2E3A66)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: 'Sensor ID',
                        value: gasData?.sensorId ?? 'No data',
                      ),
                      _InfoRow(
                        label: 'Last Update',
                        value: gasData?.timestamp ?? 'No data',
                      ),
                    ],
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

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusValue,
    required this.active,
    required this.onChanged,
    required this.leftMetricTitle,
    required this.leftMetricValue,
    required this.rightMetricTitle,
    required this.rightMetricValue,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String statusLabel;
  final String statusValue;
  final bool active;
  final ValueChanged<bool> onChanged;
  final String leftMetricTitle;
  final String leftMetricValue;
  final String rightMetricTitle;
  final String rightMetricValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? const Color(0xFF00AA73) : const Color(0xFF2E3A66),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F38D).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF00F38D), size: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF9AA6C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111833),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(color: Color(0xFF8A94B6)),
                    ),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Color(0xFF00F38D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(statusValue, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                Switch(value: active, onChanged: onChanged),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: leftMetricTitle,
                  value: leftMetricValue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: rightMetricTitle,
                  value: rightMetricValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.gasData});

  final GasData? gasData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00AA73)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Color(0xFF00F38D)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MQ6 Gas Sensor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'LPG and natural gas detection',
                      style: TextStyle(color: Color(0xFF9AA6C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: 'Status',
                  value: gasData == null ? 'No data' : 'Active',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'CO2',
                  value: gasData == null
                      ? '--'
                      : '${gasData!.co2.toStringAsFixed(1)} ppm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'Gas',
                  value: gasData == null
                      ? '--'
                      : gasData!.gasLevel.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111833),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8A94B6), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFA6B2D5))),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
