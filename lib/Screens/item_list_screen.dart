import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../widgets/pill_box.dart';
import '../models/item.dart';

class ItemListScreen extends StatefulWidget {
  final Function(Item) onItemSelected;

  const ItemListScreen({
    super.key,
    required this.onItemSelected,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch items from the repository, which is wired to the ApiService
    ItemRepository.repository.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ItemRepository.repository,
      builder: (context, _) {
        final items = ItemRepository.repository.items;

        if (items.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.nineteen_mp, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No items found in the database.'),
                  const SizedBox(height: 8),
                  Text(
                    'Ensure your credentials are correct and the API is reachable.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Database Items'),
            elevation: 0,
          ),
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
                    widget.onItemSelected(item);
                  },
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    item.title?.value ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      const Text('Status: '),
                      PillBox(
                        status: item.progressStatus,
                        onTap: () {
                          widget.onItemSelected(item);
                        },
                      ),
                    ],
                  ),
                  trailing: Text(
                    'P${item.priority ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
