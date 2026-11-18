import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'dart:developer' as dev;

class ApiService {
  // Base URL and credentials are now centralized in ApiConfig.
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  factory ApiService() => instance;

  /// Helper to ensure the baseUrl is valid for URI parsing.
  /// It ensures the string starts with a scheme and has a host.
  String _getValidBaseUrl() {
    String base = ApiConfig.baseUrl.trim();

    if (base.isEmpty) {
      return 'http://localhost:9080';
    }

    // If the URL doesn't start with a scheme, prepend http://
    if (!base.startsWith('http://') && !base.startsWith('https://')) {
      // If user entered "localhost:9080", prepend "http://"
      if (base.contains(':')) {
        return 'http://$base';
      }
      return 'http://$base';
    }

    return base;
  }

  /// Generates the standard headers for API requests, including Basic Authentication.
  Map<String, String> get _headers {
    // Basic Auth requires "username:password" encoded in Base64.
    final auth = 'Basic ${base64Encode(utf8.encode('${ApiConfig.username}:${ApiConfig.password}'))}';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': auth,
    };
  }

  Future<bool> checkReachable() async {
    final baseUrl = _getValidBaseUrl();
    final url = '$baseUrl/actuator/health';

    dev.log('Checking health endpoint: $url');
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 5));
      dev.log('Health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Health check failed: $e');
      return false;
    }
  }

  /// Authenticates against the db API using HTTP Basic Auth.
  /// Since Basic Auth is sent in every request, we simply hit a protected
  /// endpoint (like /items) to verify that the credentials are correct.
  Future<bool> authenticate() async {
    final baseUrl = _getValidBaseUrl();
    // We use /items because it's protected and requires auth.
    final url = '$baseUrl/items';

    dev.log('Verifying credentials via: $url');
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 5));
      dev.log('Auth verification response: ${response.statusCode}');
      // If we get 200 OK, credentials are correct.
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Authentication verification failed: $e');
      return false;
    }
  }

  Future<void> postItem(Map<String, dynamic> data) async {
    final baseUrl = _getValidBaseUrl();
    final url = '$baseUrl/items';

    dev.log('Posting item to: $url | Data: $data');
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      dev.log('Failed to post item: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to post item: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final baseUrl = _getValidBaseUrl();
    final url = '$baseUrl/items';

    dev.log('Fetching items from: $url');
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode != 200) {
      dev.log('Failed to fetch items: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch items: ${response.body}');
    }

    return jsonDecode(response.body) as List<Map<String, dynamic>>;
  }
}
