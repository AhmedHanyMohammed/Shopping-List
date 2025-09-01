import 'package:shopping_list/model/grocery_items.dart';

class DummyItems {
  static final List<GroceryItem> items = [
    GroceryItem(
      name: 'Apple',
      category: 'Fruits',
      quantity: 5,
    ),
    GroceryItem(
      name: 'Carrot',
      category: 'Vegetables',
      quantity: 4,
    ),
    GroceryItem(
      name: 'Milk',
      category: 'Dairy',
      quantity: 3,
    ),
    GroceryItem(
      name: 'Bread',
      category: 'Bakery',
      quantity: 6,
    ),
    GroceryItem(
      name: 'Chicken',
      category: 'Meat',
      quantity: 2,
    ),
  ];
}