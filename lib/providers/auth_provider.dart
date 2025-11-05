import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';
  static const String authEndpoint = '/auth';
}

class User {
  final String email;
  final String id;

  User({required this.email, required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      id: json['id'],
    );
  }
}

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  String? _token;
  User? _user;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  User? get user => _user;

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');

    if (token != null && userData != null) {
      _token = token;
      _user = User.fromJson(json.decode(userData));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> _storeAuth(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', json.encode({
      'email': user.email,
      'id': user.id,
    }));
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _token = data['token'];
          _user = User.fromJson(data['user']);
          _isLoggedIn = true;
          await _storeAuth(_token!, _user!);
        } else {
          throw Exception('Login failed');
        }
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        // After registration, auto login
        await login(email, password);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    _error = null;
    await _clearStoredAuth();
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    await _loadStoredAuth();
  }
}