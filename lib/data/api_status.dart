import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_service.dart';

/// Enum describing the db API connection state shown on the UI.
enum ApiConnectionStatus {
  /// API reachable AND credentials accepted.
  connected,
  /// API is reachable but the credentials were rejected.
  unauthorized,
  /// Connection state is currently being checked.
  checking,
  /// API is not reachable (timeout / connection refused).
  unreachable,
  /// Something unexpected went wrong.
  error,
}

/// Singleton that periodically checks whether the db API is reachable with the
/// configured credentials and exposes the result to the UI via [ChangeNotifier].
///
/// Usage:
/// ```dart
/// final status = ApiStatus.instance;
/// status.start();   // begin polling
/// // later:
/// status.connectionStatus; // current ApiConnectionStatus
/// status.stop();
/// ```
class ApiStatus extends ChangeNotifier {
  ApiStatus._internal();

  static final ApiStatus instance = ApiStatus._internal();

  ApiConnectionStatus _status = ApiConnectionStatus.checking;

  ApiConnectionStatus get connectionStatus => _status;

  /// Runs a single connectivity + authentication check and updates the state
  /// accordingly:
  ///  - not reachable     -> ApiConnectionStatus.unreachable
  ///  - reachable + auth ok -> ApiConnectionStatus.connected
  ///  - reachable + auth fail -> ApiConnectionStatus.unauthorized
  ///  - unexpected error  -> ApiConnectionStatus.error
  void check() {
    _status = ApiConnectionStatus.checking;
    notifyListeners();
    ApiService().checkReachable().then((reachable) async {
      if (!reachable) {
        _status = ApiConnectionStatus.unreachable;
        notifyListeners();
        return;
      }
      final authenticated = await ApiService().authenticate();
      _status = authenticated ? ApiConnectionStatus.connected : ApiConnectionStatus.unauthorized;
      notifyListeners();
    }).catchError((_) {
      _status = ApiConnectionStatus.error;
      notifyListeners();
    });
  }

  /// Starts a periodic poll (default every 3 seconds).
  void start() {
    check();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      check();
    });
  }

  /// Stops polling.
  void stop() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  Timer? _timer;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
