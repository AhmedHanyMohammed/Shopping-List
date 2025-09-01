import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:shopping_list/data/categories.dart';

class UpdateItemPage extends StatefulWidget {
  const UpdateItemPage({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  final GroceryItem item;
  final void Function(GroceryItem updated) onUpdate;

  @override
  State<UpdateItemPage> createState() => _UpdateItemPageState();
}

class _UpdateItemPageState extends State<UpdateItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late String _category;
  late int _quantity;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _urlController = TextEditingController(text: widget.item.url);
    _category = widget.item.category;
    _quantity = widget.item.quantity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final newName = _nameController.text.trim();
    final newUrl = _urlController.text.trim();
    final updated = widget.item.copyWith(
      name: newName,
      category: _category,
      quantity: _quantity,
      url: newUrl,
    );

    if (updated.id.isNotEmpty) {
      final uri = Uri.https(
        'shopping-list-app-eac59-default-rtdb.firebaseio.com',
        'shopping-list/${updated.id}.json',
      );
      try {
        await http.patch(
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
      } catch (_) {
        // ignore network errors silently
      }
    }

    widget.onUpdate(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: Categories.data.entries.map(
                  (e) {
                    const double dotSize = 14;
                    return DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: e.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.key),
                        ],
                      ),
                    );
                  },
                ).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _category = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Quantity'),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                    Text('$_quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL (optional)',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  final uri = Uri.tryParse(t);
                  if (uri == null ||
                      !uri.isAbsolute ||
                      !(uri.scheme == 'http' || uri.scheme == 'https')) {
                    return 'Invalid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
