import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../state/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final status = appState.safetyStatus;
        final statusColor = switch (status) {
          'DANGER' => const Color(0xFFFF3B5C),
          'WARNING' => const Color(0xFFFFC12A),
          'NO DATA' => const Color(0xFF8A94B6),
          _ => const Color(0xFF00F38D),
        };

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withAlpha(170)),
                      color: const Color(0xFF161C39),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            color: Color(0xFF7E8AB3),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'System Controls',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ControlTile(
                          icon: Icons.wind_power,
                          title: 'Exhaust Fan',
                          active: appState.fanOn,
                          onTap: () => appState.setFan(!appState.fanOn),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ControlTile(
                          icon: Icons.gas_meter,
                          title: 'Gas Valve',
                          active: appState.valveOpen,
                          onTap: () => appState.setValve(!appState.valveOpen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _LiveSensorCard(appState: appState),
                  const SizedBox(height: 14),
                  _InfoCard(
                    title: 'Recent Activity',
                    child: appState.activity.isEmpty
                        ? const Text(
                            'Waiting for backend activity...',
                            style: TextStyle(color: Color(0xFF8A94B6)),
                          )
                        : Column(
                            children: appState.activity
                                .take(3)
                                .map(
                                  (entry) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: entry.success
                                              ? const Color(0xFF00F38D)
                                              : const Color(0xFF8A94B6),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.message,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                entry.timeAgo,
                                                style: const TextStyle(
                                                  color: Color(0xFF8A94B6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 14),
                  _InfoCard(
                    title: 'Gas Levels (Real-time)',
                    child: appState.co2History.isEmpty
                        ? const SizedBox(
                            height: 80,
                            child: Center(
                              child: Text(
                                'No backend readings yet.',
                                style: TextStyle(color: Color(0xFF8A94B6)),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 260,
                            child: CustomPaint(
                              painter: _SimpleLineChartPainter(
                                points: appState.co2History,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiveSensorCard extends StatelessWidget {
  const _LiveSensorCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final gasData = appState.gasData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Color(0x1F00F38D),
                child: Icon(Icons.sensors, size: 16, color: Color(0xFF00F38D)),
              ),
              SizedBox(width: 10),
              Text(
                'Live Backend Data',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (gasData == null)
            const Text(
              'Waiting for readings from backend websocket...',
              style: TextStyle(color: Color(0xFF8A94B6)),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LiveRow(label: 'Sensor', value: gasData.deviceName),
                _LiveRow(
                  label: 'CO2',
                  value: '${gasData.co2.toStringAsFixed(1)} ppm',
                ),
                _LiveRow(
                  label: 'Gas Level',
                  value: gasData.gasLevel.toStringAsFixed(1),
                ),
                _LiveRow(label: 'Timestamp', value: gasData.timestamp),
                _LiveRow(label: 'Source', value: gasData.source),
              ],
            ),
        ],
      ),
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8A94B6)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({
    required this.icon,
    required this.title,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF181F3D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF00F38D) : const Color(0xFF2E3A66),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? const Color(0xFF00F38D).withAlpha(20)
                    : const Color(0xFF2A3357),
              ),
              child: Icon(
                icon,
                size: 36,
                color: active
                    ? const Color(0xFF00F38D)
                    : const Color(0xFF8A94B6),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              active ? 'ON' : 'OFF',
              style: TextStyle(
                color: active
                    ? const Color(0xFF00F38D)
                    : const Color(0xFF9AA6C7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181F3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3A66)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  _SimpleLineChartPainter({required this.points});

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const bottomPad = 24.0;
    final chartRect = Rect.fromLTWH(
      leftPad,
      8,
      size.width - leftPad - 10,
      size.height - bottomPad - 12,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFF31406A)
      ..strokeWidth = 1;

    for (int i = 0; i <= 6; i++) {
      final y = chartRect.top + (chartRect.height / 6) * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 10; i++) {
      final x = chartRect.left + (chartRect.width / 10) * i;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }

    if (points.isEmpty) return;

    final minY = points.reduce(math.min) - 40;
    final maxY = points.reduce(math.max) + 40;
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x =
          chartRect.left +
          (chartRect.width * i / math.max(points.length - 1, 1));
      final normalized = (points[i] - minY) / math.max((maxY - minY), 1);
      final y = chartRect.bottom - normalized * chartRect.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF00F38D)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SimpleLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
