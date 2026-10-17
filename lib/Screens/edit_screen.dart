import 'package:flutter/material.dart';
import 'dart:async';
import '../models/base_model.dart';
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
  ProgressStatus _selectedStatus = ProgressStatus.UNSET;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title.toString());
    _priorityController = TextEditingController(text: widget.item?.priority?.toString());
    _selectedStatus = widget.item?.progressStatus ?? ProgressStatus.UNSET;
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
        title: new ItemTitle(value: _titleController.text, editorSource: EditorSource(sourceType: SourceType.USER, name: "Editor")),
        priority: int.tryParse(_priorityController.text),
        progressStatus: _selectedStatus,
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
        title: new ItemTitle(value: _titleController.text, editorSource: EditorSource(sourceType: SourceType.USER, name: "Editor")),
        priority: int.tryParse(_priorityController.text),
        progressStatus: _selectedStatus,
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
                    widget.item != null ? 'Edit Item (screen)' : 'New Item (screen)',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('Title'),
                      const SizedBox(width: 8),
                      BillButton(),
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter title',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  // onTap: () => _titleController.clear(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.playlist_add_circle, color: Colors.blue, size: 18),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _titleController.clear(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priorityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter priority',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BillButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Status'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ProgressStatus>(
                          value: _selectedStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                          items: ProgressStatus.values.map((status) {
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
                      ),
                      const SizedBox(width: 8),
                      BillButton(),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
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

class BillButton extends StatefulWidget {
  const BillButton({super.key});

  @override
  State<BillButton> createState() => _BillButtonState();
}

class _BillButtonState extends State<BillButton> {
  bool _isProcessing = false;
  double _progress = 0.0;
  bool _isPaused = false;
  Timer? _timer;

  void _toggleBilling() {
    if (!_isProcessing) {
      setState(() {
        _isProcessing = true;
        _progress = 0.0;
        _isPaused = false;
      });
      _startTimer();
    } else {
      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPaused) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _timer?.cancel();
            setState(() {
              _isProcessing = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _toggleBilling,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(100, 40),
      ),
      child: _isProcessing
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Billing...', style: TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                  ),
                ),
              ],
            )
          : const Text('Bill'),
    );
  }
}
