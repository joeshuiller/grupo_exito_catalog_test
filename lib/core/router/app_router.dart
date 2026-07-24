import 'package:go_router/go_router.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/cart_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/checkout_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/home_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/products_by_category_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/category/:categoryName',
      name: ProductsByCategoryScreen.routeName,
      builder: (context, state) {
        final categoryName =
            state.pathParameters['categoryName'] ?? 'Categoría';
        return ProductsByCategoryScreen(categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/cart',
      name: CartScreen.routeName,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      name: CheckoutScreen.routeName,
      builder: (context, state) => const CheckoutScreen(),
    ),
  ],
);
