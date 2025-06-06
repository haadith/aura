import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import "package:fl_chart/fl_chart.dart";

class TherapyEntry {
  final DateTime date;
  final DateTime? morningTime;
  final DateTime? eveningTime;

  TherapyEntry({required this.date, this.morningTime, this.eveningTime});
}

class TherapyState extends ChangeNotifier {
  Database? _db;
  final List<TherapyEntry> _last7Days = [];

  List<TherapyEntry> get last7Days => List.unmodifiable(_last7Days);

  TherapyState() {
    _init();
  }

  Future<void> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aura.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE therapy(
            date TEXT PRIMARY KEY,
            morning_time TEXT,
            evening_time TEXT
          )
        ''');
      },
    );
    await _loadLast7Days();
  }

  Future<void> _loadLast7Days() async {
    if (_db == null) return;
    _last7Days.clear();
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = DateUtils.dateOnly(now.subtract(Duration(days: i)));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final res = await _db!.query(
        'therapy',
        where: 'date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );
      DateTime? morning;
      DateTime? evening;
      if (res.isNotEmpty) {
        final row = res.first;
        if (row['morning_time'] != null) {
          morning = DateTime.tryParse(row['morning_time'] as String);
        }
        if (row['evening_time'] != null) {
          evening = DateTime.tryParse(row['evening_time'] as String);
        }
      }
      _last7Days.add(TherapyEntry(date: date, morningTime: morning, eveningTime: evening));
    }
    notifyListeners();
  }

  bool get morningRecordedToday => _last7Days.isNotEmpty && _last7Days.last.morningTime != null;
  bool get eveningRecordedToday => _last7Days.isNotEmpty && _last7Days.last.eveningTime != null;

  int get totalTaken {
    int sum = 0;
    for (var e in _last7Days) {
      if (e.morningTime != null) sum++;
      if (e.eveningTime != null) sum++;
    }
    return sum;
  }

  double get adherencePercent => (totalTaken / 14) * 100;

  Future<void> recordMorning() async {
    await _record(timeOfDay: 'morning_time');
  }

  Future<void> recordEvening() async {
    await _record(timeOfDay: 'evening_time');
  }

  Future<void> _record({required String timeOfDay}) async {
    if (_db == null) return;
    final now = DateTime.now();
    final date = DateUtils.dateOnly(now);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final res = await _db!.query(
      'therapy',
      where: 'date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );
    if (res.isEmpty) {
      await _db!.insert('therapy', {
        'date': dateStr,
        if (timeOfDay == 'morning_time') 'morning_time': now.toIso8601String(),
        if (timeOfDay == 'evening_time') 'evening_time': now.toIso8601String(),
      });
    } else if (res.first[timeOfDay] == null) {
      await _db!.update(
        'therapy',
        {timeOfDay: now.toIso8601String()},
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    } else {
      return;
    }
    await _loadLast7Days();
  }

  List<FlSpot> morningDeviationSpots() {
    final List<FlSpot> spots = [];
    for (int i = 0; i < _last7Days.length; i++) {
      final entry = _last7Days[i];
      if (entry.morningTime != null) {
        final ideal = DateTime(entry.date.year, entry.date.month, entry.date.day, 8);
        final diff = entry.morningTime!.difference(ideal).inMinutes.abs().toDouble();
        spots.add(FlSpot(i.toDouble(), diff));
      }
    }
    return spots;
  }

  List<FlSpot> eveningDeviationSpots() {
    final List<FlSpot> spots = [];
    for (int i = 0; i < _last7Days.length; i++) {
      final entry = _last7Days[i];
      if (entry.eveningTime != null) {
        final ideal = DateTime(entry.date.year, entry.date.month, entry.date.day, 20);
        final diff = entry.eveningTime!.difference(ideal).inMinutes.abs().toDouble();
        spots.add(FlSpot(i.toDouble(), diff));
      }
    }
    return spots;
  }
}
