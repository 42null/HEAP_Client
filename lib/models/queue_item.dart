import 'package:sqflite/sqflite.dart';
import '../models/job.dart';

enum QueueStatus {
  PENDING,
  SENDING,
  PROCESSING,
  COMPLETED,
  FAILED
}

class QueueItem {
  final String queueId;
  final int itemId;
  final String jobId;
  final String payload;
  final JobType jobType;
  final QueueStatus status;
  final int priority;
  final int createdAt;
  final int retryCount;
  final String? errorMessage;

  QueueItem({
    required this.queueId,
    required this.itemId,
    required this.jobId,
    required this.payload,
    this.jobType = JobType.FILL_IN_REQUEST,
    this.status = QueueStatus.PENDING,
    this.priority = 0,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'queueId': queueId,
      'itemId': itemId,
      'jobId': jobId,
      'payload': payload,
      'jobType': jobType.index,
      'status': status.index,
      'priority': priority,
      'createdAt': createdAt,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  factory QueueItem.fromMap(Map<String, dynamic> map) {
    return QueueItem(
      queueId: map['queueId'] as String? ?? '',
      itemId: (map['itemId'] as num?)?.toInt() ?? 0,
      jobId: map['jobId'] as String? ?? '',
      payload: map['payload'] as String? ?? '',
      jobType: JobType.values[map['jobType'] as int? ?? 0],
      status: QueueStatus.values[map['status'] as int? ?? 0],
      priority: (map['priority'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as num?)?.toInt() ?? 0,
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}