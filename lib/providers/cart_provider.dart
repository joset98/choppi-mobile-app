import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';
  static const String cartEndpoint = '/cart';
}

class CartQuote {
  final double subtotal;
  final List<CartQuoteItem> items;

  CartQuote({required this.subtotal, required this.items});

  factory CartQuote.fromJson(Map<String, dynamic> json) {
    return CartQuote(
      subtotal: json['subtotal'].toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => CartQuoteItem.fromJson(item))
          .toList(),
    );
  }
}

class CartQuoteItem {
  final String storeProductId;
  final int quantity;
  final double price;
  final double subtotal;
  final Product product;
  final Store store;

  CartQuoteItem({
    required this.storeProductId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.product,
    required this.store,
  });

  factory CartQuoteItem.fromJson(Map<String, dynamic> json) {
    return CartQuoteItem(
      storeProductId: json['storeProductId'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      product: Product.fromJson(json['product']),
      store: Store.fromJson(json['store']),
    );
  }
}

class Store {
  final String id;
  final String name;

  Store({required this.id, required this.name});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  CartQuote? _quote;

  List<CartItem> get items => _items;
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isLoading => _isLoading;
  String? get error => _error;
  CartQuote? get quote => _quote;

  CartProvider() {
    _loadCart();
  }

  void addItem(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _quote = null;
    _saveCart();
    notifyListeners();
  }

  Future<void> calculateQuote(AuthProvider authProvider) async {
    if (_items.isEmpty) {
      _quote = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cartItems = _items.map((item) {
        // Assuming CartItem has a storeProductId, or we need to map product.id to storeProductId
        // For now, using product.id as storeProductId - this may need adjustment based on actual data
        return {
          'storeProductId': item.product.id.toString(), // This might need to be adjusted
          'quantity': item.quantity,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cartEndpoint}/quote'),
        headers: {
          'Content-Type': 'application/json',
          if (authProvider.token != null)
            'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode(cartItems),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _quote = CartQuote.fromJson(data);
      } else {
        throw Exception('Failed to calculate quote: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartData));
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart');
    if (cartData != null) {
      try {
        final decodedData = jsonDecode(cartData) as List<dynamic>;
        // Note: We can't properly load cart items without product data
        // This should be handled by fetching products first, then loading cart
        // For now, we'll clear the cart if we can't load it properly
        _items.clear();
        notifyListeners();
      } catch (e) {
        // Handle parsing error
        print('Error loading cart: $e');
        _items.clear();
        notifyListeners();
      }
    }
  }
}