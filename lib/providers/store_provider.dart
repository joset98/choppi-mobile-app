import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/store.dart';
import '../models/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';
  static const String storesEndpoint = '/stores';
}

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  bool _isLoading = false;
  String? _error;

  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.storesEndpoint}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          _stores = data.map((json) => Store.fromJson(json)).toList();
        } else {
          throw Exception('Expected list of stores, got: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load stores: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Store? getStoreById(int id) {
    return _stores.firstWhere((store) => store.id == id);
  }
}