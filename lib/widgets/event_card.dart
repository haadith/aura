import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EventCard extends StatefulWidget {
  final String type; // npr. 'Umeren', 'Blag', 'Težak', 'Frisium'
  final IconData icon;
  final Color color;
  final String title;
  final DateTime dateTime;
  final String okolnost;
  final int trajanje;
  final String? geolokacija;
  final Map<String, dynamic>? healthData; // npr. {'puls': 72, ...}
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EventCard({
    super.key,
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.dateTime,
    required this.okolnost,
    required this.trajanje,
    this.geolokacija,
    this.healthData,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => widget.onEdit?.call(),
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Izmeni',
            ),
            SlidableAction(
              onPressed: (_) => widget.onDelete?.call(),
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Obriši',
            ),
          ],
        ),
        child: Card(
          color: widget.type == 'Frisium' ? const Color(0xFFDFF5E3) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          child: Column(
            children: [
              ListTile(
                leading: Icon(widget.icon, color: widget.color, size: 28),
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(widget.dateTime),
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Okolnost: ${widget.okolnost}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Trajanje: ${widget.trajanje} s',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (widget.geolokacija != null)
                      Row(
                        children: const [
                          Icon(Icons.location_on, size: 15, color: Colors.grey),
                          SizedBox(width: 2),
                          Text('Lokacija sačuvana', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                  ],
                ),
                trailing: widget.healthData != null
                    ? IconButton(
                        icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                        onPressed: () => setState(() => _expanded = !_expanded),
                      )
                    : null,
              ),
              if (_expanded && widget.healthData != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildHealthData(widget.healthData!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    // Format: utorak, 03. jun 2025. - 01:56
    // Ovo je pojednostavljeno, koristi intl za lokalizaciju ako treba
    return '${_weekday(dt.weekday)}, ${dt.day.toString().padLeft(2, '0')}. ${_month(dt.month)} ${dt.year}. - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _weekday(int w) {
    const days = ['ponedeljak', 'utorak', 'sreda', 'četvrtak', 'petak', 'subota', 'nedelja'];
    return days[(w - 1) % 7];
  }

  String _month(int m) {
    const months = [
      'januar', 'februar', 'mart', 'april', 'maj', 'jun',
      'jul', 'avgust', 'septembar', 'oktobar', 'novembar', 'decembar'
    ];
    return months[(m - 1) % 12];
  }

  Widget _buildHealthData(Map<String, dynamic> data) {
    // Prikaz health connect podataka u gridu
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            children: [
              _healthItem(Icons.favorite, 'Puls', data['puls']?.toString()),
              _healthItem(Icons.nightlight_round, 'San', data['san']?.toString()),
              _healthItem(Icons.directions_walk, 'Koraci', data['koraci']?.toString()),
              _healthItem(Icons.opacity, 'Saturacija', data['saturacija']?.toString()),
              _healthItem(Icons.monitor_weight, 'Težina', data['tezina']?.toString(), suffix: 'kg'),
              _healthItem(Icons.pie_chart, 'BMI', data['bmi']?.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthItem(IconData icon, String label, String? value, {String suffix = ''}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: Colors.blue[400]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(
          value != null && value.isNotEmpty ? '$value$suffix' : '-',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
} 