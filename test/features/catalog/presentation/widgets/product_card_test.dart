import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/product_card.dart';

/// Evita que Image.network falle en los tests de Flutter
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Fake Repository dinámico para respaldar las operaciones del CartProvider en los tests
class MockCartRepository implements CartRepository {
  final List<CartItem> _standardItems = [];
  final List<CartItem> _expressItems = [];

  MockCartRepository({
    List<CartItem> initialStandardItems = const [],
    List<CartItem> initialExpressItems = const [],
  }) {
    _standardItems.addAll(initialStandardItems);
    _expressItems.addAll(initialExpressItems);
  }

  @override
  Future<List<CartItem>> getStandardCart() async => List.from(_standardItems);

  @override
  Future<List<CartItem>> getExpressCart() async => List.from(_expressItems);

  @override
  Future<void> addProduct(Product product, {required bool isExpress}) async {
    final target = isExpress ? _expressItems : _standardItems;
    final index = target.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      target[index] = target[index].copyWith(
        quantity: target[index].quantity + 1,
      );
    } else {
      target.add(CartItem(product: product, quantity: 1));
    }
  }

  @override
  Future<void> removeProduct(int productId, {required bool isExpress}) async {
    final target = isExpress ? _expressItems : _standardItems;
    final index = target.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (target[index].quantity > 1) {
        target[index] = target[index].copyWith(
          quantity: target[index].quantity - 1,
        );
      } else {
        target.removeAt(index);
      }
    }
  }

  @override
  Future<void> clearCart({required bool isExpress}) async {
    if (isExpress) {
      _expressItems.clear();
    } else {
      _standardItems.clear();
    }
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  const tProduct = Product(
    id: 1,
    title: 'Arroz Roa 1kg',
    price: 4200.0,
    category: 'Abarrotes',
    image: 'https://via.placeholder.com/150',
  );

  Widget createWidgetUnderTest({required CartProvider cartProvider}) {
    return ChangeNotifierProvider<CartProvider>.value(
      value: cartProvider,
      child: const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 250,
            height: 350,
            child: ProductCard(product: tProduct),
          ),
        ),
      ),
    );
  }

  group('ProductCard - Widget Tests', () {
    testWidgets(
      'Debe mostrar información básica del producto y botón "Agregar" si cantidad es 0',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository();
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        expect(find.text('Arroz Roa 1kg'), findsOneWidget);
        expect(find.text('\$4200.00'), findsOneWidget);
        expect(find.text('Agregar'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsNothing);
      },
    );

    testWidgets(
      'Tocar "Agregar" debe invocar addProduct en CartProvider y actualizar la UI',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository();
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        final addBtn = find.text('Agregar');
        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        expect(cartProvider.getProductQuantity(tProduct.id), 1);
        expect(find.text('1 und'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar control de cantidad (- N und +) cuando el producto ya fue agregado',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(
          initialStandardItems: [
            const CartItem(product: tProduct, quantity: 3),
          ],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        expect(find.text('Agregar'), findsNothing);
        expect(find.text('3 und'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
      },
    );

    testWidgets(
      'Tocar el botón (+) e (-) debe incrementar y decrementar la cantidad',
      (WidgetTester tester) async {
        final mockRepo = MockCartRepository(
          initialStandardItems: [
            const CartItem(product: tProduct, quantity: 2),
          ],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        // Incrementa
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(cartProvider.getProductQuantity(tProduct.id), 3);
        expect(find.text('3 und'), findsOneWidget);

        // Decrementa
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pumpAndSettle();
        expect(cartProvider.getProductQuantity(tProduct.id), 2);
        expect(find.text('2 und'), findsOneWidget);
      },
    );
  });
}
