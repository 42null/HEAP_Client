import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/item.dart';
import '../../data/item_repository.dart';

class EditScreen extends StatefulWidget {
  final Item? item;

  const EditScreen({super.key, this.item});

  static const double labelWidth = 100.0;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priorityController;
  late ProgressStatus _selectedStatus;

  // Track the current state of the item for local updates
  Item? _currentLocalItem;

  final Map<String, FocusNode> _focusNodes = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize controllers and local item state from widget.item
    _titleController = TextEditingController(text: widget.item?.title?.value ?? '');
    _priorityController = TextEditingController(text: widget.item?.priority?.toString() ?? '');
    _selectedStatus = widget.item?.progressStatus ?? ProgressStatus.UNSET;

    // Initialize focus nodes
    _focusNodes['title'] = FocusNode();
    _focusNodes['priority'] = FocusNode();

    // We no longer use listeners here as we'll handle updates via onSubmitted and focus change
  }

  // --- Core Saving Logic ---
  Future<void> _saveItem() async {
    if (_currentLocalItem == null) return;

    final itemToSave = _currentLocalItem!;

    try {
      if (itemToSave.id != -1) {
        // Update existing item
        ItemRepository().updateItem(itemToSave);
      } else {
        // Create new item
        ItemRepository().createItem(itemToSave);
      }
      // Signal parent to refresh the list/state
      // In a real app, this would involve a callback to the parent
      // For this implementation, we assume a successful save clears the form or notifies the parent.
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // Handle save failure
      debugPrint("Failed to save item: $e");
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Save the data before the state is disposed (Auto-save on exit)
    _saveItem();

    // Dispose controllers and focus nodes to free memory
    _titleController.dispose();
    _priorityController.dispose();
    _keyboardFocusNode.dispose();
    _focusNodes.forEach((key, node) {
      node.dispose();
    });
    super.dispose();
  }

  void _handleQueueAction(String value) {
    debugPrint("Queue action for: $value");
  }

  void _onSubmitSave(String field, String? value, {bool pending = false}) {
    if (field == 'title') {
      _currentLocalItem?.setUncommited(titleText: value ?? '');
    } else if (field == 'priority') {
      _currentLocalItem?.setUncommited(priority: int.tryParse(value ?? ''));
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
                      SizedBox(width: EditScreen.labelWidth, child: const Text('Title')),
                      const SizedBox(width: 6),
                      QueueButton(onPressed: () => _handleQueueAction(_titleController.text)),
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          focusNode: _focusNodes['title'],
                          onSubmitted: (value) => _onSubmitSave('title', value),
                          onTapOutside: (event) => _onSubmitSave('title', _titleController.text, pending: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter title',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
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
                  Row(
                    children: [
                      SizedBox(width: EditScreen.labelWidth, child: const Text('Priority')),
                      const SizedBox(width: 6),
                      QueueButton(onPressed: () => _handleQueueAction(_priorityController.text)),
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priorityController,
                          focusNode: _focusNodes['priority'],
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) => _onSubmitSave('priority', value),
                          onTapOutside: (event) => _onSubmitSave('priority', _priorityController.text, pending: true),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter priority',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
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
                                  onPressed: () => _priorityController.clear(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: EditScreen.labelWidth, child: const Text('Status')),
                      const SizedBox(width: 6),
                      QueueButton(onPressed: () => _handleQueueAction(_selectedStatus.name)),
                    ]
                  ),
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
                            return DropdownMenuItem<ProgressStatus>(
                              value: status,
                              child: Text(status.name),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select status',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
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
                                  onPressed: () => _selectedStatus = ProgressStatus.UNSET,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (widget.item != null) {
                            await ItemRepository().deleteItem(widget.item!.id);
                            if (!mounted) return;
                            Navigator.pop(context);
                          }
                        },
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

class QueueButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const QueueButton({super.key, this.onPressed});

  @override
  State<QueueButton> createState() => _QueueButtonState();
}


class _QueueButtonState extends State<QueueButton> {
  bool _isProcessing = false;
  double _progress = 0.0;
  bool _isPaused = false;
  Timer? _timer;

  void _toggleQueueing() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }

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
      onPressed: _toggleQueueing,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size(EditScreen.labelWidth, 20),
      ),
      child: _isProcessing
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isPaused ? 'Paused' : 'Queued #${2}',
            style: const TextStyle(fontSize: 10),
          ),
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
          : const Text('Queue'),
    );
  }
}