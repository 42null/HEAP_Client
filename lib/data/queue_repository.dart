import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import '../models/queue_item.dart';

class QueueRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.Instance;

  Future<void> enqueue(String payload, {int priority = 0}) async {
    final db = await _dbHelper.database;
    final newItem = QueueItem(
      id: Guid.newString(),
      payload: payload,
      priority: priority,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    await db.insert('queue_items', newItem.toMap());
  }

  Future<void> removeItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('queue_items', where: 'id = ?', whereArgs: [id]);
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
