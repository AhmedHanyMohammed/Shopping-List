import 'package:flutter/material.dart';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:shopping_list/pages/add.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/pages/update.dart';
import 'package:shopping_list/pages/notification.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late List<GroceryItem> _items;
  final List<_AppEvent> _events = []; // internal event log

  @override
  void initState() {
    super.initState();
    _items = [];
  }

  void _log(String msg) {
    setState(() {
      _events.add(_AppEvent(msg));
    });
  }

  bool get _hasNewEvents => _events.any((e) => e.isNew);

  void _markEventsSeen() {
    setState(() {
      for (final e in _events) {
        e.isNew = false;
      }
    });
  }

  Future<void> _clearIncomplete() async {
    final toDelete = _items.where((g) => !g.isComplete).toList();
    if (toDelete.isEmpty) return;
    // remove locally
    setState(() {
      _items.removeWhere((g) => !g.isComplete);
    });
    // remove from backend
    for (final item in toDelete) {
      _log('Deleted (clear): ${item.name}');
      if (item.id.isEmpty) continue;
      final uri = Uri.https(
        'shopping-list-app-eac59-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json',
      );
      try { await http.delete(uri); } catch (_) {}
    }
  }

  void _applyUpdated(GroceryItem original, GroceryItem updated) {
    final idx = _items.indexOf(original);
    if (idx == -1) return;
    final wasCompleteChange = original.isComplete != updated.isComplete;
    final otherChange = original.name != updated.name ||
        original.category != updated.category ||
        original.quantity != updated.quantity ||
        original.url != updated.url;
    setState(() => _items[idx] = updated);
    if (wasCompleteChange) {
      _log(
        updated.isComplete
            ? 'Marked complete: ${original.name}'
            : 'Reopened: ${original.name}',
      );
    } else if (otherChange) {
      final diffs = <String>[];
      if (original.name != updated.name) {
        diffs.add("name: '${original.name}' -> '${updated.name}'");
      }
      if (original.category != updated.category) {
        diffs.add("category: ${original.category} -> ${updated.category}");
      }
      if (original.quantity != updated.quantity) {
        diffs.add("quantity: ${original.quantity} -> ${updated.quantity}");
      }
      if (original.url != updated.url) {
        final oldUrl = (original.url.trim().isEmpty) ? '(none)' : original.url;
        final newUrl = (updated.url.trim().isEmpty) ? '(none)' : updated.url;
        diffs.add("url: $oldUrl -> $newUrl");
      }
      _log('Updated: ${updated.name} [${diffs.join(', ')}]');
    }
    if (updated.id.isNotEmpty) {
      final uri = Uri.https(
        'shopping-list-app-eac59-default-rtdb.firebaseio.com',
        'shopping-list/${updated.id}.json',
      );
      http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': updated.name,
          'category': updated.category,
          'quantity': updated.quantity,
          'url': updated.url,
          'isComplete': updated.isComplete,
        }),
      );
    }
  }

  Future<void> _deleteItem(GroceryItem item) async {
    setState(() => _items.remove(item));
    _log('Deleted: ${item.name}');
    if (item.id.isEmpty) return;
    final uri = Uri.https(
      'shopping-list-app-eac59-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    try { await http.delete(uri); } catch (_) {}
  }

  Widget _buildList(List<GroceryItem> items, String emptyMsg) {
    if (items.isEmpty) return Center(child: Text(emptyMsg));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return GroceryItem.build(
          item,
          (updated) => _applyUpdated(item, updated),
          onDelete: () => _deleteItem(item),
          extraActions: item.isComplete
              ? const [] // no edit option for completed
              : [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UpdateItemPage(
                              item: item,
                              onUpdate: (u) => _applyUpdated(item, u),
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    ],
                  ),
                ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomplete = _items.where((i) => !i.isComplete).toList();
    final completed = _items.where((i) => i.isComplete).toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Shopping List'),
          actions: [
            IconButton(
              tooltip: 'Notifications',
              icon: Icon(
                Icons.notifications,
                color: _hasNewEvents ? Colors.amber : Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => NotificationPage(
                      events: _events,
                      onViewed: _markEventsSeen,
                    ),
                  ),
                )
                    .then((_) {
                  // Ensure icon updates (in case route dispose timing missed)
                  if (_hasNewEvents) {
                    _markEventsSeen();
                  } else {
                    setState(() {}); // force rebuild to refresh icon color
                  }
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: incomplete.isEmpty ? null : _clearIncomplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear'),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incomplete'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(incomplete, 'No items'),
            _buildList(completed, 'No completed items'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddItemPage(
                  onAdd: (item) {
                    setState(() => _items.add(item));
                    _log('Added: ${item.name}');
                  },
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// simple internal event model
class _AppEvent {
  _AppEvent(this.text)
      : time = DateTime.now(),
        isNew = true;
  final String text;
  final DateTime time;
  bool isNew;
}
