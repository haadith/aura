import 'package:flutter/material.dart';
import 'package:health/health.dart';

/// Centralizovana mapa podržanih HealthDataType podataka.
final Map<HealthDataType, Map<String, dynamic>> kSupportedHealthTypes = {
  HealthDataType.STEPS: {
    'label': 'Koraci',
    'unit': 'koraka',
    'permission': 'android.permission.health.READ_STEPS',
    'icon': Icons.directions_walk,
  },
  HealthDataType.WEIGHT: {
    'label': 'Težina',
    'unit': 'kg',
    'permission': 'android.permission.health.READ_WEIGHT',
    'icon': Icons.monitor_weight,
  },
  HealthDataType.HEIGHT: {
    'label': 'Visina',
    'unit': 'cm',
    'permission': 'android.permission.health.READ_HEIGHT',
    'icon': Icons.height,
  },
  HealthDataType.BODY_MASS_INDEX: {
    'label': 'BMI',
    'unit': '',
    'permission': 'android.permission.health.READ_BODY_MASS_INDEX',
    'icon': Icons.fitness_center,
  },
  HealthDataType.BODY_FAT_PERCENTAGE: {
    'label': 'Procenat masti',
    'unit': '%',
    'permission': 'android.permission.health.READ_BODY_FAT',
    'icon': Icons.pie_chart,
  },
  HealthDataType.LEAN_BODY_MASS: {
    'label': 'Mišićna masa',
    'unit': 'kg',
    'permission': 'android.permission.health.READ_LEAN_BODY_MASS',
    'icon': Icons.accessibility_new,
  },
  HealthDataType.BODY_TEMPERATURE: {
    'label': 'Telesna temperatura',
    'unit': '°C',
    'permission': 'android.permission.health.READ_BODY_TEMPERATURE',
    'icon': Icons.thermostat,
  },
  HealthDataType.ACTIVE_ENERGY_BURNED: {
    'label': 'Potrošene kalorije',
    'unit': 'kcal',
    'permission': 'android.permission.health.READ_ACTIVE_ENERGY_BURNED',
    'icon': Icons.local_fire_department,
  },
  HealthDataType.HEART_RATE: {
    'label': 'Puls',
    'unit': 'bpm',
    'permission': 'android.permission.health.READ_HEART_RATE',
    'icon': Icons.favorite,
  },
  HealthDataType.BLOOD_OXYGEN: {
    'label': 'Zasićenost kiseonikom',
    'unit': '%',
    'permission': 'android.permission.health.READ_BLOOD_OXYGEN',
    'icon': Icons.air,
  },

  // Sleep data
  HealthDataType.SLEEP_ASLEEP: {
    'label': 'Spavanje (asleep)',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.bedtime,
  },
  HealthDataType.SLEEP_AWAKE: {
    'label': 'Budno stanje tokom spavanja',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.bedtime_off,
  },
  HealthDataType.SLEEP_AWAKE_IN_BED: {
    'label': 'Budno u krevetu',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.king_bed_outlined,
  },
  HealthDataType.SLEEP_DEEP: {
    'label': 'Dubok san',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.night_shelter,
  },
  HealthDataType.SLEEP_LIGHT: {
    'label': 'Lagan san',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.hotel,
  },
  HealthDataType.SLEEP_OUT_OF_BED: {
    'label': 'Vreme van kreveta',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.door_back_door,
  },
  HealthDataType.SLEEP_REM: {
    'label': 'REM faza sna',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.visibility,
  },
  HealthDataType.SLEEP_SESSION: {
    'label': 'Sesija spavanja',
    'unit': '',
    'permission': 'android.permission.health.READ_SLEEP',
    'icon': Icons.bed,
  },
};

List<HealthDataType> get allSupportedTypes => kSupportedHealthTypes.keys.toList();

String getLabelForType(HealthDataType type) =>
    kSupportedHealthTypes[type]?['label'] ?? type.name;

String getUnitForType(HealthDataType type) =>
    kSupportedHealthTypes[type]?['unit'] ?? '';

IconData? getIconForType(HealthDataType type) =>
    kSupportedHealthTypes[type]?['icon'];

/// Service koji obezbeđuje dohvat i obradu Health Connect podataka.
class HealthService {
  final Health _health = Health();

  Future<bool> _requestAuth(List<HealthDataType> types) async {
    final permissions = List.filled(types.length, HealthDataAccess.READ);
    return _health.requestAuthorization(types, permissions: permissions);
  }

