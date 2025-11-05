class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool inStock;
  final int storeId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.inStock,
    required this.storeId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      inStock: json['in_stock'],
      storeId: json['store_id'],
    );
  }
}