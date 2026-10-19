import 'package:flutter/material.dart';
import '../data/queue_repository.dart';
import '../models/queue_item.dart';
import '../data/database.dart';

class QueueTrackerScreen extends StatefulWidget {
  const QueueTrackerScreen({super.key});

  @override
  State<QueueTrackerScreen> createState() => _QueueTrackerScreenState();
}

class _QueueTrackerScreenState extends State<QueueTrackerScreen> {
  final QueueRepository _repository = QueueRepository();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    super.dispose();
  }

  String _dbPath = "";

  @override
  void initState() {
    super.initState();
    _initDatabasePath();
  }

  Future<void> _initDatabasePath() async {
    final db = await DatabaseHelper.Instance.database;
    setState(() {
      _dbPath = db.path;
    });
  }

  Future<void> _handleAddTask() async {
    final value = _controller.text;
    final idValue = _idController.text;
    if (value.isNotEmpty && idValue.isNotEmpty) {
      final itemId = int.tryParse(idValue);
      if (itemId != null) {
        await _repository.enqueue(value, itemId);
        _controller.clear();
        _idController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid numeric Item ID')),
        );
      }
    }
  }

  Future<void> _removeItem(String id) async {
    await _repository.removeItem(id);
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueueItem>>(
              stream: _repository.getQueueStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('Queue is empty'));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            item.payload.isNotEmpty ? item.payload : 'No Payload',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${item.status.name}'),
                              Row(
                                children: [
                                  const Text('Priority: '),
                                  Text('${item.priority}'),
                                  const SizedBox(width: 8),
                                  const Text('Retries: '),
                                  Text('${item.retryCount}'),
                                ],
                              ),
                              if (item.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Error: ${item.errorMessage}',
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeItem(item.queueId),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          const Divider(thickness: 2, height: 2),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Debug System',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Payload',
                                  ),
                                  onSubmitted: (_) => _handleAddTask(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _idController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Item ID',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handleAddTask,
                            child: const Text('Queue Item'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(thickness: 2, height: 2),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Database Path:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SelectableText(_dbPath),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }
}
