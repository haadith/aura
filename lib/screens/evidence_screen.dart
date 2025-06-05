import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';
import 'package:health/health.dart';
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

  void _refreshHealthData() {
    setState(() {
      _healthDataFuture = _fetchHealthData();
    });
  }

  Future<Map<String, dynamic>> _fetchHealthData() async {
    try {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 5));
      final health = Health();

      // Koristimo samo tipove koje nam trebaju
      final types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.BODY_TEMPERATURE,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.SLEEP_SESSION,
        HealthDataType.WEIGHT,
        HealthDataType.HEIGHT,
      ];
      final permissions = List.filled(types.length, HealthDataAccess.READ);

      print('[DEBUG] Tražim dozvole za: ${types.map((e) => e.name).join(', ')}');
      final requested = await health.requestAuthorization(types, permissions: permissions);
      if (!requested) {
        print('[DEBUG] HealthConnect: Authorization not granted');
        return {};
      }

      print('[DEBUG] Dohvatam podatke od $fiveDaysAgo do $now');
      final results = await health.getHealthDataFromTypes(
        types: types,
        startTime: fiveDaysAgo,
        endTime: now,
      );
      print('[DEBUG] Dobijeno ${results.length} podataka');
      
      final cleanData = health.removeDuplicates(results);
      print('[DEBUG] Nakon uklanjanja duplikata: ${cleanData.length} podataka');
      
      Map<String, dynamic> data = {};

      // Koraci: max vrednost (samo za današnji dan)
      final today = DateTime(now.year, now.month, now.day);
      final koraciList = cleanData
          .where((e) => e.type == HealthDataType.STEPS && 
                        e.value is NumericHealthValue &&
                        e.dateFrom.isAfter(today))
          .toList();
      double koraciMax = 0;
      for (var p in koraciList) {
        final broj = (p.value as NumericHealthValue).numericValue;
        if (broj.toDouble() > koraciMax) koraciMax = broj.toDouble();
      }
      data['koraci'] = koraciMax.toInt();
      print('[DEBUG] Koraci: $koraciMax (${koraciList.length} merenja)');

      // Kalorije: zbir (samo za današnji dan)
      final kalorijeList = cleanData
          .where((e) => e.type == HealthDataType.ACTIVE_ENERGY_BURNED && 
                        e.value is NumericHealthValue &&
                        e.dateFrom.isAfter(today))
          .toList();
      double kalorijeSum = 0;
      for (var p in kalorijeList) {
        kalorijeSum += (p.value as NumericHealthValue).numericValue.toDouble();
      }
      data['kalorije'] = kalorijeSum > 0 ? kalorijeSum.toInt() : '';
      print('[DEBUG] Kalorije: $kalorijeSum (${kalorijeList.length} merenja)');

      // Puls: poslednja vrednost
      final pulsList = cleanData.where((e) => e.type == HealthDataType.HEART_RATE && e.value is NumericHealthValue).toList();
      data['puls'] = pulsList.isNotEmpty ? (pulsList.last.value as NumericHealthValue).numericValue.toInt() : '';
      print('[DEBUG] Puls: ${data['puls']} (${pulsList.length} merenja)');

      // Temperatura: poslednja vrednost
      final tempList = cleanData.where((e) => e.type == HealthDataType.BODY_TEMPERATURE && e.value is NumericHealthValue).toList();
      data['temperatura'] = tempList.isNotEmpty ? (tempList.last.value as NumericHealthValue).numericValue.toStringAsFixed(1) : '';
      print('[DEBUG] Temperatura: ${data['temperatura']} (${tempList.length} merenja)');

      // Saturacija: poslednja vrednost
      final satList = cleanData.where((e) => e.type == HealthDataType.BLOOD_OXYGEN && e.value is NumericHealthValue).toList();
      data['saturacija'] = satList.isNotEmpty ? (satList.last.value as NumericHealthValue).numericValue : '';
      print('[DEBUG] Saturacija: ${data['saturacija']} (${satList.length} merenja)');

      // San: zbir trajanja (samo za današnji dan)
      final sanList = cleanData
          .where((e) => e.type == HealthDataType.SLEEP_SESSION && 
                        e.value is NumericHealthValue &&
                        e.dateFrom.isAfter(today))
          .toList();
      double sanMin = 0.0;
      for (var p in sanList) {
        sanMin += (p.value as NumericHealthValue).numericValue.toDouble();
      }
      final sanH = sanMin ~/ 60;
      final sanM = (sanMin % 60).toInt().toString().padLeft(2, '0');
      data['san'] = sanMin > 0 ? '${sanH}h ${sanM}min' : '';
      print('[DEBUG] San: $sanMin min (${sanList.length} merenja)');

      // Težina: poslednja vrednost iz poslednjih 5 dana
      data['tezina'] = _getLatestWeight(cleanData);
      print('[DEBUG] Težina: ${data['tezina']}');

      // Visina: najnovija vrednost iz Health Connect-a, ili 188.2 ako nema
      final visinaList = cleanData
          .where((e) => e.type == HealthDataType.HEIGHT && e.value is NumericHealthValue)
          .toList();
      double visina = 0.0;
      if (visinaList.isNotEmpty) {
        visinaList.sort((a, b) => a.dateTo.compareTo(b.dateTo));
        // Konvertujemo iz metara u centimetre
        visina = (visinaList.last.value as NumericHealthValue).numericValue.toDouble() * 100;
        print('[DEBUG] Visina iz Health Connect-a: $visina cm (${visinaList.length} merenja)');
      } else {
        visina = 188.2;
        print('[DEBUG] Visina nije pronađena, koristi se podrazumevana: $visina cm');
      }
      data['visina'] = visina.toStringAsFixed(1);

      // BMI: ručno računanje
      if (data['tezina'] != '' && visina > 0) {
        double tezina = double.parse(data['tezina']);
        // Visina je već u centimetrima, delimo sa 100 da dobijemo metre
        double bmi = tezina / ((visina / 100) * (visina / 100));
        data['bmi'] = bmi.toStringAsFixed(1);
        print('[DEBUG] BMI: $bmi (težina: $tezina kg, visina: $visina cm)');
      } else {
        data['bmi'] = '';
        print('[DEBUG] BMI: nije moguće izračunati (težina: ${data['tezina']} kg, visina: $visina cm)');
      }

      print('[DEBUG] HealthData (univerzalno): $data');
      return data;
    } catch (e, stackTrace) {
      print('[ERROR] Greška pri dohvatanju health podataka: $e');
      print('[ERROR] Stack trace: $stackTrace');
      return {};
    }
  }

  String _getLatestWeight(List<HealthDataPoint> data) {
    final tezinaList = data
        .where((e) => e.type == HealthDataType.WEIGHT && e.value is NumericHealthValue)
        .toList();
    
    if (tezinaList.isEmpty) {
      return '';
    }

    // Sortiraj po datumu, od najnovijeg ka najstarijem
    tezinaList.sort((a, b) => b.dateTo.compareTo(a.dateTo));
    
    // Uzmi najnoviju vrednost
    final tezina = (tezinaList.first.value as NumericHealthValue).numericValue.toDouble();
    return tezina > 0 ? tezina.toStringAsFixed(1) : '';
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
            const SizedBox(height: 8),
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
                _refreshHealthData(); // Refresh after adding event
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
                    geolokacija: 'dummy',
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
                    geolokacija: 'dummy',
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
                    geolokacija: 'dummy',
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
