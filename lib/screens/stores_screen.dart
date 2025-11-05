import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/store.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _searchController = TextEditingController();
  List<Store> _filteredStores = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStores(String query, List<Store> stores) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = stores;
      } else {
        _filteredStores = stores
            .where((store) =>
                store.name.toLowerCase().contains(query.toLowerCase()) ||
                store.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          if (storeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (storeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${storeProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => storeProvider.fetchStores(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stores = storeProvider.stores;
          if (_filteredStores.isEmpty && _searchController.text.isEmpty) {
            _filteredStores = stores;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search stores...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) => _filterStores(query, stores),
                ),
              ),
              Expanded(
                child: _filteredStores.isEmpty
                    ? const Center(child: Text('No stores found'))
                    : AnimatedList(
                        initialItemCount: _filteredStores.length,
                        itemBuilder: (context, index, animation) {
                          final store = _filteredStores[index];
                          return FadeTransition(
                            opacity: animation,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ListTile(
                                leading: Image.network(
                                  store.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(store.name),
                                subtitle: Text(store.description),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  context.go('/store/${store.id}');
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}