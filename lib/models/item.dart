enum ItemStatus implements Comparable<ItemStatus> {
  UNSET(order: 0),
  BACKLOG(order: 1),
  SELECTED(order:  2),
  IN_PROGRESS(order: 3),
  COMPLETED(order: 4),
  ARCHIVED(order: 99);

  const ItemStatus({
    required this.order,
  });

  final int order;

  @override
  int compareTo(ItemStatus other) => order.compareTo(other.order);
}

class Item {
  final int id;
  final String? title;
  final int? priority;
  final ItemStatus status;

  const Item({
    required this.id,
    this.title,
    this.priority,
    required this.status,
  });
}
