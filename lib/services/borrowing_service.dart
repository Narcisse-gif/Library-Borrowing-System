import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/borrowing_model.dart';

class BorrowingService {
  // Fetch borrowings of a specific user
  static Future<List<BorrowingModel>> fetchUserBorrowings(String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings/user/$userId');

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
        return data.map((e) => BorrowingModel.fromJson(e)).toList();
      } else {
        print('Failed to load user borrowings: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching user borrowings: $e');
      return [];
    }
  }

  // Fetch all borrowings (admin)
  static Future<List<BorrowingModel>> fetchAllBorrowings() async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings');

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
        return data.map((e) => BorrowingModel.fromJson(e)).toList();
      } else {
        print('Failed to load all borrowings: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching all borrowings: $e');
      return [];
    }
  }

  // Renew a borrowing
  static Future<bool> renewBorrowing(String borrowingId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings/$borrowingId/renew');

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
      print('Renew borrowing error: $e');
      return false;
    }
  }

  // Return a borrowed book
  static Future<bool> returnBook(String borrowingId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings/$borrowingId/return');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('ReturnBook response status: ${response.statusCode}');
      print('ReturnBook response body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Return borrowing error: $e');
      return false;
    }
  }


  // Create a new borrowing (for a user and a book)
  static Future<bool> borrowBook(String bookId, String userId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiEndpoints.baseUrl}/borrowings');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookId': bookId,
          'userId': userId,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Borrow book error: $e');
      return false;
    }
  }
}
