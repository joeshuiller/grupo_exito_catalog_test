import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/home_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/category_card.dart';

class MockCatalogRepository implements CatalogRepository {
  List<String> categoriesToReturn = ['electronics', 'jewelery'];
  bool shouldThrow = false;
  bool delayResponse = false;

  @override
  Future<List<String>> getCategories() async {
    if (delayResponse) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (shouldThrow) throw Exception('Error al cargar categorías');
    return categoriesToReturn;
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async => [];
}

class MockCartRepository implements CartRepository {
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
}

void main() {
  late MockCatalogRepository catalogRepository;
  late MockCartRepository cartRepository;

  setUp(() {
    catalogRepository = MockCatalogRepository();
    cartRepository = MockCartRepository();
  });

  Widget createWidgetUnderTest({
    required CatalogProvider catalogProvider,
    required CartProvider cartProvider,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/cart',
          builder: (context, state) =>
              const Scaffold(body: Text('Cart Screen')),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CatalogProvider>.value(value: catalogProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('HomeScreen - Estados de Carga y Categorías', () {
    testWidgets(
      'Debe mostrar CircularProgressIndicator mientras isLoading es true',
      (WidgetTester tester) async {
        catalogRepository.delayResponse = true;

        final catalogProvider = CatalogProvider(
          getCategoriesUseCase: GetCategories(catalogRepository),
          getProductsByCategoryUseCase: GetProductsByCategory(
            catalogRepository,
          ),
        );
        final cartProvider = CartProvider(cartRepository: cartRepository);

        await tester.pumpWidget(
          createWidgetUnderTest(
            catalogProvider: catalogProvider,
            cartProvider: cartProvider,
          ),
        );

        await tester.pump(); // Renderiza estado inicial cargando

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle(); // Limpia temporizadores
      },
    );

    testWidgets(
      'Debe renderizar la grilla con las tarjetas de categorías al cargar exitosamente',
      (WidgetTester tester) async {
        final catalogProvider = CatalogProvider(
          getCategoriesUseCase: GetCategories(catalogRepository),
          getProductsByCategoryUseCase: GetProductsByCategory(
            catalogRepository,
          ),
        );
        final cartProvider = CartProvider(cartRepository: cartRepository);

        await tester.pumpWidget(
          createWidgetUnderTest(
            catalogProvider: catalogProvider,
            cartProvider: cartProvider,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Ecommerce App'), findsOneWidget);
        expect(find.text('¿Cómo quieres recibir tu pedido?'), findsOneWidget);
        expect(find.byType(CategoryCard), findsNWidgets(2));
        expect(find.text('ELECTRONICS'), findsOneWidget);
        expect(find.text('JEWELERY'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar mensaje de error y botón de reintentar si la carga falla',
      (WidgetTester tester) async {
        catalogRepository.shouldThrow = true;

        final catalogProvider = CatalogProvider(
          getCategoriesUseCase: GetCategories(catalogRepository),
          getProductsByCategoryUseCase: GetProductsByCategory(
            catalogRepository,
          ),
        );
        final cartProvider = CartProvider(cartRepository: cartRepository);

        await tester.pumpWidget(
          createWidgetUnderTest(
            catalogProvider: catalogProvider,
            cartProvider: cartProvider,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar mensaje descriptivo si la lista de categorías está vacía',
      (WidgetTester tester) async {
        catalogRepository.categoriesToReturn = [];

        final catalogProvider = CatalogProvider(
          getCategoriesUseCase: GetCategories(catalogRepository),
          getProductsByCategoryUseCase: GetProductsByCategory(
            catalogRepository,
          ),
        );
        final cartProvider = CartProvider(cartRepository: cartRepository);

        await tester.pumpWidget(
          createWidgetUnderTest(
            catalogProvider: catalogProvider,
            cartProvider: cartProvider,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('No hay categorías disponibles.'), findsOneWidget);
      },
    );
  });

  group('HomeScreen - Carrito y Navegación', () {
    testWidgets(
      'Tocar el badge del carrito en el AppBar debe navegar hacia /cart',
      (WidgetTester tester) async {
        final catalogProvider = CatalogProvider(
          getCategoriesUseCase: GetCategories(catalogRepository),
          getProductsByCategoryUseCase: GetProductsByCategory(
            catalogRepository,
          ),
        );
        final cartProvider = CartProvider(cartRepository: cartRepository);

        await tester.pumpWidget(
          createWidgetUnderTest(
            catalogProvider: catalogProvider,
            cartProvider: cartProvider,
          ),
        );

        await tester.pumpAndSettle();

        final cartChip = find.widgetWithText(Chip, '0 und');
        expect(cartChip, findsOneWidget);

        await tester.tap(cartChip);
        await tester.pumpAndSettle();

        expect(find.text('Cart Screen'), findsOneWidget);
      },
    );
  });
}
