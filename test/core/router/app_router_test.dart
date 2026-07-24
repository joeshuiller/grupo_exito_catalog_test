import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/cart_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/checkout_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/home_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/products_by_category_screen.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/core/router/app_router.dart';

// Mocks simples para alimentar los proveedores durante la navegación
class DummyCatalogRepository implements CatalogRepository {
  @override
  Future<List<String>> getCategories() async => ['electronics'];

  @override
  Future<List<Product>> getProductsByCategory(String category) async => [];
}

class DummyCartRepository implements CatalogRepository, CartRepository {
  @override
  Future<List<CartItem>> getStandardCart() async => [];
  @override
  Future<List<CartItem>> getExpressCart() async => [];
  @override
  Future<void> addProduct(Product product, {required bool isExpress}) async {}
  @override
  Future<void> removeProduct(int productId, {required bool isExpress}) async {}
  @override
  Future<void> clearCart({required bool isExpress}) async {}

  @override
  Future<List<String>> getCategories() async => [];
  @override
  Future<List<Product>> getProductsByCategory(String category) async => [];
}

void main() {
  late CatalogRepository catalogRepository;
  late CartRepository cartRepository;

  setUp(() {
    catalogRepository = DummyCatalogRepository();
    cartRepository = DummyCartRepository();
  });

  Widget buildTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(
            getCategoriesUseCase: GetCategories(catalogRepository),
            getProductsByCategoryUseCase: GetProductsByCategory(
              catalogRepository,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartRepository: cartRepository),
        ),
      ],
      child: MaterialApp.router(routerConfig: appRouter),
    );
  }

  group('GoRouter Configuration Tests', () {
    testWidgets('La ruta inicial "/" debe renderizar la pantalla HomeScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
      'Navegar a "/category/electronics" debe renderizar ProductsByCategoryScreen',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Forzamos la navegación declarativa
        appRouter.go('/category/electronics');
        await tester.pumpAndSettle();

        expect(find.byType(ProductsByCategoryScreen), findsOneWidget);
        expect(find.text('ELECTRONICS'), findsOneWidget);
      },
    );

    testWidgets('Navegar a "/cart" debe renderizar CartScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      appRouter.go('/cart');
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);
    });

    testWidgets('Navegar a "/checkout" debe renderizar CheckoutScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      appRouter.go('/checkout');
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutScreen), findsOneWidget);
    });
  });
}
