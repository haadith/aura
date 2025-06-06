import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/weather_widget.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/health_types.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  String _selectedOkolnost = 'Prekid pažnje';
  int _selectedTrajanje = 10;
  late Future<Map<String, dynamic>> _healthDataFuture;
  final HealthService _healthService = HealthService();

  final List<String> _okolnosti = [
    'Prekid pažnje',
    'Vožnja',
    'San',
    'Ostalo',
  ];

  final List<int> _trajanja = [5, 10, 20, 25, 30];

  @override
  void initState() {
    super.initState();
    _refreshHealthData();
  }

  Future<void> _refreshHealthData() async {
    setState(() {
      _healthDataFuture = _healthService.fetchSummary();
    });
    await _healthDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evidencija napada"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHealthData,
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WeatherWidget(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Jačina napada',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Blag',
              icon: Icons.waves,
              backgroundColor: Colors.lightBlue.shade400,
              height: 84,
              fontSize: 20,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await _refreshHealthData();
                final healthData = await _healthDataFuture;
                debugPrint('[DEBUG] HealthData: $healthData');
                if (healthData.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nema dostupnih Health Connect podataka za poslednjih 10 minuta.')),
                    );
                  }
                }
                Provider.of<AppState>(context, listen: false).addEvent(
                  Event(
                    type: 'Blag',
                    title: 'Blag',
                    icon: Icons.waves,
                    color: Colors.lightBlue.shade400,
                    dateTime: DateTime.now(),
                    okolnost: _selectedOkolnost,
                    trajanje: _selectedTrajanje,
                    geolokacija: 'dummy',
                    healthData: healthData,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Umeren',
              icon: Icons.warning_amber_rounded,
              backgroundColor: Colors.orange.shade600,
              height: 84,
              fontSize: 20,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final healthData = await _healthDataFuture;
                print('[DEBUG] HealthData: $healthData');
                if (healthData.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nema dostupnih Health Connect podataka za poslednjih 10 minuta.')),
                    );
                  }
                }
                Provider.of<AppState>(context, listen: false).addEvent(
                  Event(
                    type: 'Umeren',
                    title: 'Umeren',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange.shade600,
                    dateTime: DateTime.now(),
                    okolnost: _selectedOkolnost,
                    trajanje: _selectedTrajanje,
                    geolokacija:
                        Provider.of<AppState>(context, listen: false)
                            .currentLocation,
                    healthData: healthData,
                  ),
                );
                _refreshHealthData(); // Refresh after adding event
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Težak',
              icon: Icons.error_outline_rounded,
              backgroundColor: Colors.red.shade400,
              height: 84,
              fontSize: 20,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final healthData = await _healthDataFuture;
                print('[DEBUG] HealthData: $healthData');
                if (healthData.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nema dostupnih Health Connect podataka za poslednjih 10 minuta.')),
                    );
                  }
                }
                Provider.of<AppState>(context, listen: false).addEvent(
                  Event(
                    type: 'Težak',
                    title: 'Težak',
                    icon: Icons.error_outline_rounded,
                    color: Colors.red.shade400,
                    dateTime: DateTime.now(),
                    okolnost: _selectedOkolnost,
                    trajanje: _selectedTrajanje,
                    geolokacija:
                        Provider.of<AppState>(context, listen: false)
                            .currentLocation,
                    healthData: healthData,
                  ),
                );
                _refreshHealthData(); // Refresh after adding event
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Benzodiazepin (Frisium)',
              icon: Icons.link_rounded,
              backgroundColor: const Color(0xFFB2F2BB),
              textColor: Colors.black87,
              height: 56,
              onPressed: () async {
                HapticFeedback.selectionClick();
                final healthData = await _healthDataFuture;
                print('[DEBUG] HealthData: $healthData');
                if (healthData.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nema dostupnih Health Connect podataka za poslednjih 10 minuta.')),
                    );
                  }
                }
                Provider.of<AppState>(context, listen: false).addEvent(
                  Event(
                    type: 'Frisium',
                    title: 'Frisium',
                    icon: Icons.add_box_outlined,
                    color: Colors.green,
                    dateTime: DateTime.now(),
                    okolnost: _selectedOkolnost,
                    trajanje: _selectedTrajanje,
                    geolokacija:
                        Provider.of<AppState>(context, listen: false)
                            .currentLocation,
                    healthData: healthData,
                  ),
                );
                _refreshHealthData(); // Refresh after adding event
              },
            ),
            const SizedBox(height: 32),
            // Okolnost dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Okolnost',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _selectedOkolnost,
              items: _okolnosti
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOkolnost = value);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            // Trajanje dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Trajanje (s)',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<int>(
              value: _selectedTrajanje,
              items: _trajanja
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTrajanje = value);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
