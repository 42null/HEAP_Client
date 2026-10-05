import '../models/item.dart';

final sampleItems = [
  const Item(id: 1, title: 'Finish Canvas assignment', priority: 3, status: ItemStatus.BACKLOG),
  const Item(id: 3, title: null, priority: null, status: ItemStatus.UNSET),
];