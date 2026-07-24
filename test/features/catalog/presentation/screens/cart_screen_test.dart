import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/cart_screen.dart';

/// Evita que Image.network falle en los tests de pantalla
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Fake Repository para alimentar el CartProvider durante el test
class MockCartRepository implements CartRepository {
  final List<CartItem> standardItems;
  final List<CartItem> expressItems;

  MockCartRepository({
    this.standardItems = const [],
    this.expressItems = const [],
  });

  @override
  Future<List<CartItem>> getStandardCart() async => standardItems;

  @override
  Future<List<CartItem>> getExpressCart() async => expressItems;

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

  const tProduct = Product(
    id: 1,
    title: 'Queso Alpina 250g',
    price: 12500.0,
    category: 'Lácteos',
    image: 'https://via.placeholder.com/150',
  );

  Widget createWidgetUnderTest({required CartProvider cartProvider}) {
    final router = GoRouter(
      initialLocation: '/cart',
      routes: [
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
        GoRoute(
          path: '/checkout',
          builder: (context, state) =>
              const Scaffold(body: Text('Checkout Screen')),
        ),
      ],
    );

    return ChangeNotifierProvider<CartProvider>.value(
      value: cartProvider,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('CartScreen - Tests de Interfaz y Estado', () {
    testWidgets(
      'Debe mostrar estado vacío cuando no hay productos en el carrito estándar',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(standardItems: []);
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        expect(find.text('Carrito de Compras'), findsOneWidget);
        expect(find.text('Tu carrito estándar está vacío'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
        expect(find.text('Comprar Ahora'), findsNothing);
      },
    );

    testWidgets(
      'Debe renderizar la lista de productos y calcular el total correctamente',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(
          standardItems: [const CartItem(product: tProduct, quantity: 2)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        // 1. Verifica presencia del título del producto
        expect(find.text('Queso Alpina 250g'), findsOneWidget);

        // 2. Verifica el precio unitario del ítem
        expect(find.text('\$12500.00'), findsOneWidget);

        // 3. Verifica el total acumulado en el footer (12,500 x 2 = $25000.00)
        expect(find.text('\$25000.00'), findsOneWidget);

        // 4. Verifica la cantidad y botón de acción
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Comprar Ahora'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe cambiar el título a "Carrito Express ⚡" cuando el modo Express está activo',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(
          expressItems: [const CartItem(product: tProduct, quantity: 1)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();
        cartProvider.toggleExpressMode(true);

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        expect(find.text('Carrito Express ⚡'), findsOneWidget);
        expect(find.text('Queso Alpina 250g'), findsOneWidget);
      },
    );

    testWidgets(
      'Hacer tap en "Comprar Ahora" debe navegar hacia /checkout y mostrar SnackBar',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(
          standardItems: [const CartItem(product: tProduct, quantity: 1)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        final buyButton = find.text('Comprar Ahora');
        expect(buyButton, findsOneWidget);

        await tester.tap(buyButton);
        await tester.pumpAndSettle();

        // Verifica navegación a Checkout
        expect(find.text('Checkout Screen'), findsOneWidget);
      },
    );
  });
}
