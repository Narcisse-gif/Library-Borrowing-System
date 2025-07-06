import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('AuthService.login called with email=$email');

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        print('Token saved');

        // ✅ Inject token into user map before returning
        final user = data['user'];
        user['token'] = data['token'];

        return {
          'success': true,
          'user': user,
        };
      } else {
        print('Login failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Exception in login: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String role,
      ) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': data['message'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Token removed on logout');
  }

  // UPDATE USER PROFILE
  Future<bool> updateUserProfile(String name) async {
    try {
      final token = await _getToken();

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      print('Update profile status: ${response.statusCode}');
      print('Update response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
