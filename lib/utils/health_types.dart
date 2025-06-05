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