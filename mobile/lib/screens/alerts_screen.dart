import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Alerts')),
          body: appState.alerts.isEmpty
              ? const Center(child: Text('No alerts yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: appState.alerts.length,
                  itemBuilder: (context, index) {
                    return AlertCard(alert: appState.alerts[index]);
                  },
                ),
        );
      },
    );
  }
}
