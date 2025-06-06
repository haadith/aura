import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../state/therapy_state.dart';

class TerapijaScreen extends StatelessWidget {
  const TerapijaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dnevna terapija')),
      body: Consumer<TherapyState>(
        builder: (context, state, _) {
          final entries = state.last7Days;
          final df = DateFormat('dd.MM.');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.morningRecordedToday ? null : state.recordMorning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.morningRecordedToday ? Colors.green : Colors.grey,
                        ),
                        child: const Text('☀️ Jutarnja terapija'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.eveningRecordedToday ? null : state.recordEvening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.eveningRecordedToday ? Colors.green : Colors.grey,
                        ),
                        child: const Text('🌙 Večernja terapija'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final color = (entry.morningTime != null && entry.eveningTime != null)
                          ? Colors.green
                          : (entry.morningTime != null || entry.eveningTime != null)
                              ? Colors.yellow
                              : Colors.red;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(height: 4),
                            Text(df.format(entry.date), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Redovnost terapije: ${state.totalTaken}/14 (${state.adherencePercent.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                              final weekday = DateFormat('EEE').format(entries[i].date);
                              return Text(weekday, style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 30),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: state.morningDeviationSpots(),
                          isCurved: true,
                          color: Colors.blue,
                          dotData: FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: state.eveningDeviationSpots(),
                          isCurved: true,
                          color: Colors.green,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
