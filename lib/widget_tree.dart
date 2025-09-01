import 'package:flutter/material.dart';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:shopping_list/pages/add.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late List<GroceryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [];
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
    setState(() => _items[idx] = updated);
    if (updated.id.isNotEmpty) {
      final uri = Uri.https(
        'shopping-list-app-eac59-default-rtdb.firebaseio.com',
        'shopping-list/${updated.id}.json',
      );
      // fire-and-forget patch
      http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isComplete': updated.isComplete}),
      );
    }
  }

  Future<void> _deleteItem(GroceryItem item) async {
    setState(() => _items.remove(item));
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
                  onAdd: (item) => setState(() => _items.add(item)),
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
