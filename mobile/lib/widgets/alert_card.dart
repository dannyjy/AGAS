import 'package:flutter/material.dart';

import '../state/app_state.dart';

class AlertCard extends StatelessWidget {
  final GasAlert alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        title: Text(alert.title),
        subtitle: Text(
          'Time: ${alert.timestamp}\nCO2: ${alert.co2.toStringAsFixed(0)} ppm',
        ),
      ),
    );
  }
}
