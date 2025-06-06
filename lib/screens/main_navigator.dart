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
  State<MainNavigator> createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showTest = context.watch<AppState>().showTestTab;

    // Ako je test tab isključen i korisnik je na test tabu, resetuj na početnu
    if (!showTest && _currentIndex >= 3) {
      _currentIndex = 0;
    }

    final screens = [
      const EvidenceScreen(),
      const HistoryScreen(),
      const TerapijaScreen(),
      if (showTest) const TestScreen(),
    ];

    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Istorija'),
      const BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Terapija'),
      if (showTest)
        const BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Test'),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        onTap: (index) => setTab(index),
        items: items,
      ),
    );
  }
}
