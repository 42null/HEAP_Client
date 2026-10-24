import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../models/job.dart';
import 'database.dart';
import '../models/queue_item.dart';

class QueueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.Instance;

  Future<void> enqueue(String payload, int itemId, {int priority = 0, JobType jobType = JobType.FILL_IN_REQUEST}) async {
    final db = await _dbHelper.database;
    final jobId = Guid.newString();
    
    // Save the job details separately
    final newJob = Job(
      jobId: jobId,
      itemId: itemId,
      jobType: jobType,
      payload: payload,
      priority: priority,
    );

    await db.insert('jobs', newJob.toMap());

    // Save the queue item for processing
    final newItem = QueueItem(
      queueId: Guid.newString(),
      itemId: itemId,
      jobId: jobId,
      payload: payload, // Still keeping it here so the UI tracker works easily
      priority: priority,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    await db.insert('queue_items', newItem.toMap());
  }

  Future<void> removeItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('queue_items', where: 'queueId = ?', whereArgs: [id]);
  }

  Stream<List<QueueItem>> getQueueStream() async* {
    final db = await _dbHelper.database;
    while (true) {
      final List<Map<String, dynamic>> maps = await db.query(
        'queue_items',
        orderBy: 'priority DESC, createdAt ASC',
      );
      yield maps.map((map) => QueueItem.fromMap(map)).toList();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<int> getPosition(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> items = await db.query(
      'queue_items',
      where: 'id = ? AND status != 3', // Not completed
      whereArgs: [id],
      orderBy: 'priority DESC, createdAt ASC',
    );
    return items.length;
  }

  /// Fetches pending jobs ordered by priority then creation date (oldest first)
  Future<List<QueueItem>> getPendingJobs() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'queue_items',
      where: 'status = 0 OR status = 1', // PENDING (0) or SENDING (1) - though SENDING should be handled carefully
      orderBy: 'priority DESC, createdAt ASC',
    );
    return maps.map((map) => QueueItem.fromMap(map)).toList();
  }

  /// Updates the status of a specific queue item
  Future<void> updateJobStatus(String queueId, QueueStatus status, {int? retryCount, String? errorMessage}) async {
    final db = await _dbHelper.database;
    await db.update(
      'queue_items',
      {
        'status': status.index,
        if (retryCount != null) 'retryCount': retryCount,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
      where: 'queueId = ?',
      whereArgs: [queueId],
    );
  }
}

// Simple UUID helper since we don't have a package yet
class Guid {
  static String newString() {
    var charCodes = ['a', 'b', 'c', 'd', 'e', 'f', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    var result = '';
    for (var i = 0; i < 32; i++) {
      result += charCodes[Random().nextInt(charCodes.length)];
    }
    return result;
  }
}