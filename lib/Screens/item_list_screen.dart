import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../widgets/pill_box.dart';
import '../models/item.dart';

class ItemListScreen extends StatelessWidget {
  final Function(Item) onItemSelected;

  const ItemListScreen({
    super.key,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ItemRepository.repository,
      builder: (context, _) {
        final items = ItemRepository.repository.items;
        return Scaffold(
          // appBar: AppBar(title: const Text('HEAP')),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    onItemSelected(item);
                  },
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(item.titleText),
                  subtitle: Row(
                    children: [
                      const Text('Status: '),
                      PillBox(
                        status: item.status,
                        onTap: () {
                          onItemSelected(item);
                        },
                      ),
                    ],
                  ),
                  trailing: Text('P${item.priority ?? '-'}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
