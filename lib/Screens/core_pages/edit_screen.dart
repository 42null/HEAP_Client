import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/item.dart';
import '../../data/item_repository.dart'; // Assuming this handles data operations

class EditScreen extends StatefulWidget {
  final Item? item;

  const EditScreen({super.key, this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priorityController;
  late Status _selectedStatus;

  // Track the current state of the item for local updates
  Item? _currentLocalItem;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize controllers and local item state from widget.item
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _priorityController = TextEditingController(text: widget.item?.priority.toString() ?? '');
    _selectedStatus = widget.item?.status ?? Status.UNSET;

    // Create a mutable local copy for editing
    _currentLocalItem = widget.item?.copyWith(
      title: widget.item?.title,
      priority: widget.item?.priority,
      status: widget.item?.status,
    ) ?? Item(id: -1, status: Status.UNSET); // -1 indicates a new item

    // Add listener to controllers to update the local item state as user types
    _titleController.addListener(_onTitleChanged);
    _priorityController.addListener(_onPriorityChanged);
  }

  void _onTitleChanged() {
    final newTitle = _titleController.text;
    setState(() {
      _currentLocalItem = _currentLocalItem!.copyWith(title: newTitle);
    });
  }

  void _onPriorityChanged() {
    final newPriority = int.tryParse(_priorityController.text);
    setState(() {
      _currentLocalItem = _currentLocalItem!.copyWith(priority: newPriority);
    });
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

  // --- Key Event Handling (Ctrl+S) ---
  void _handleKey(KeyEvent event) {
    // Check for Ctrl+S
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isControlPressed) {
      _saveItem();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New Item' : 'Edit Item'),
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: _handleKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              Text('Title', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                autofocus: widget.item == null, // Auto-focus if creating a new item
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter item title',
                ),
              ),
              const SizedBox(height: 20),
              // Priority Input
              Text('Priority', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _priorityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter priority (0-10)',
                ),
              ),
              const SizedBox(height: 20),
              // Status Selection
              Text('Status', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<Status>(
                initialValue: _selectedStatus,
                onChanged: (Status? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                    _currentLocalItem = _currentLocalItem!.copyWith(status: newValue!);
                  });
                },
                items: Status.values.map((status) {
                  return DropdownMenuItem<Status>(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  child: const Text('Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}