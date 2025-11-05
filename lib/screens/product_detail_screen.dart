import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  Product? _findProduct(BuildContext context) {
    final storeProvider = context.read<StoreProvider>();
    for (final store in storeProvider.stores) {
      final product = store.products.firstWhere(
        (p) => p.id == productId,
        orElse: () => null as Product,
      );
      if (product != null) return product;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final product = _findProduct(context);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              final cartItem = cart.items.firstWhere(
                (item) => item.product.id == product.id,
                orElse: () => null as dynamic,
              );
              final quantity = cartItem?.quantity ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    if (quantity > 0)
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.shopping_cart),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Product name
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Price
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Stock status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product.inStock ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.inStock ? 'In Stock' : 'Out of Stock',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 32),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: product.inStock
                    ? () {
                        context.read<CartProvider>().addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () {
                                // Navigate to cart screen (will be implemented)
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}