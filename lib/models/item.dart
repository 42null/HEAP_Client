import 'package:flutter/material.dart';

enum Status implements Comparable<Status> {
  UNSET(order: 0, hexColor: '#D3D3D3'),
  BACKLOG(order: 1, hexColor: '#808080'),
  SELECTED(order: 2, hexColor: '#0000FF'),
  IN_PROGRESS(order: 3, hexColor: '#FFA500'),
  COMPLETED(order: 4, hexColor: '#008000'),
  ARCHIVED(order: 99, hexColor: '#A9A9A9');

  const Status({
    required this.order,
    required this.hexColor,
  });

  final int order;
  final String hexColor;
  Color get color => Color(int.parse(hexColor.replaceFirst('#', '0xFF')));

  @override
  int compareTo(Status other) => order.compareTo(other.order);
}

class Item {
  final int id;
  final String? title;
  final int? priority;
  final Status status;

  const Item({
    required this.id,
    this.title,
    this.priority,
    required this.status,
  });

  Item copyWith({
    int? id,
    String? title,
    int? priority,
    Status? status,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  String get titleText => title ?? '(untitled)';
  Color get color => status.color;
}
