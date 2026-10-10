import 'package:flutter/material.dart';
import '../models/item.dart';
import '../data/item_repository.dart';

class EditScreen extends StatefulWidget {
  final Item? item;

  const EditScreen({super.key, this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priorityController;
  Status _selectedStatus = Status.UNSET;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title);
    _priorityController = TextEditingController(text: widget.item?.priority?.toString());
    _selectedStatus = widget.item?.status ?? Status.UNSET;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (widget.item != null) {
      final updatedItem = Item(
        id: widget.item!.id,
        title: _titleController.text,
        priority: int.tryParse(_priorityController.text),
        status: _selectedStatus,
      );
      ItemRepository.repository.updateItem(updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved successfully!')),
      );
      // Optionally navigate back
      // Navigator.pop(context);
    } else {
      // Handle new item creation
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Simple unique ID
        title: _titleController.text,
        priority: int.tryParse(_priorityController.text),
        status: _selectedStatus,
      );
      ItemRepository.repository.updateItem(newItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New item created!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // The "long box" on the left side to go back
          GestureDetector(
            onTap: () {
              // Move to ItemListScreen (index 2)
              DefaultTabController.of(context).animateTo(2);
            },
            child: Container(
              width: 80,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.arrow_back, size: 40),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item != null ? 'Edit Item' : 'New Item',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text('Title'),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter title',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority'),
                  TextField(
                    controller: _priorityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter priority',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Status'),
                  DropdownButtonFormField<Status>(
                    value: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                    items: Status.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select status',
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _saveItem,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
