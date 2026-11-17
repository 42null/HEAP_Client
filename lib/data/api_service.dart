import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // Base URL and credentials are now centralized in ApiConfig.
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  factory ApiService() => instance;

  /// Performs a lightweight GET on the health endpoint to verify the db API
  /// is reachable. The server should respond with HTTP 200 when healthy.
  Future<bool> checkReachable() async {
    try {
      final response = await http
          .get(Uri.parse('$ApiConfig.baseUrl/actuator/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates against the db API with the configured username/password.
  /// Returns true only if the server accepts these credentials (e.g. 200).
  Future<bool> authenticate() async {
    try {
      final response = await http
          .post(
            Uri.parse('$ApiConfig.baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': ApiConfig.username,
              'password': ApiConfig.password,
            }),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> postItem(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$ApiConfig.baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to post item: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final response = await http.get(Uri.parse('$ApiConfig.baseUrl/items'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch items: ${response.body}');
    }

    return jsonDecode(response.body) as List<Map<String, dynamic>>;
  }
}
