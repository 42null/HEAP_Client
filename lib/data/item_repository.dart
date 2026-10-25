import 'package:flutter/material.dart';
import '../models/base_model.dart';
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

  /// Updates a specific field of an item live.
  /// [id] is the unique identifier of the item.
  /// [fieldIdentifier] specifies which field to update (e.g., 'title', 'priority').
  /// [newValue] is the new value for that field.
  void updateFieldLive(int id, String fieldIdentifier, String newValue, bool pending, EditorSource editorSource) {
    print('Updating field "$fieldIdentifier" with value: "$newValue" for item ID: $id (pending=$pending})');
    final item = getItemById(id);
    if (item != null) {
      switch (fieldIdentifier) {
        case 'title':
          item.title = ItemTitle(value: newValue, editorSource: editorSource);
          // API request here
          break;
        case 'priority':
          print("Not applying to other fields right now");
          break;
        default:
          break;
      }
    }
  }

}
