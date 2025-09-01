import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.events,
    required this.onViewed,
  });

  final List<dynamic> events; // expecting _AppEvent objects
  final VoidCallback onViewed;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void dispose() {
    // Mark events seen when leaving the page so next visit shows them as old
    widget.onViewed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events.reversed.toList(); // newest first
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: events.isEmpty
          ? const Center(child: Text('No activity yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final e = events[i];
                final bool isNew = e.isNew;
                return Container(
                  decoration: BoxDecoration(
                    color: isNew
                        ? Colors.amber.shade400
                        : Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: isNew ? Colors.amber[800] : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.text,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(e.time),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return '${_two(dt.hour)}:${_two(dt.minute)}:${_two(dt.second)}';
    }
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}
