import 'package:flutter/material.dart';
import '../data/queue_repository.dart';
import '../models/queue_item.dart';
import '../data/database.dart';
import '../services/job_executor.dart';

class QueueTrackerScreen extends StatefulWidget {
  const QueueTrackerScreen({super.key});

  @override
  State<QueueTrackerScreen> createState() => _QueueTrackerScreenState();
}

class _QueueTrackerScreenState extends State<QueueTrackerScreen> {
  final QueueRepository _repository = QueueRepository();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  
  // Initialize the executor
  final JobExecutor _executor = JobExecutor();

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _executor.stop(); // Ensure loop stops when screen is disposed
    super.dispose();
  }

  String _dbPath = "";

  @override
  void initState() {
    super.initState();
    _initDatabasePath();
    // Start the job executor in a background process
    _executor.start();
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

  Color _getStatusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.PENDING:
        return Colors.blue;
      case QueueStatus.SENDING:
        return Colors.orange;
      case QueueStatus.PROCESSING:
        return Colors.purple;
      case QueueStatus.COMPLETED:
        return Colors.green;
      case QueueStatus.FAILED:
        return Colors.red;
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
          // New Debug Info Area
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[800],
            child: StreamBuilder<ActiveJobInfo?>(
              stream: _executor.activeJobStream,
              builder: (context, snapshot) {
                final active = snapshot.data;
                if (active == null) {
                  return const Text(
                    'No active execution.',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTIVE EXECUTION DEBUG:', 
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Endpoint: ${active.endpoint}', style: const TextStyle(color: Colors.white)),
                    Text('Job ID: ${active.item.jobId}', style: const TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        const Text('Started: ', style: TextStyle(color: Colors.white)),
                        Text('${active.startTime},', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Payload: ${active.item.payload}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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
                      final queuedJob = items[index];
                      final statusColor = _getStatusColor(queuedJob.status);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.2),
                            child: Text('${index + 1}', style: TextStyle(color: statusColor)),
                          ),
                          title: Text(
                            queuedJob.payload.isNotEmpty ? queuedJob.payload : 'No Payload',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${queuedJob.status.name}',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Text('Priority: '),
                                  Text('${queuedJob.priority}'),
                                  const SizedBox(width: 8),
                                  const Text('Retries: '),
                                  Text('${queuedJob.retryCount}'),
                                ],
                              ),
                              if (queuedJob.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Error: ${queuedJob.errorMessage}',
                                    style: TextStyle(color: Colors.red, fontSize: 10),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Job ID: ${queuedJob.jobId}, Type: ${queuedJob.jobType.name}',
                                style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeItem(queuedJob.queueId),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
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