  Future<List<HealthDataPoint>> _fetchRaw(
      List<HealthDataType> types, DateTime start, DateTime end) async {
    if (!await _requestAuth(types)) return [];
    final results = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );
    return _health.removeDuplicates(results);
  }

  /// Vraća mapu agregiranih vrednosti sličnu onoj koja se koristi u
  /// `EvidenceScreen` za beleženje događaja.
  Future<Map<String, dynamic>> fetchSummary() async {
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

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

    final data = await _fetchRaw(types, fiveDaysAgo, now);
    if (data.isEmpty) return {};

    final Map<String, dynamic> result = {};
    final today = DateTime(now.year, now.month, now.day);
    final todayStart = DateTime(today.year, today.month, today.day, 0, 0, 0);

    debugPrint('[DEBUG] Tražim korake za: $todayStart');

    // Koraci: SAMO 00:00:00
    final stepsList = data
        .where((e) => e.type == HealthDataType.STEPS &&
            e.value is NumericHealthValue &&
            e.dateFrom == todayStart)
        .toList();
    
    debugPrint('[DEBUG] Pronađeni koraci:');
    for (var step in stepsList) {
      debugPrint('[DEBUG] Koraci: ${(step.value as NumericHealthValue).numericValue} @ ${step.dateFrom}');
    }
    
    result['koraci'] = stepsList.isNotEmpty 
        ? (stepsList.first.value as NumericHealthValue).numericValue.toInt()
        : 0;
    
    debugPrint('[DEBUG] Korišćeni koraci: ${result['koraci']} @ ${stepsList.isNotEmpty ? stepsList.first.dateFrom : "nema podataka"}');

    // Kalorije: poslednji rezultat
    final calorieList = data
        .where((e) => e.type == HealthDataType.ACTIVE_ENERGY_BURNED &&
            e.value is NumericHealthValue &&
            e.dateFrom.isAfter(today))
        .toList();
    double calorieSum = 0;
    for (var p in calorieList) {
      calorieSum += (p.value as NumericHealthValue).numericValue.toDouble();
    }
    result['kalorije'] = calorieSum > 0 ? calorieSum.toInt() : '';
    debugPrint('[DEBUG] Kalorije: $calorieSum (${calorieList.length} merenja)');

    // Puls: poslednji rezultat
    final pulseList = data
        .where((e) => e.type == HealthDataType.HEART_RATE &&
            e.value is NumericHealthValue)
        .toList();
    result['puls'] = pulseList.isNotEmpty
        ? (pulseList.last.value as NumericHealthValue).numericValue.toInt()
        : '';
    debugPrint('[DEBUG] Puls: ${result['puls']} (${pulseList.length} merenja)');

    // Temperatura: poslednji rezultat
    final tempList = data
        .where((e) => e.type == HealthDataType.BODY_TEMPERATURE &&
            e.value is NumericHealthValue)
        .toList();
    result['temperatura'] = tempList.isNotEmpty
        ? (tempList.last.value as NumericHealthValue).numericValue.toStringAsFixed(1)
        : '';
    debugPrint('[DEBUG] Temperatura: ${result['temperatura']} (${tempList.length} merenja)');

    // Saturacija: poslednji rezultat
    final satList = data
        .where((e) => e.type == HealthDataType.BLOOD_OXYGEN &&
            e.value is NumericHealthValue)
        .toList();
    result['saturacija'] = satList.isNotEmpty
        ? (satList.last.value as NumericHealthValue).numericValue
        : '';
    debugPrint('[DEBUG] Saturacija: ${result['saturacija']} (${satList.length} merenja)');

    // San: poslednji rezultat
    final sanList = data
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
    result['san'] = sanMin > 0 ? '${sanH}h ${sanM}min' : '';
    debugPrint('[DEBUG] San: $sanMin min (${sanList.length} merenja)');

    // Težina: poslednji rezultat
    final tezinaList = data
        .where((e) => e.type == HealthDataType.WEIGHT &&
            e.value is NumericHealthValue)
        .toList();
    result['tezina'] = tezinaList.isNotEmpty
        ? (tezinaList.last.value as NumericHealthValue).numericValue.toStringAsFixed(1)
        : '';
    debugPrint('[DEBUG] Težina: ${result['tezina']} (${tezinaList.length} merenja)');

    // Visina: poslednji rezultat
    final visinaList = data
        .where((e) => e.type == HealthDataType.HEIGHT &&
            e.value is NumericHealthValue)
        .toList();
    double visina = 0.0;
    if (visinaList.isNotEmpty) {
      visinaList.sort((a, b) => a.dateTo.compareTo(b.dateTo));
      visina = (visinaList.last.value as NumericHealthValue).numericValue.toDouble() * 100;
      debugPrint('[DEBUG] Visina iz Health Connect-a: $visina cm (${visinaList.length} merenja)');
    } else {
      visina = 188.2;
      debugPrint('[DEBUG] Visina nije pronađena, koristi se podrazumevana: $visina cm');
    }
    result['visina'] = visina.toStringAsFixed(1);

    if (result['tezina'] != '' && visina > 0) {
      final weight = double.parse(result['tezina']);
      final bmi = weight / ((visina / 100) * (visina / 100));
      result['bmi'] = bmi.toStringAsFixed(1);
    } else {
      result['bmi'] = '';
    }

    return result;
  }

  String _latestWeight(List<HealthDataPoint> data) {
    final list = data
        .where((e) => e.type == HealthDataType.WEIGHT &&
            e.value is NumericHealthValue)
        .toList();
    if (list.isEmpty) return '';
    list.sort((a, b) => b.dateTo.compareTo(a.dateTo));
    final weight =
        (list.first.value as NumericHealthValue).numericValue.toDouble();
    return weight > 0 ? weight.toStringAsFixed(1) : '';
  }
}

