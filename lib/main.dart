import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: DummyItems.items.length,
        itemBuilder: (context, index) {
          final item = DummyItems.items[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: item['color'],
            ),
            title: Text(item['name'] as String),
            subtitle: Text(item['category'] as String),
          );
        },
      ),
    );
  }
}
