import 'package:flutter/material.dart';

/// Represents the source of an item's ownership or modification.
enum SourceType {
  PLATFORM(name: 'Native', color: 'gray'),
  USER(name: 'User', color: 'green'),
  API(name: 'API', color: 'blue'),
  AI_NATIVE(name: 'AI Native', color: 'purple');

  final String name;
  final String color; // Placeholder for color

  const SourceType({required this.name, required this.color});
}

class EditorSource {
  final SourceType sourceType;
  final String name;

  EditorSource({required this.sourceType, required this.name});
}

/// Base model that provides a common structure for heap items.
/// Subclasses should extend this to define specific data and color logic.
abstract class BaseItemModel {
  final dynamic value;
  final EditorSource editorSource;
  final DateTime setAt;
  final String historyMessage;

  // Constructor with defaults
  BaseItemModel({
    required this.value,
    required this.editorSource,
    DateTime? setAt,
    String? historyMessage,
  })  : setAt = setAt ?? DateTime.now(),
        historyMessage = historyMessage ?? 'Item initialized via ${editorSource.name}.';

  /// The color of the item, computed based on the specific model's state.
  /// This is intended to be overridden by subclasses.
  Color get givenColor;
}
