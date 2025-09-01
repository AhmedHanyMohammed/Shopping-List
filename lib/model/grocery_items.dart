import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:url_launcher/url_launcher.dart'; // for opening URLs

class GroceryItem {
  const GroceryItem({
    this.id = '',
    required this.name,
    required this.category,
    required this.quantity,
    this.isComplete = false,
    this.url = '',
  });

  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isComplete;
  final String url;

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    bool? isComplete,
    String? url,
  }) => GroceryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        isComplete: isComplete ?? this.isComplete,
        url: url ?? this.url,
      );

  static Widget build(
    GroceryItem item,
    ValueChanged<GroceryItem> onChanged, {
    VoidCallback? onDelete,
    List<Widget> extraActions = const [], // new
  }) {
    final bool completed = item.isComplete;
    final color = Categories.data[item.category] ?? Colors.grey;
    final hasUrl = item.url.trim().isNotEmpty;

    Future<void> openUrl() async {
      final uri = Uri.tryParse(item.url.trim());
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return ListTile(
      leading: CircleAvatar(backgroundColor: color),
      title: Text('${item.name} (x${item.quantity})'),
      subtitle: Text(item.category),
      onTap: hasUrl ? openUrl : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: completed ? 'Mark incomplete' : 'Mark complete',
            icon: Icon(completed ? Icons.cancel : Icons.check_circle),
            color: completed ? Colors.red : Colors.green,
            onPressed: () => onChanged(item.copyWith(isComplete: !completed)),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete),
              color: Colors.grey.shade700,
              onPressed: onDelete,
            ),
          ...extraActions,
        ],
      ),
    );
  }
}