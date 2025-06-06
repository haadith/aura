import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/therapy_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'settings_screen.dart';



class TerapijaScreen extends StatelessWidget {
  const TerapijaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terapija"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer<TherapyState>(
        builder: (context, therapyState, child) {
          final morning = therapyState.getTodayEntry(TherapyType.morning);
          final evening = therapyState.getTodayEntry(TherapyType.evening);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Dnevna terapija',
                      style: TextStyle(
                        color: Color(0xFF23408E),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TherapyButton(
                          label: 'Jutarnja terapija',
                          icon: Icons.wb_sunny,
                          isActive: morning != null,
                          onPressed: () {
                            if (morning == null) {
                              therapyState.addEntry(TherapyEntry(
                                dateTime: DateTime.now(),
                                type: TherapyType.morning,
                              ));
                            } else {
                              therapyState.deleteTodayEntry(TherapyType.morning);
                            }
                          },
                          time: morning != null ? _formatTime(morning.dateTime) : null,
                        ),
                        const SizedBox(width: 12),
                        _TherapyButton(
                          label: 'Večernja terapija',
                          icon: Icons.nightlight_round,
                          isActive: evening != null,
                          onPressed: () {
                            if (evening == null) {
                              therapyState.addEntry(TherapyEntry(
                                dateTime: DateTime.now(),
                                type: TherapyType.evening,
                              ));
                            } else {
                              therapyState.deleteTodayEntry(TherapyType.evening);
                            }
                          },
                          time: evening != null ? _formatTime(evening.dateTime) : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _TherapyHistory(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    return dt.hour.toString().padLeft(2, '0') + ':' + dt.minute.toString().padLeft(2, '0');
  }
}

class _TherapyButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final String? time;

  const _TherapyButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.green;
    return Expanded(
      child: Column(
        children: [
          Material(
            elevation: isActive ? 3 : 1,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: isActive ? Colors.white : Colors.black38, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (time != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(time!, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
        ],
      ),
    );
  }
}

class _TherapyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TherapyEntry>>(
      future: Provider.of<TherapyState>(context, listen: false).getLastNDaysEntries(7),
      builder: (context, snapshot) {
        final days = List.generate(7, (i) {
          final date = DateTime.now().subtract(Duration(days: 6 - i));
          return date;
        });
        final entries = snapshot.data ?? [];
        Map<String, TherapyEntry?> morningMap = {for (var d in days) d.toIso8601String().substring(0, 10): null};
        Map<String, TherapyEntry?> eveningMap = {for (var d in days) d.toIso8601String().substring(0, 10): null};
        for (var e in entries) {
          final key = e.dateTime.toIso8601String().substring(0, 10);
          if (e.type == TherapyType.morning) morningMap[key] = e;
          if (e.type == TherapyType.evening) eveningMap[key] = e;
        }
        // Redovnost
        int total = 14;
        int taken = morningMap.values.where((e) => e != null).length + eveningMap.values.where((e) => e != null).length;
        double percent = (taken / total * 100).roundToDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((d) {
                final key = d.toIso8601String().substring(0, 10);
                final morning = morningMap[key];
                final evening = eveningMap[key];
                Color color;
                if ((morning != null && evening != null)) {
                  color = Colors.green;
                } else if (morning != null || evening != null) {
                  color = Colors.orange;
                } else {
                  color = Colors.red;
                }
                return Column(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: color, child: Text('${d.day}', style: const TextStyle(color: Colors.white, fontSize: 13))),
                    Text('${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text('Redovnost terapije: $taken/$total (${percent.toInt()}%)', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text('Odstupanje u vremenu uzimanja terapije:', style: const TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, horizontalInterval: 60, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value == 120) return const Text('+2h', style: TextStyle(fontSize: 12));
                          if (value == 60) return const Text('+1h', style: TextStyle(fontSize: 12));
                          if (value == 0) return const Text('0', style: TextStyle(fontSize: 12));
                          if (value == -60) return const Text('-1h', style: TextStyle(fontSize: 12));
                          if (value == -120) return const Text('-2h', style: TextStyle(fontSize: 12));
                          return const SizedBox();
                        },
                        interval: 60,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx > 6) return const SizedBox();
                          final d = days[idx];
                          const daysShort = ['Pon', 'Uto', 'Sre', 'Čet', 'Pet', 'Sub', 'Ned'];
                          return Text(daysShort[d.weekday - 1], style: const TextStyle(fontSize: 12));
                        },
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  minY: -120,
                  maxY: 120,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (i) {
                        final d = days[i];
                        final entry = morningMap[d.toIso8601String().substring(0, 10)];
                        double diff = 0;
                        if (entry != null) {
                          diff = entry.dateTime.difference(DateTime(d.year, d.month, d.day, 8, 0)).inMinutes.toDouble();
                          if (diff > 120) diff = 120;
                          if (diff < -120) diff = -120;
                        }
                        return FlSpot(i.toDouble(), diff);
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: List.generate(7, (i) {
                        final d = days[i];
                        final entry = eveningMap[d.toIso8601String().substring(0, 10)];
                        double diff = 0;
                        if (entry != null) {
                          diff = entry.dateTime.difference(DateTime(d.year, d.month, d.day, 20, 0)).inMinutes.toDouble();
                          if (diff > 120) diff = 120;
                          if (diff < -120) diff = -120;
                        }
                        return FlSpot(i.toDouble(), diff);
                      }),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(children: [Icon(Icons.wb_sunny, color: Colors.blue, size: 16), SizedBox(width: 4), Text('Jutarnja terapija', style: TextStyle(fontSize: 12))]),
                Row(children: [Icon(Icons.nightlight_round, color: Colors.green, size: 16), SizedBox(width: 4), Text('Večernja terapija', style: TextStyle(fontSize: 12))]),
              ],
            ),
          ],
        );
      },
    );
  }
} 