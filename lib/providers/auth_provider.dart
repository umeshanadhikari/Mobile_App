import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userRole;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userRole = prefs.getString('userRole');
    final userDataString = prefs.getString('userData');
    
    if (userDataString != null) {
      // Parse user data if exists
      // You might want to use json.decode here
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<bool> login(String id, String password) async {
    try {
      final response = await ApiService.login(id, password);

      if (response['success']) {
        _isAuthenticated = true;
        _userRole = response['role'];
        _token = response['token'];
        _userData = response['user'];

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userRole', _userRole!);
        // You might want to save userData as JSON string

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userRole = null;
      _token = null;
      _userData = null;

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Method to check if token is valid
  Future<bool> isTokenValid() async {
    if (_token == null) return false;
    
    try {
      // You might want to implement token validation logic here
      // For example, making an API call to verify token
      return true;
    } catch (e) {
      return false;
    }
  }
}