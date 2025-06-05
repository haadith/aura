import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../utils/health_types.dart'; // koristi kSupportedHealthTypes

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final Health _health = Health();
  List<HealthDataPoint> _healthDataList = [];
  bool _isLoading = false;

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final types = kSupportedHealthTypes.keys.toList();
    final permissions = List.filled(types.length, HealthDataAccess.READ);

    final requested = await _health.requestAuthorization(types, permissions: permissions);

    if (!requested) {
      setState(() => _isLoading = false);
      return;
    }

    final now = DateTime.now();
    final past = now.subtract(const Duration(days: 7));

    final results = await _health.getHealthDataFromTypes(
      types: types,
      startTime: past,
      endTime: now,
    );

    final cleanData = _health.removeDuplicates(results);

    setState(() {
      _healthDataList = cleanData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <HealthDataType, List<HealthDataPoint>>{};
    for (var data in _healthDataList) {
      grouped.putIfAbsent(data.type, () => []).add(data);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Health Podaci')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchData,
        icon: const Icon(Icons.refresh),
        label: const Text('Osveži'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : grouped.isEmpty
              ? const Center(child: Text('Nema dostupnih podataka.'))
              : ListView.builder(
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final type = grouped.keys.elementAt(index);
                    final info = kSupportedHealthTypes[type];
                    final list = grouped[type]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            if (info?['icon'] != null)
                              Icon(info!['icon'] as IconData, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(info?['label'] ?? type.name),
                          ],
                        ),
                        children: list.map((entry) {
                          final unit = info?['unit'] ?? entry.unit.name ?? '';
                          return ListTile(
                            title: Text('${entry.value} $unit'),
                            subtitle: Text('${entry.dateFrom}'),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
