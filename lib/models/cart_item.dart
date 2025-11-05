import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json, List<Product> products) {
    final product = products.firstWhere(
      (p) => p.id == json['product_id'],
      orElse: () => throw Exception('Product not found'),
    );
    return CartItem(
      product: product,
      quantity: json['quantity'],
    );
  }

  factory CartItem.fromJsonWithoutProducts(Map<String, dynamic> json) {
    // This is a fallback for when we don't have full product data
    // We would need to create a minimal Product object or handle differently
    // For now, we'll throw an exception to indicate this needs proper handling
    throw Exception('CartItem requires full product data for deserialization');
  }
}