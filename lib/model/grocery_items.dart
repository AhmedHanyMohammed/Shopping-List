import 'package:flutter/material.dart';

class GroceryItem {
  const GroceryItem({
    required this.name,
    required this.category,
    required this.color,
  });

  final String name;
  final String category;
  final Color color;

  static Widget build(GroceryItem item) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: item.color),
      title: Text(item.name),
      subtitle: Text(item.category),
      trailing: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        color: Colors.grey,
        onPressed: () {

        },
      ),
    );
  }
}