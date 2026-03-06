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
  double _co2Warning = 600;
  double _co2Critical = 1000;
  double _temperatureWarning = 28;
  double _temperatureCritical = 32;
  bool _alertsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _autoFanEnabled = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isLoaded) return;

    final appState = context.read<AppState>();
    _serverController.text = appState.serverUrl;
    _co2Warning = appState.co2WarningLevel;
    _co2Critical = appState.co2CriticalLevel;
    _temperatureWarning = appState.temperatureWarningLevel;
    _temperatureCritical = appState.temperatureCriticalLevel;
    _alertsEnabled = appState.enableAlerts;
    _soundEnabled = appState.enableSound;
    _vibrationEnabled = appState.enableVibration;
    _autoFanEnabled = appState.autoFanControl;
    _isLoaded = true;
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 90),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Configure system preferences',
            style: TextStyle(color: Color(0xFF97A4C8)),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.storage,
            title: 'Server Connection',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Server URL',
                  style: TextStyle(color: Color(0xFFAEBADF)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serverController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF111833),
                    hintText: 'https://backend-agas.vercel.app',
                    hintStyle: const TextStyle(color: Color(0xFF7080AF)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF324171)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF324171)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.notifications_none,
            title: 'Alert Thresholds',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SliderRow(
                  label:
                      'CO2 Warning Level: ${_co2Warning.toStringAsFixed(0)} ppm',
                  value: _co2Warning,
                  min: 300,
                  max: 1200,
                  onChanged: (value) => setState(() => _co2Warning = value),
                ),
                const SizedBox(height: 8),
                _SliderRow(
                  label:
                      'CO2 Danger Level: ${_co2Critical.toStringAsFixed(0)} ppm',
                  value: _co2Critical,
                  min: 500,
                  max: 2000,
                  onChanged: (value) => setState(() => _co2Critical = value),
                ),
                const SizedBox(height: 8),
                _SliderRow(
                  label:
                      'Temperature Warning: ${_temperatureWarning.toStringAsFixed(0)}°C',
                  value: _temperatureWarning,
                  min: 20,
                  max: 60,
                  onChanged: (value) =>
                      setState(() => _temperatureWarning = value),
                ),
                const SizedBox(height: 8),
                _SliderRow(
                  label:
                      'Temperature Danger: ${_temperatureCritical.toStringAsFixed(0)}°C',
                  value: _temperatureCritical,
                  min: 25,
                  max: 90,
                  onChanged: (value) =>
                      setState(() => _temperatureCritical = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.tips_and_updates_outlined,
            title: 'Notifications',
            child: Column(
              children: [
                _ToggleRow(
                  title: 'Sound Alerts',
                  subtitle: 'Play sound on critical alerts',
                  value: _soundEnabled,
                  onChanged: (value) => setState(() => _soundEnabled = value),
                ),
                _ToggleRow(
                  title: 'Vibration',
                  subtitle: 'Vibrate on danger alerts',
                  value: _vibrationEnabled,
                  onChanged: (value) =>
                      setState(() => _vibrationEnabled = value),
                ),
                _ToggleRow(
                  title: 'Auto Fan Control',
                  subtitle: 'Automatically activate fan on high CO2',
                  value: _autoFanEnabled,
                  onChanged: (value) => setState(() => _autoFanEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _AboutCard(),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00E58F),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              context.read<AppState>().updateSettings(
                server: _serverController.text,
                warningLevel: _co2Warning,
                criticalLevel: _co2Critical,
                temperatureWarning: _temperatureWarning,
                temperatureCritical: _temperatureCritical,
                alertsEnabled: _alertsEnabled,
                soundEnabled: _soundEnabled,
                vibrationEnabled: _vibrationEnabled,
                autoFanEnabled: _autoFanEnabled,
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings updated')));
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt, size: 18),
                SizedBox(width: 8),
                Text(
                  'Save Settings',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F38D).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF00F38D)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFC12A),
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.white,
          inactiveColor: const Color(0xFF2F3A62),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8C98BA)),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00F38D)),
              SizedBox(width: 10),
              Text(
                'About',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _InfoRow(label: 'Version', value: '1.0.0'),
          _InfoRow(label: 'Build', value: '2024.03.06'),
          _InfoRow(label: 'Platform', value: 'Arduino + Flutter'),
          SizedBox(height: 10),
          Text(
            'Smart Gas Safety Monitoring System designed for real-time detection and control of gas leaks using MQ6 sensors and Arduino hardware.',
            style: TextStyle(color: Color(0xFFAAB6D8)),
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
          Text(label, style: const TextStyle(color: Color(0xFFA8B5D8))),
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
