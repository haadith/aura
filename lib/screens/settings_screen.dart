import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podešavanja'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test mod',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return SwitchListTile(
                  title: const Text('Test'),
                  subtitle: const Text('Prikaži stranicu za testiranje'),
                  value: appState.showTestTab,
                  onChanged: (value) {
                    appState.setShowTestTab(value);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Lični podaci',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<AppState>(
              builder: (context, appState, child) {
                return TextFormField(
                  initialValue: appState.height?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Visina (cm)',
                    border: OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final height = double.tryParse(value);
                      if (height != null) {
                        appState.setHeight(height);
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
