import 'package:flutter/material.dart';

class GroceryItem {
  const GroceryItem({
    required this.name,
    required this.category,
    required this.color,
    this.isComplete = false,
  });

  final String name;
  final String category;
  final Color color;
  final bool isComplete;

  GroceryItem copyWith({
    String? name,
    String? category,
    Color? color,
    bool? isComplete,
  }) => GroceryItem(
        name: name ?? this.name,
        category: category ?? this.category,
        color: color ?? this.color,
        isComplete: isComplete ?? this.isComplete,
      );


  static Widget build(GroceryItem item, ValueChanged<GroceryItem> onChanged) {
    final bool completed = item.isComplete;
    return ListTile(
      leading: CircleAvatar(backgroundColor: item.color),
      title: Text(item.name),
      subtitle: Text(item.category),
      trailing: IconButton(
        icon: Icon(completed ? Icons.cancel : Icons.check_circle),
        color: completed ? Colors.red : Colors.green,
        onPressed: () => onChanged(item.copyWith(isComplete: !completed)),
      ),
      onTap: () => onChanged(item.copyWith(isComplete: !completed)),
    );
  }
}