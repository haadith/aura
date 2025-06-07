import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/custom_button.dart';

class DailyTherapyScreen extends StatefulWidget {
  const DailyTherapyScreen({super.key});

  @override
  State<DailyTherapyScreen> createState() => _DailyTherapyScreenState();
}

class _DailyTherapyScreenState extends State<DailyTherapyScreen> {
  Future<DateTime?> _selectTime(BuildContext context) async {
    TimeOfDay initial = TimeOfDay.now();
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (context) {
        TimeOfDay temp = initial;
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime:
                      DateTime(0, 0, 0, initial.hour, initial.minute),
                  onDateTimeChanged: (dt) {
                    temp = TimeOfDay(hour: dt.hour, minute: dt.minute);
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(temp),
                child: const Text('Potvrdi'),
              )
            ],
          ),
        );
      },
    );

    if (picked == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
  }

  void _recordTherapy(String label, DateTime time) {
    final msg = '$label u ${_formatTime(time)}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dnevna terapija')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomButton(
              label: 'Jutarnja terapija',
              icon: Icons.light_mode_outlined,
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: () {
                _recordTherapy('Jutarnja terapija', DateTime.now());
              },
              onLongPress: () async {
                final time = await _selectTime(context);
                if (time != null) {
                  _recordTherapy('Jutarnja terapija', time);
                }
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Večernja terapija',
              icon: Icons.dark_mode_outlined,
              backgroundColor: Colors.indigo,
              onPressed: () {
                _recordTherapy('Večernja terapija', DateTime.now());
              },
              onLongPress: () async {
                final time = await _selectTime(context);
                if (time != null) {
                  _recordTherapy('Večernja terapija', time);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
