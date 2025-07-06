import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/reservation_model.dart';

class ReservationService {
  // Fetch reservations of a specific user
  static Future<List<ReservationModel>> fetchUserReservations(String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations/user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ReservationModel.fromJson(e)).toList();
      } else {
        print('Failed to load user reservations (${response.statusCode}): ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching user reservations: $e');
      return [];
    }
  }

  // Fetch all reservations (admin)
  static Future<List<ReservationModel>> fetchAllReservations() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ReservationModel.fromJson(e)).toList();
      } else {
        print('Failed to load all reservations (${response.statusCode}): ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching all reservations: $e');
      return [];
    }
  }

  // Cancel a reservation
  static Future<bool> cancelReservation(String reservationId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations/$reservationId/cancel');

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
      print('Cancel reservation error: $e');
      return false;
    }
  }

  // Fulfill a reservation (admin)
  static Future<bool> fulfillReservation(String reservationId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/reservations/$reservationId/fulfill');

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
      print('Fulfill reservation error: $e');
      return false;
    }
  }
}
