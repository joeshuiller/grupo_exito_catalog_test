import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/core/errors/failures.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/products_by_category_screen.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/product_card.dart';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MockCatalogRepository implements CatalogRepository {
  List<Product> productsToReturn = [];
  bool shouldThrow = false;
  bool delayResponse = false;

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    if (delayResponse) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    if (shouldThrow) throw const ServerFailure('Error al cargar productos');
    return productsToReturn;
  }
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
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  late MockCatalogRepository catalogRepository;
  late MockCartRepository cartRepository;

  const tCategory = 'electronics';

  const tProduct1 = Product(
    id: 1,
    title: 'Televisor Samsung 55"',
    price: 2100000.0,
    category: 'electronics',
    image: 'https://via.placeholder.com/150',
  );

  const tProduct2 = Product(
    id: 2,
    title: 'Audífonos Sony WH-1000XM4',
    price: 1100000.0,
    category: 'electronics',
    image: 'https://via.placeholder.com/150',
  );

  setUp(() {
    catalogRepository = MockCatalogRepository();
    cartRepository = MockCartRepository();
  });

  Widget createWidgetUnderTest({
    required CatalogProvider catalogProvider,
    required CartProvider cartProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CatalogProvider>.value(value: catalogProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ],
      child: const MaterialApp(
        home: ProductsByCategoryScreen(categoryName: tCategory),
      ),
    );
  }

  group('ProductsByCategoryScreen - Pruebas de Estados de UI', () {
    testWidgets(
      'Debe mostrar CircularProgressIndicator mientras se realiza la carga',
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

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('ELECTRONICS'), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Debe renderizar la grilla con los ProductCard cuando se obtienen productos exitosamente',
      (WidgetTester tester) async {
        catalogRepository.productsToReturn = [tProduct1, tProduct2];

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

        expect(find.text('ELECTRONICS'), findsOneWidget);
        expect(find.byType(ProductCard), findsNWidgets(2));
        expect(find.text('Televisor Samsung 55"'), findsOneWidget);
        expect(find.text('Audífonos Sony WH-1000XM4'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar el mensaje de error cuando falla la petición de productos',
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

        // Busca cualquier elemento de texto visible que contenga la palabra Error
        expect(find.textContaining('Error'), findsOneWidget);
      },
    );

    testWidgets('Debe adoptar el color dinámico del carrito en el AppBar', (
      WidgetTester tester,
    ) async {
      catalogRepository.productsToReturn = [tProduct1];

      final catalogProvider = CatalogProvider(
        getCategoriesUseCase: GetCategories(catalogRepository),
        getProductsByCategoryUseCase: GetProductsByCategory(catalogRepository),
      );
      final cartProvider = CartProvider(cartRepository: cartRepository);
      cartProvider.toggleExpressMode(true);

      await tester.pumpWidget(
        createWidgetUnderTest(
          catalogProvider: catalogProvider,
          cartProvider: cartProvider,
        ),
      );

      await tester.pumpAndSettle();

      final appBarWidget = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBarWidget.backgroundColor, Colors.deepOrange);
    });
  });
}
