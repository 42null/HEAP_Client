import 'package:flutter/material.dart';

enum JobType {
  FILL_IN_REQUEST,
}

class Job {
  final String jobId;
  final int itemId;
  final JobType jobType;
  final String payload;
  final int priority;

  Job({
    required this.jobId,
    required this.itemId,
    required this.jobType,
    required this.payload,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'itemId': itemId,
      'jobType': jobType.index,
      'payload': payload,
      'priority': priority,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      jobId: map['jobId'] as String? ?? '',
      itemId: (map['itemId'] as num?)?.toInt() ?? 0,
      jobType: JobType.values[map['jobType'] as int? ?? 0],
      payload: map['payload'] as String? ?? '',
      priority: (map['priority'] as num?)?.toInt() ?? 0,
    );
  }
}