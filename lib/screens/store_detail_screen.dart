import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class StoreDetailScreen extends StatefulWidget {
  final int storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  bool _showOnlyInStock = false;
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final storeProvider = context.read<StoreProvider>();
    final store = storeProvider.getStoreById(widget.storeId);
    if (store != null) {
      setState(() {
        _filteredProducts = store.products
            .where((product) => !_showOnlyInStock || (product.inStock ?? false))
            .toList();
        _currentPage = 1; // Reset to first page when filtering
      });
    }
  }

  List<Product> _getCurrentPageProducts() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredProducts.sublist(
      startIndex,
      endIndex > _filteredProducts.length ? _filteredProducts.length : endIndex,
    );
  }

  int get _totalPages => (_filteredProducts.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'), // We'll add cart screen later
          ),
        ],
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          final store = storeProvider.getStoreById(widget.storeId);

          if (store == null) {
            return const Center(child: Text('Store not found'));
          }

          return Column(
            children: [
              // Store header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Image.network(
                      store.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(store.description),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filter toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Show only in stock'),
                    Switch(
                      value: _showOnlyInStock,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyInStock = value;
                        });
                        _filterProducts();
                      },
                    ),
                  ],
                ),
              ),

              // Products list
              Expanded(
                child: _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found'))
                    : ListView.builder(
                        itemCount: _getCurrentPageProducts().length,
                        itemBuilder: (context, index) {
                          final product = _getCurrentPageProducts()[index];
                          return FadeTransition(
                            opacity: AlwaysStoppedAnimation(1.0), // Simple fade
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ListTile(
                                leading: Image.network(
                                  product.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(product.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.description),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      (product.inStock ?? false) ? 'In Stock' : 'Out of Stock',
                                      style: TextStyle(
                                        color: (product.inStock ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: (product.inStock ?? false)
                                      ? () {
                                          context
                                              .read<CartProvider>()
                                              .addItem(product);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${product.name} added to cart'),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                                onTap: () {
                                  context.go('/product/${product.id}');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Pagination
              if (_totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                      ),
                      Text('Page $_currentPage of $_totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}