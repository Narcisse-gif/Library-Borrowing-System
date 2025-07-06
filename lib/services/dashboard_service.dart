import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'json_helper.dart';

class DashboardService {
  /// Fetch Student Dashboard Data
  static Future<Map<String, int>> fetchStudentDashboard(String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/dashboard/student/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = JsonHelper.decode(response.body);
        print('📊 Student dashboard data: $data');

        return {
          'borrowed': data['borrowedBooks'] ?? 0,
          'reservations': data['activeReservations'] ?? 0,
          'overdue': data['overdueBooks'] ?? 0,
          'read': data['booksRead'] ?? 0,
        };
      } else {
        print('❌ Failed to load dashboard data: ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Dashboard error: $e');
      return {};
    }
  }

  /// Fetch Borrowings for Student
  static Future<List<Map<String, dynamic>>> fetchUserBorrowings(String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = JsonHelper.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to load borrowings: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Borrowings error: $e');
      return [];
    }
  }

  /// Fetch Reservations for Student
  static Future<List<Map<String, dynamic>>> fetchUserReservations(String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = JsonHelper.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Failed to load reservations: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Reservations error: $e');
      return [];
    }
  }

  /// Renew Borrowing
  static Future<bool> renewBorrowing(String borrowingId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings/renew/$borrowingId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Renew borrowing error: $e');
      return false;
    }
  }

  /// Cancel Reservation
  static Future<bool> cancelReservation(String reservationId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations/$reservationId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Cancel reservation error: $e');
      return false;
    }
  }

  /// Fetch Admin Overview Dashboard
  static Future<Map<String, dynamic>> fetchAdminOverview() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/dashboard/admin/overview');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return JsonHelper.decode(response.body);
      } else {
        print('❌ Failed to fetch admin overview: ${response.statusCode} → ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Admin overview fetch error: $e');
      return {};
    }
  }
}
