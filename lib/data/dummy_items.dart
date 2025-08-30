import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class GroceryItem {
  const GroceryItem({
    required this.name,
    required this.category,
    required this.color,
  });

  final String name;
  final String category;
  final Color color;
}


class GroceryItems {
  static final List<GroceryItem> items = [
    GroceryItem(
      name: 'Apple',
      category: 'Fruits',
      color: Categories.data['Fruits']!,
    ),
    GroceryItem(
      name: 'Carrot',
      category: 'Vegetables',
      color: Categories.data['Vegetables']!,
    ),
    GroceryItem(
      name: 'Milk',
      category: 'Dairy',
      color: Categories.data['Dairy']!,
    ),
    GroceryItem(
      name: 'Bread',
      category: 'Bakery',
      color: Categories.data['Bakery']!,
    ),
    GroceryItem(
      name: 'Chicken',
      category: 'Meat',
      color: Categories.data['Meat']!,
    ),
  ];
}