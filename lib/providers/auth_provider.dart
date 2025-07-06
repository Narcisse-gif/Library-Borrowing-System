import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    print('AuthProvider.login called');
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;
    notifyListeners();

    if (result['success']) {
      print('Login successful, parsing user...');
      try {
        _user = UserModel.fromJson(result['user']);
        print('User loaded: ${_user!.email}, role: ${_user!.role}');
      } catch (e) {
        print('Error parsing user: $e');
        return false;
      }
      return true;
    } else {
      print('Login failed: ${result['message']}');
      return false;
    }
  }

  Future<String?> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(name, email, password, role);

    _isLoading = false;
    notifyListeners();

    return result['success'] ? null : result['message'];
  }

  Future<bool> updateUserProfile(String name, {String? email, String? password}) async {
    try {
      final token = _user?.token;

      final response = await http.put(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(jsonDecode(response.body)['user']);
        _user = UserModel(
          id: updatedUser.id,
          name: updatedUser.name,
          email: updatedUser.email,
          role: updatedUser.role,
          token: token, // ✅ keep existing token
        );
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }





  void logout() {
    _authService.logout();
    _user = null;
    notifyListeners();
  }
}
