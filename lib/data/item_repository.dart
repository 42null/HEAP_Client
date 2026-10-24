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

  /// Updates a specific field of an item live.
  /// [id] is the unique identifier of the item.
  /// [fieldIdentifier] specifies which field to update (e.g., 'title', 'priority').
  /// [newValue] is the new value for that field.
  void updateFieldLive(int id, String fieldIdentifier, String newValue) {
    print('Updating field $fieldIdentifier with value: $newValue for item ID: $id');
    final item = getItemById(id);
    if (item != null) {
      switch (fieldIdentifier) {
        case 'title':
          // Note: In a real app, we'd need to handle the ItemTitle object correctly.
          // For now, we just update the raw value as requested by the user.
          // We assume there's a way to update it or we recreate the item with new values.
          final updatedItem = Item(
            id: item.id,
            title: ItemTitle(value: newValue, editorSource: item.title!.editorSource),
            priority: int.tryParse(item.priority?.toString() ?? '0') ?? 0,
            progressStatus: item.progressStatus,
          );
          updateItem(updatedItem);
          break;
        case 'priority':
          final updatedItem = Item(
            id: item.id,
            title: item.title,
            priority: int.tryParse(newValue) ?? 0,
            progressStatus: item.progressStatus,
          );
          updateItem(updatedItem);
          break;
        default:
          // Handle other fields as needed
          break;
      }
    }
  }

  /// Saves the current state of an item to temporary storage.
  /// This is used when the field is unfocused.
  Future<void> saveToTempStorage(Item item) async {
    print('Saving item ${item.id} to temporary storage');
    // TODO: Implement actual temp storage logic (e.g., SharedPreferences or local DB)
    // For now, we just print the intent.
  }

  /// Performs a live update of an item's field in the repository.
  /// This is used when the user presses 'Enter'.
  void commitUpdate(int id, String fieldIdentifier, String newValue) {
    print('Committing update for field $fieldIdentifier with value: $newValue for item ID: $id');
    updateFieldLive(id, fieldIdentifier, newValue);
  }
}
