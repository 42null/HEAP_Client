import 'dart:async';
import '../data/queue_repository.dart';
import '../models/queue_item.dart';

/// Data class to hold debug information about the currently active job execution.
class ActiveJobInfo {
  final QueueItem item;
  final DateTime startTime;
  final String endpoint;

  ActiveJobInfo(this.item, this.startTime, this.endpoint);
}

class JobExecutor {
  final QueueRepository _repository = QueueRepository();
  bool _isRunning = false;

  // Observable state for the UI to debug what's happening
  final StreamController<ActiveJobInfo?> _activeJobController = StreamController<ActiveJobInfo>.broadcast();
  Stream<ActiveJobInfo?> get activeJobStream => _activeJobController.stream;

  /// Starts the job execution loop. This will run in the background and 
  /// process jobs one by one in a serial manner (FIFO based on createdAt).
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      while (_isRunning) {
        final List<QueueItem> items = await _repository.getPendingJobs();
        
        if (items.isNotEmpty) {
          final jobToProcess = items.first;
          await _processJob(jobToProcess);
        } else {
          // No pending jobs, wait a bit before checking again
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      print('Critical error in JobExecutor loop: $e');
    }
  }

  /// Stops the job execution loop and closes streams.
  void stop() {
    _isRunning = false;
    _activeJobController.close();
  }

  /// Processes a single job sequentially.
  Future<void> _processJob(QueueItem item) async {
    try {
      // 1. Update status to SENDING
      await _repository.updateJobStatus(item.queueId, QueueStatus.SENDING);

      // Define endpoint based on type (Mocked for now)
      final String endpoint = _getEndpointForType(item.jobType);

      // Notify UI that we are starting this job
      _activeJobController.add(ActiveJobInfo(item, DateTime.now(), endpoint));

      // 2. Placeholder for API Call
      print('Executing Job: ${item.jobId} (Type: ${item.jobType}) at $endpoint');
      await _mockApiCall(item);

      // 3. Update status to COMPLETED
      await _repository.updateJobStatus(item.queueId, QueueStatus.COMPLETED);
    } catch (e) {
      print('Error executing job ${item.jobId}: $e');
      
      int newRetryCount = item.retryCount + 1;
      await _repository.updateJobStatus(
        item.queueId, 
        QueueStatus.PENDING, 
        errorMessage: e.toString(),
        retryCount: newRetryCount
      );
    } finally {
      // Clear active job info when done or failed (only if controller is still open)
      if (!_activeJobController.isClosed) {
        _activeJobController.add(null);
      }
    }
  }

  String _getEndpointForType(dynamic type) {
    // Mocked endpoints - replace with real logic later
    return "https://api.heap.dev/v1/jobs/${type.toString().toLowerCase()}";
  }

  /// Mock API call to simulate network latency and success/failure.
  Future<void> _mockApiCall(QueueItem item) async {
    await Future.delayed(const Duration(seconds: 3));
    // Simulate random failure for testing (10% chance)
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('Mocked Network Error');
    }
  }
}