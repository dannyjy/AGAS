import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _serverController;
  late final TextEditingController _warningController;
  late final TextEditingController _criticalController;
  bool _alertsEnabled = true;
  bool _soundEnabled = true;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController();
    _warningController = TextEditingController();
    _criticalController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoaded) return;

    final appState = context.read<AppState>();
    _serverController.text = appState.serverUrl;
    _warningController.text = appState.co2WarningLevel.toStringAsFixed(0);
    _criticalController.text = appState.co2CriticalLevel.toStringAsFixed(0);
    _alertsEnabled = appState.enableAlerts;
    _soundEnabled = appState.enableSound;
    _isLoaded = true;
  }

  @override
  void dispose() {
    _serverController.dispose();
    _warningController.dispose();
    _criticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Server Config',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://192.168.X.X:3000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert Thresholds',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _warningController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CO2 Warning Level',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _criticalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CO2 Critical Level',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _alertsEnabled,
                  title: const Text('Enable Alerts'),
                  onChanged: (value) {
                    setState(() {
                      _alertsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  value: _soundEnabled,
                  title: const Text('Enable Sound'),
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final warning = double.tryParse(_warningController.text) ?? 800;
              final critical =
                  double.tryParse(_criticalController.text) ?? 1000;

              context.read<AppState>().updateSettings(
                server: _serverController.text,
                warningLevel: warning,
                criticalLevel: critical,
                alertsEnabled: _alertsEnabled,
                soundEnabled: _soundEnabled,
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings updated')));
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
