import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central configuration for the db API endpoint and credentials.
///
/// Credentials are entered once (via the credentials dialog) and stored in
/// native secure storage (`flutter_secure_storage`: Android Keystore, iOS
/// Keychain, platform-native storage on other targets). They are decrypted here
/// on load and consumed by [ApiService] / [ApiStatus].
///
/// Usage:
/// ```dart
/// await ApiConfig.load();     // read credentials from secure storage
/// await ApiConfig.set(...);   // write new credentials (setup/edit flow)
/// ```
class ApiConfig {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Base URL of the db API.
  static String baseUrl = 'http://localhost:9080';

  /// Username used to authenticate with the db API.
  static String username = 'admin';

  /// Password used to authenticate with the db API.
  static String password = 'password';

  /// Whether any credentials have been stored in secure storage.
  static Future<bool> hasCredentials() async {
    try {
      final storedPassword = await _storage.read(key: 'heap_api_password');
      return storedPassword != null && storedPassword.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Reads all three credentials from secure storage.
  /// No-ops (keeping defaults) if nothing has been stored yet.
  static Future<void> load() async {
    try {
      final storedPassword = await _storage.read(key: 'heap_api_password');
      if (storedPassword != null && storedPassword.isNotEmpty) {
        final storedBaseUrl = await _storage.read(key: 'heap_api_base_url');
        final storedUsername = await _storage.read(key: 'heap_api_username');

        password = storedPassword;
        baseUrl = storedBaseUrl ?? baseUrl;
        username = storedUsername ?? username;
      }
    } catch (_) {
      // Ignore read errors; fall back to defaults.
    }
  }



  /// Writes all three credentials to secure storage (encrypted).
  static Future<void> set({required String baseUrl, required String username, required String password}) async {
    await _storage.write(
      key: 'heap_api_password',
      value: password,
    );
    await _storage.write(
      key: 'heap_api_base_url',
      value: baseUrl,
    );
    await _storage.write(
      key: 'heap_api_username',
      value: username,
    );
  }
}
