import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:health/health.dart';

Future<String> requestAllPermissions() async {
  final deviceInfo = DeviceInfoPlugin();
  int sdkInt = 0;

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    sdkInt = androidInfo.version.sdkInt;
  }

  final permissions = <Permission>[
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.locationAlways,
    Permission.activityRecognition,
    Permission.notification,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.sensors,
    Permission.calendarFullAccess,
    Permission.contacts,
    Permission.sms,
    Permission.phone,
  ];

  if (sdkInt >= 33) {
    permissions.addAll([
      Permission.photos,
      Permission.audio,
      Permission.videos,
    ]);
  }

  final results = await permissions.request();
  return results.entries
      .map((e) => "${e.key.toString().replaceAll("Permission.", "")}: ${e.value}")
      .join('\n');
}

Future<void> requestHealthConnectPermissions() async {
  final health = Health();

  final types = [
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.HEART_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.LEAN_BODY_MASS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
  ];

  final hasPermissions = await health.hasPermissions(
    types,
    permissions: types.map((e) => HealthDataAccess.READ).toList(),
  );
  print('🔎 Health Connect - already granted: $hasPermissions');

  if (!(hasPermissions ?? false)) {
    final granted = await health.requestAuthorization(
      types,
      permissions: types.map((e) => HealthDataAccess.READ).toList(),
    );
    print('🔐 Health Connect - permission granted: $granted');
  }
}  

Future<void> requestAllAppPermissions() async {
  final systemResults = await requestAllPermissions();
  print("📋 System permissions result:\n$systemResults");

  await requestHealthConnectPermissions();
}