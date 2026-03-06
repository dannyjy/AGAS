import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final criticalCount = appState.alerts
            .where((a) => a.co2 >= appState.co2CriticalLevel)
            .length;
        final warningCount = appState.alerts
            .where(
              (a) =>
                  a.co2 >= appState.co2WarningLevel &&
                  a.co2 < appState.co2CriticalLevel,
            )
            .length;
        final latest = appState.alerts.isNotEmpty
            ? appState.alerts.first
            : null;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 90),
              children: [
                const Text(
                  'Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CounterCard(
                        value: '$criticalCount',
                        label: 'Critical',
                        color: const Color(0xFFFF3B5C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CounterCard(
                        value: '$warningCount',
                        label: 'Warning',
                        color: const Color(0xFFFFC12A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: _CounterCard(
                        value: '0',
                        label: 'Info',
                        color: Color(0xFF00F38D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Active Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _ActiveAlertCard(alert: latest),
                const SizedBox(height: 14),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...appState.activity
                    .take(3)
                    .map((item) => _ActivityCard(item: item)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 34)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF8A94B6))),
        ],
      ),
    );
  }
}

class _ActiveAlertCard extends StatelessWidget {
  const _ActiveAlertCard({required this.alert});

  final GasAlert? alert;

  @override
  Widget build(BuildContext context) {
    final hasAlert = alert != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC12A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC12A).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFFC12A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      hasAlert ? alert!.title : 'No active alerts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 27,
                      ),
                    ),
                    const Spacer(),
                    if (hasAlert)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC12A).withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Color(0xFFFFC12A),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasAlert
                      ? 'CO2 value is above warning threshold'
                      : 'All systems are currently normal',
                  style: const TextStyle(color: Color(0xFFB0BCDF)),
                ),
                if (hasAlert) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${alert!.co2.toStringAsFixed(0)} ppm',
                    style: const TextStyle(
                      color: Color(0xFFFFC12A),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF8A94B6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert!.timestamp,
                        style: const TextStyle(color: Color(0xFF8A94B6)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00F38D).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.success ? Icons.check_circle_outline : Icons.info_outline,
              color: item.success
                  ? const Color(0xFF00F38D)
                  : const Color(0xFFFFC12A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.success
                      ? 'All sensors functioning normally'
                      : 'Attention required',
                  style: const TextStyle(color: Color(0xFFB0BCDF)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF8A94B6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.timeAgo,
                      style: const TextStyle(color: Color(0xFF8A94B6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
