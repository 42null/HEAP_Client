import 'package:flutter/material.dart';
import '../data/queue_repository.dart';
import '../models/queue_item.dart';

class QueueTrackerScreen extends StatefulWidget {
  const QueueTrackerScreen({super.key});

  @override
  State<QueueTrackerScreen> createState() => _QueueTrackerScreenState();
}

class _QueueTrackerScreenState extends State<QueueTrackerScreen> {
  final QueueRepository _repository = QueueRepository();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAddTask() async {
    final value = _controller.text;
    if (value.isNotEmpty) {
      await _repository.enqueue(value);
      _controller.clear();
    }
  }

  @override
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
                        title: Text(item.id),
                        subtitle: Text('Status: ${item.status.toString()}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Payload',
                    ),
                    onSubmitted: (_) => _handleAddTask(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleAddTask,
                    child: const Text('Add to Queue'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Remove Items:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<QueueItem>>(
                      stream: _repository.getQueueStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final items = snapshot.data!;
                          if (items.isEmpty) {
                            return const Center(child: Text('No items to remove'));
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ListTile(
                                title: Text(item.id),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _repository.removeItem(item.id);
                                  },
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text('Loading items...'));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
