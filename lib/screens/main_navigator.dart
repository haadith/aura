import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'test_screen.dart';
import 'history_screen.dart';
import '../state/app_state.dart';
import 'evidence_screen.dart';
import 'terapija_screen.dart';


class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final showTest = context.watch<AppState>().showTestTab;

    // If the test tab is disabled while it was active, reset to the first tab
    if (!showTest && _currentIndex >= 3) {
      _currentIndex = 0;
    }

    final screens = [
      const EvidenceScreen(),
      const TerapijaScreen(),
      const HistoryScreen(),
      if (showTest) const TestScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
      const BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Terapija'),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Istorija'),
      if (showTest)
        const BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Test'),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        onTap: (index) => setState(() => _currentIndex = index),
        items: items,
      ),
    );
  }
}
