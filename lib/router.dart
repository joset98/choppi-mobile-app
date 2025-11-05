import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/stores_screen.dart';
import 'screens/store_detail_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/stores',
          builder: (context, state) => const StoresScreen(),
        ),
        GoRoute(
          path: '/store/:id',
          builder: (context, state) {
            final storeId = int.parse(state.pathParameters['id']!);
            return StoreDetailScreen(storeId: storeId);
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final productId = int.parse(state.pathParameters['id']!);
            return ProductDetailScreen(productId: productId);
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }
        if (isLoggedIn && isLoginRoute) {
          return '/stores';
        }
        return null;
      },
    );
  }
}