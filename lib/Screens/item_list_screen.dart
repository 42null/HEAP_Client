import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/sample_items.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HEAP')),
      body: ListView.builder(
        itemCount: sampleItems.length,
        itemBuilder: (context, index) {
          final item = sampleItems[index];
          return ListTile(
            title: Text(item.title ?? '(untitled)'),
            subtitle: Text('${item.type} • ${item.status}'),
            trailing: Text('P${item.priority ?? '-'}'),
          );
        },
      ),
    );
  }
}