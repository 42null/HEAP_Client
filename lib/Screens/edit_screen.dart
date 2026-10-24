import 'package:flutter/material.dart';
import 'dart:async';
import '../models/base_model.dart';
import '../models/item.dart';
import '../data/item_repository.dart';
import '../data/queue_repository.dart';

class EditScreen extends StatefulWidget {
  final Item? item;

  const EditScreen({super.key, this.item});

  static double get labelWidth => 50.0;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priorityController;
  ProgressStatus _selectedStatus = ProgressStatus.UNSET;
  final QueueRepository _queueRepository = QueueRepository();

  // Map of field identifiers to their respective FocusNodes
  final Map<String, FocusNode> _focusNodes = {
    'title': FocusNode(),
    'priority': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title.toString());
    _priorityController = TextEditingController(text: widget.item?.priority?.toString());
    _selectedStatus = widget.item?.progressStatus ?? ProgressStatus.UNSET;

    // We no longer use listeners here as we'll handle updates via onSubmitted and focus change
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  void _saveItem() {
    if (widget.item != null) {
      // ItemRepository.repository.saveItem(updatedItem); //@@@






      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved successfully! - ${_titleController.text}')),
        );
      }
    } else {
      // Handle new item creation
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Simple unique ID
        title: ItemTitle(value: _titleController.text, editorSource: EditorSource(sourceType: SourceType.USER, name: "Editor")),
        priority: int.tryParse(_priorityController.text),
        progressStatus: _selectedStatus,
      );
      ItemRepository.repository.updateItem(newItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New item created!')),
        );
      }
    }
  }

  void _handleQueueAction(String payload) async {
    if (widget.item != null) {
      await _queueRepository.enqueue(payload, widget.item!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to queue')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please save the item before adding it to the queue')),
        );
      }
    }
  }

  void _handleFieldUpdate(String fieldIdentifier, String newValue) {
    if (widget.item != null) {
      ItemRepository.repository.updateFieldLive(widget.item!.id, fieldIdentifier, newValue);
    }
  }

  // Unified logic to handle both commit and temp storage
  void _onSubmitSave(String fieldIdentifier, String value, {bool pending=false}) {
    if (!pending) {
      // Logic for pressing Enter / explicit save
      _handleFieldUpdate(fieldIdentifier, value);
    } else {
      // Logic for losing focus / "auto-save" to temp storage
      print('Saving $fieldIdentifier to temporary storage: $value');
      FocusManager.instance.primaryFocus?.unfocus();
    // Unfocus the box


    // TODO: bring in
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
                          onTapOutside: (event) => _onSubmitSave('priority', _titleController.text, pending: true),
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
                            return DropdownMenuItem(
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