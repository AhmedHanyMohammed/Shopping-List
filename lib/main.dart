import 'package:flutter/material.dart';
import 'package:shopping_list/model/dummy.dart';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:shopping_list/pages/add.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal , brightness: Brightness.dark),
      ),
      home: const MyHomePage(title: 'Shopping List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<GroceryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<GroceryItem>.from(DummyItems.items);
  }

  void _clearAll() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded),
              tooltip: 'Clear All',
              color: Colors.red,
              onPressed: _items.isEmpty ? null : _clearAll,
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
            _items.isEmpty
                ? const Center(child: Text('No items'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return GroceryItem.build(item);
                    },
                  ),
            const Center(child: Text('No completed items yet')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddItemPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
