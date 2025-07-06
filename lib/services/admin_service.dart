import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  /// Fetch Admin Overview Data
  static Future<Map<String, dynamic>> getOverview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiEndpoints.adminOverview),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET /admin/overview → ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch admin overview');
    }
  }

  /// Fetch Top Borrowers
  static Future<List<dynamic>> getTopBorrowers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiEndpoints.adminOverview}/top-borrowers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET /admin/overview/top-borrowers → ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch top borrowers');
    }
  }

  /// Fetch Overdue Books
  static Future<List<dynamic>> getOverdueBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiEndpoints.borrowings}/overdue'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET /borrowings/overdue → ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch overdue books');
    }
  }

  /// Send Overdue Email Reminders
  static Future<bool> sendOverdueReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${ApiEndpoints.borrowings}/overdue/remind'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('POST /borrowings/overdue/remind → ${response.statusCode}');
    print('Response Body: ${response.body}');

    return response.statusCode == 200;
  }

  /// Fetch All Users
  static Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(ApiEndpoints.users),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET /users → ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
