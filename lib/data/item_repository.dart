import 'package:flutter/material.dart';
import '../models/item.dart';
import 'sample_items.dart';

class ItemRepository extends ChangeNotifier {
  static final ItemRepository _instance = ItemRepository._internal();
  factory ItemRepository() => _instance;
  ItemRepository._internal();

  static final ItemRepository repository = ItemRepository();

  final List<Item> _items = sampleItems;

  List<Item> get items => List.unmodifiable(_items);

  Item? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateItem(Item newItem) {
    int index = _items.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      _items[index] = newItem;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void createItem(Item newItem) {
    _items.add(newItem);
    notifyListeners();
  }
}
