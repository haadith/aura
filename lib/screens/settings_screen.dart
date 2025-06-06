import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
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
            const SizedBox(height: 24),
            _LocationStatusWidget(),
          ],
        ),
      ),
    );
  }
}

class _LocationStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    String statusText;
    Color statusColor;
    if (appState.locationError != null) {
      statusText = 'Greška: ${appState.locationError}';
      statusColor = Colors.red;
    } else if (appState.currentLocation != null && appState.locationAccuracy != null) {
      statusText = 'Lokacija: ${appState.currentLocation} (preciznost: ${appState.locationAccuracy?.toStringAsFixed(1)} m)';
      statusColor = Colors.green[700]!;
    } else {
      statusText = 'Lokacija: učitavanje...';
      statusColor = Colors.grey;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusText,
          style: TextStyle(color: statusColor),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => appState.retryLocation(),
          icon: Icon(Icons.refresh),
          label: Text('Pokušaj ponovo'),
        ),
        if (appState.locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'DEBUG: ${appState.locationError}',
              style: TextStyle(fontSize: 12, color: Colors.red[300]),
            ),
          ),
      ],
    );
  }
}
