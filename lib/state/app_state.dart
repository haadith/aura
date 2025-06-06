import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/weather_service.dart';
import 'package:geolocator/geolocator.dart';

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
  String? _currentLocation;
  double? _locationAccuracy;
  String? _locationError;

  bool get showTestTab => _showTestTab;
  double? get height => _height;
  WeatherData? get weather => _weather;
  String? get currentLocation => _currentLocation;
  double? get locationAccuracy => _locationAccuracy;
  String? get locationError => _locationError;

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

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError = 'Servis za lokaciju nije omogućen.';
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationError = 'Dozvola za lokaciju nije odobrena.';
        notifyListeners();
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _locationError = 'Dozvola za lokaciju je trajno odbijena.';
      notifyListeners();
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      _currentLocation = '${pos.latitude},${pos.longitude}';
      _locationAccuracy = pos.accuracy;
      _locationError = null;
      notifyListeners();
    } catch (e) {
      _locationError = 'Greška pri dohvatanju lokacije.';
      notifyListeners();
    }
  }

  Future<void> retryLocation() async {
    await _initLocation();
  }
}
