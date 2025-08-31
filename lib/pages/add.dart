import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late final Map<String, Color> _categories;
  String? _selectedKey;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _categories = Categories.data;
    if (_categories.isNotEmpty) {
      _selectedKey = _categories.keys.first;
      _selectedColor = _categories[_selectedKey];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedKey,
              items: _categories.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: e.value,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
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
                  _selectedColor = val == null ? null : _categories[val]!;
                });
              },
            ),
            const SizedBox(height: 24),
            if (_selectedKey != null && _selectedColor != null)
              Chip(
                label: Text(_selectedKey!),
                backgroundColor: _selectedColor!,
              ),
            if (_selectedKey == 'others' && _selectedColor != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}