import '../models/item.dart';

final sampleItems = [
  const Item(id: 1, type: 'TODO', title: 'Finish Canvas assignment', priority: 3, status: 'BACKLOG'),
  const Item(id: 2, type: 'DAILY', title: 'Take pictures', priority: 5, status: 'BACKLOG'),
  const Item(id: 3, type: 'UNSET', title: null, priority: null, status: 'BACKLOG'),
];