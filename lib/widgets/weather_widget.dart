import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<AppState>().weather;
    if (weather == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wb_sunny, color: Colors.orange),
            const SizedBox(width: 8),
            Text('${weather.temperature.toStringAsFixed(1)}°C'),
          ],
        ),
      ),
    );
  }
}
