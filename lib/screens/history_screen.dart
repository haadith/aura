import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istorija'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.events.isEmpty) {
            return const Center(child: Text('Nema unetih događaja.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: appState.events.length,
            itemBuilder: (context, index) {
              final event = appState.events[index];
              return EventCard(
                type: event.type,
                icon: event.icon,
                color: event.color,
                title: event.title,
                dateTime: event.dateTime,
                okolnost: event.okolnost,
                trajanje: event.trajanje,
                geolokacija: event.geolokacija,
                healthData: event.healthData,
                onDelete: () => Provider.of<AppState>(context, listen: false).removeEvent(index),
                onEdit: null, // za sada
              );
            },
          );
        },
      ),
    );
  }
} 