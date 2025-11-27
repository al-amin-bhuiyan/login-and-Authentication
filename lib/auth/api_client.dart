import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:log_auth/auth/api_config.dart';

import '../model/login_model.dart';

class ApiClient {
  static Future<LoginModel?> postLogin(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Profile fetch failed: ${response.statusCode}');
    }
  }
}
