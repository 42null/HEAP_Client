import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../models/base_model.dart';
import '../models/item.dart';
import '../data/api_service.dart';

class ItemRepository extends ChangeNotifier {
  static final ItemRepository _instance = ItemRepository._internal();
  factory ItemRepository() => _instance;
  ItemRepository._internal();

  static final ItemRepository repository = ItemRepository();

  final List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);

  Future<void> fetchItems() async {
    try {
      final List<Map<String, dynamic>> maps = await ApiService().getItems();
      _items.clear();
      for (var map in maps) {
        _items.add(Item(
          id: (map['id'] as num).toInt(),
          title: ItemTitle(value: map['title'] as String, editorSource: EditorSource(sourceType: SourceType.USER, name: "API")),
          priority: (map['priority'] as num?)?.toInt() ?? 0,
          progressStatus: _mapProgressStatus(map['progressStatus'] as String?),
        ));
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  ProgressStatus _mapProgressStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'BACKLOG': return ProgressStatus.BACKLOG;
      case 'SELECTED': return ProgressStatus.SELECTED;
      case 'IN_PROGRESS': return ProgressStatus.IN_PROGRESS;
      case 'COMPLETED': return ProgressStatus.COMPLETED;
      case 'ARCHIVED': return ProgressStatus.ARCHIVED;
      default: return ProgressStatus.UNSET;
    }
  }

  Future<void> fetchItemById(int id) async {
    try {
      final map = await ApiService().getItemById(id);
      final item = Item(
        id: map['id'] as int,
        title: ItemTitle(value: map['title'] as String, editorSource: EditorSource(sourceType: SourceType.USER, name: "API")),
        priority: (map['priority'] as num?)?.toInt() ?? 0,
        progressStatus: _mapProgressStatus(map['progressStatus'] as String?),
      );
      
      int index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = item;
      } else {
        _items.add(item);
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching item by id: $e");
    }
  }

  Item? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  void createItem(Item newItem) {
    _items.add(newItem);
    notifyListeners();
  }

  void updateItem(Item newItem) {
    int index = _items.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      _items[index] = newItem;
    } else {
      _items.add(newItem);
    }
    notifyListeners();

    final Map<String, dynamic> data = {
      'title': newItem.title?.value,
      'priority': newItem.priority,
      'progressStatus': newItem.progressStatus.name,
    };
    ApiService().updateItem(newItem.id, data).catchError((e) {
      print("Error updating item on server: $e");
    });
  }

  /// Updates a specific field of an item live.
  /// [id] is the unique identifier of the item.
  /// [fieldIdentifier] specifies which field to update (e.g., 'title', 'priority').
  /// [newValue] is the new value for that field.
  void updateFieldLive(int id, String fieldIdentifier, String newValue, bool pending, EditorSource editorSource) {
    print('Updating field "$fieldIdentifier" with value: "$newValue" for item ID: $id (pending=$pending)');
    final item = getItemById(id);
    if (item != null) {
      switch (fieldIdentifier) {
        case 'title':
          item.title = ItemTitle(value: newValue, editorSource: editorSource);
          break;
        case 'priority':
          item.priority = int.tryParse(newValue);
          break;
        default:
          break;
      }
      notifyListeners();

      final Map<String, dynamic> data = {};
      if (fieldIdentifier == 'title') {
        data['title'] = item.title?.value;
      } else if (fieldIdentifier == 'priority') {
        data['priority'] = item.priority;
      }
      // For status, it's not currently handled in updateFieldLive, but could be.
      
      if (data.isNotEmpty) {
        ApiService().updateItem(id, data).then((_) {
          dev.log('Successfully updated item $id on server');
        }).catchError((e) {
          dev.log('Failed to update item $id on server: $e');
        });
      }
    }
  }

}
