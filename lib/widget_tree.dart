import 'package:flutter/material.dart';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:shopping_list/pages/add.dart';

// Moved from main.dart
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

  void _clearIncomplete() {
    setState(() {
      _items.removeWhere((g) => !g.isComplete);
    });
  }

  void _applyUpdated(GroceryItem original, GroceryItem updated) {
    final idx = _items.indexOf(original);
    if (idx == -1) return;
    setState(() => _items[idx] = updated);
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
