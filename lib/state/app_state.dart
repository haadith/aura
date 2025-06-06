import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/weather_service.dart';

class Event {
  final String type;
  final String title;
  final IconData icon;
  final Color color;
  final DateTime dateTime;
  final String okolnost;
  final int trajanje;
  final String? geolokacija;
  final Map<String, dynamic>? healthData;

  Event({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
    required this.dateTime,
    required this.okolnost,
    required this.trajanje,
    this.geolokacija,
    this.healthData,
  });
}

class AppState extends ChangeNotifier {
  bool _showTestTab = false;
  double? _height;
  WeatherData? _weather;

  bool get showTestTab => _showTestTab;
  double? get height => _height;
  WeatherData? get weather => _weather;

  AppState() {
    _loadHeight();
    fetchWeather();
  }

  Future<void> _loadHeight() async {
    final prefs = await SharedPreferences.getInstance();
    _height = prefs.getDouble('height');
    notifyListeners();
  }

  Future<void> setHeight(double value) async {
    _height = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', value);
    notifyListeners();
  }

  void setShowTestTab(bool value) {
    _showTestTab = value;
    notifyListeners();
  }

  Future<void> fetchWeather() async {
    final service = WeatherService();
    final data = await service.fetchCurrentWeather();
    _weather = data;
    notifyListeners();
  }

  // Lista događaja
  final List<Event> _events = [];
  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events.insert(0, event); // najnoviji na vrhu
    notifyListeners();
  }

  void removeEvent(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      notifyListeners();
    }
  }

  void editEvent(int index, Event newEvent) {
    if (index >= 0 && index < _events.length) {
      _events[index] = newEvent;
      notifyListeners();
    }
  }
}
