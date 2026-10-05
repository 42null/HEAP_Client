class Item {
  final int id;
  final String type;
  final String? title;
  final int? priority;
  final String status;

  const Item({
    required this.id,
    required this.type,
    this.title,
    this.priority,
    required this.status,
  });
}
