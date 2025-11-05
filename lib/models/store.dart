import 'product.dart';

class Store {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Product> products;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.products,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      products: (json['products'] is List<dynamic>)
          ? (json['products'] as List<dynamic>)
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}