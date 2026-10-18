import 'package:sqflite/sqflite.dart';

enum QueueStatus {
  PENDING,
  SENDING,
  PROCESSING,
  COMPLETED,
  FAILED
}

class QueueItem {
  final String id;
  final String payload;
  final QueueStatus status;
  final int priority;
  final int createdAt;
  final int retryCount;
  final String? errorMessage;

  QueueItem({
    required this.id,
    required this.payload,
    this.status = QueueStatus.PENDING,
    this.priority = 0,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payload': payload,
      'status': status.index,
      'priority': priority,
      'createdAt': createdAt,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  factory QueueItem.fromMap(Map<String, dynamic> map) {
    return QueueItem(
      id: map['id'],
      payload: map['payload'],
      status: QueueStatus.values[map['status']],
      priority: map['priority'],
      createdAt: map['createdAt'],
      retryCount: map['retryCount'],
      errorMessage: map['errorMessage'],
    );
  }
}