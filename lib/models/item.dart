import 'package:flutter/material.dart';

import 'base_model.dart';

enum ProgressStatus implements Comparable<ProgressStatus> {
  UNSET(order: 0, hexColor: '#D3D3D3'),
  BACKLOG(order: 1, hexColor: '#808080'),
  SELECTED(order: 2, hexColor: '#0000FF'),
  IN_PROGRESS(order: 3, hexColor: '#FFA500'),
  COMPLETED(order: 4, hexColor: '#008000'),
  ARCHIVED(order: 99, hexColor: '#A9A9A9');

  const ProgressStatus({
    required this.order,
    required this.hexColor,
  });

  final int order;
  final String hexColor;
  Color get color => Color(int.parse(hexColor.replaceFirst('#', '0xFF')));

  @override
  int compareTo(ProgressStatus other) => order.compareTo(other.order);
}

class ItemTitle({required super.value, required super.editorSource}) extends BaseItemModel{
  @override
  // TODO: add some logic here to decide on colors
  Color get givenColor => ProgressStatus.UNSET.color;

}



class Item {
  Item? uncommittedEdit;
  int id;
  int? priority;
  ProgressStatus progressStatus;
  ItemTitle? title;

  Item({
    required this.id,
    this.uncommittedEdit,
    this.title,
    this.priority,
    required this.progressStatus,
  });

  void setUncommited({
    int? id,
    String? titleText,
    int? priority,
    ProgressStatus? progressStatus,
  }) {
    // return Item(
      // uncommittedEdit: uncommittedEdit ?? this.uncommittedEdit,
      this.id = id ?? this.id;
      this.title = title ?? this.title;
      this.priority = priority ?? this.priority;
      this.progressStatus = progressStatus ?? this.progressStatus;
    // );
  }

  void saveCommited({
    bool? id,
    bool? title,
    bool? priority,
    bool? progressStatus,
  }) {
    if(id != null && id){ this.id = this.uncommittedEdit!.id; }
    if(title != null && title){ this.title = this.uncommittedEdit?.title; }
    if(priority != null && priority){ this.priority = this.uncommittedEdit?.priority; }
    if(progressStatus != null && progressStatus){ this.progressStatus = this.uncommittedEdit!.progressStatus; }
  }

  ItemTitle get titleText => title ?? new ItemTitle(value: "(Unset)", editorSource: EditorSource(sourceType: SourceType.PLATFORM, name: "Item.dart default"));
  Color get statusColor => progressStatus.color;
}
