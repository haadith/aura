import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum TherapyType { morning, evening }

class TherapyEntry {
  final int? id;
  final DateTime dateTime;
  final TherapyType type;

  TherapyEntry({this.id, required this.dateTime, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'type': type.index,
    };
  }

  factory TherapyEntry.fromMap(Map<String, dynamic> map) {
    return TherapyEntry(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      type: TherapyType.values[map['type']],
    );
  }
}

class TherapyState extends ChangeNotifier {
  Database? _database;
  List<TherapyEntry> _entries = [];

  List<TherapyEntry> get entries => _entries;

  Future<void> initDatabase() async {
    if (_database != null) return;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'therapy_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE therapy_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, dateTime TEXT, type INTEGER)',
        );
      },
      version: 1,
    );
    await loadEntries();
  }

  Future<void> loadEntries() async {
    if (_database == null) await initDatabase();
    final List<Map<String, dynamic>> maps = await _database!.query('therapy_entries', orderBy: 'dateTime DESC');
    _entries = maps.map((map) => TherapyEntry.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addEntry(TherapyEntry entry) async {
    if (_database == null) await initDatabase();
    final id = await _database!.insert(
      'therapy_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _entries.insert(0, TherapyEntry(id: id, dateTime: entry.dateTime, type: entry.type));
    notifyListeners();
  }

  TherapyEntry? getTodayEntry(TherapyType type) {
    final now = DateTime.now();
    try {
      return _entries.firstWhere(
        (e) => e.type == type && e.dateTime.year == now.year && e.dateTime.month == now.month && e.dateTime.day == now.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<TherapyEntry>> getLastNDaysEntries(int days) async {
    if (_database == null) await initDatabase();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final List<Map<String, dynamic>> maps = await _database!.query(
      'therapy_entries',
      where: 'dateTime >= ?',
      whereArgs: [DateTime(start.year, start.month, start.day).toIso8601String()],
      orderBy: 'dateTime ASC',
    );
    return maps.map((map) => TherapyEntry.fromMap(map)).toList();
  }

  Future<void> deleteTodayEntry(TherapyType type) async {
    final now = DateTime.now();
    TherapyEntry? entry;
    try {
      entry = _entries.firstWhere(
        (e) => e.type == type && e.dateTime.year == now.year && e.dateTime.month == now.month && e.dateTime.day == now.day,
      );
    } catch (e) {
      entry = null;
    }
    if (entry != null && _database != null) {
      await _database!.delete(
        'therapy_entries',
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      _entries.remove(entry);
      notifyListeners();
    }
  }
} 