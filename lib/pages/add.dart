import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/model/grocery_items.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key, required this.onAdd});
  final void Function(GroceryItem item) onAdd;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late final Map<String, Color> _categories;
  String? _selectedKey;
  static const double _colorDotSize = 14;
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _categories = Categories.data;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showMissingDialog(String message) async {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Incomplete'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
        ],
      ),
    );
  }

  void _handleSave() async{
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedKey == null) {
      _showMissingDialog(
        name.isEmpty && _selectedKey == null
            ? 'Please enter an item name and select a category.'
            : name.isEmpty
                ? 'Please enter an item name.'
                : 'Please select a category.',
      );
      return;
    }
    if(_urlController.text.isNotEmpty){
      final parsed = Uri.tryParse(_urlController.text.trim());
      if(parsed == null || !(parsed.isAbsolute && (parsed.hasScheme && (parsed.scheme == 'http' || parsed.scheme == 'https')))){
        _showMissingDialog('Please enter a valid URL.');
        return;
      }
    }

    final remoteUri = Uri.https(
      'shopping-list-app-eac59-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.post(
        remoteUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
            'category': _selectedKey!,
            'url': _urlController.text.trim(),
            'quantity': _quantity,
            'isComplete': false,
        }),
      );
      String id = '';
      try {
        final data = json.decode(response.body);
        id = data['name'] ?? '';
      } catch (_) {}
      widget.onAdd(
        GroceryItem(
          id: id,
          name: name,
          category: _selectedKey!,
          quantity: _quantity,
          url: _urlController.text.trim(),
        ),
      );
    } catch (_) {
      widget.onAdd(
        GroceryItem(
          name: name,
          category: _selectedKey!,
          quantity: _quantity,
          url: _urlController.text.trim(),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedKey,
                hint: const Text('Select a category'),
                items: _categories.entries
                    .map(
                      (e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: _colorDotSize,
                          height: _colorDotSize,
                          decoration: BoxDecoration(
                            color: e.value,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(e.key),
                      ],
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedKey = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Url (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Quantity:'),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}