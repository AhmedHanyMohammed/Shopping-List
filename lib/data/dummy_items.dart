import 'package:shopping_list/data/categories.dart';

class DummyItems {
  static final List<Map<String, dynamic>> items = [
    {
      'name': 'Apple',
      'category': 'Fruits',
      'color': Categories.data['Fruits'],
    },
    {
      'name': 'Carrot',
      'category': 'Vegetables',
      'color': Categories.data['Vegetables'],
    },
    {
      'name': 'Milk',
      'category': 'Dairy',
      'color': Categories.data['Dairy'],
    },
    {
      'name': 'Bread',
      'category': 'Bakery',
      'color': Categories.data['Bakery'],
    },
    {
      'name': 'Chicken',
      'category': 'Meat',
      'color': Categories.data['Meat'],
    }
    ];
}