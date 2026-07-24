import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/screens/checkout_screen.dart';

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
  const tProduct = Product(
    id: 10,
    title: 'Café Sello Rojo 500g',
    price: 15000.0,
    category: 'Despensa',
    image: 'https://via.placeholder.com/150',
  );

  Widget createWidgetUnderTest({required CartProvider cartProvider}) {
    final router = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
      ],
    );

    return ChangeNotifierProvider<CartProvider>.value(
      value: cartProvider,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('CheckoutScreen - Resumen de Pedido y Tarifas de Envío', () {
    testWidgets(
      'Debe calcular tarifa estándar (\$2500.00) y mostrar el total correcto',
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

        expect(find.text('Formulario de Pago'), findsOneWidget);
        expect(find.text('Envío Estándar:'), findsOneWidget);
        expect(find.text('\$2500.00'), findsOneWidget);
        expect(find.text('\$17500.00'), findsOneWidget);
        expect(find.text('Pagar \$17500.00'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe calcular tarifa express (\$5000.00) y actualizar título al estar activo Express',
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

        expect(find.text('Pago Express ⚡'), findsOneWidget);
        expect(find.text('Envío Express:'), findsOneWidget);
        expect(find.text('\$5000.00'), findsOneWidget);
        expect(find.text('\$20000.00'), findsOneWidget);
        expect(find.text('Pagar \$20000.00'), findsOneWidget);
      },
    );
  });

  group('CheckoutScreen - Validaciones de Formulario y Métodos de Pago', () {
    testWidgets(
      'Debe mostrar mensajes de error al intentar pagar con campos vacíos',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockCartRepository(
          standardItems: [const CartItem(product: tProduct, quantity: 1)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        final payButton = find.widgetWithText(
          ElevatedButton,
          'Pagar \$17500.00',
        );
        await tester.tap(payButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
        expect(find.text('Por favor ingresa la dirección'), findsOneWidget);
        expect(
          find.text('Ingresa un número de tarjeta válido (16 dígitos)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Ocultar campos de tarjeta y mostrar aviso al seleccionar pago en Efectivo',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockCartRepository(
          standardItems: [const CartItem(product: tProduct, quantity: 1)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        final cashChip = find.text('Efectivo');
        await tester.tap(cashChip);
        await tester.pumpAndSettle();

        expect(find.text('Número de Tarjeta'), findsNothing);
        expect(
          find.text(
            'Pagarás en efectivo al repartidor al momento de recibir tu pedido.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('CheckoutScreen - Flujo de Pago Completo', () {
    testWidgets(
      'Debe procesar el pago correctamente y redirigir al inicio tras la confirmación',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockCartRepository(
          standardItems: [const CartItem(product: tProduct, quantity: 1)],
        );
        final cartProvider = CartProvider(cartRepository: mockRepo);
        await cartProvider.loadCarts();

        await tester.pumpWidget(
          createWidgetUnderTest(cartProvider: cartProvider),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre Completo'),
          'Carlos Pérez',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Dirección de Entrega'),
          'Calle 100 # 15-20',
        );

        await tester.tap(find.text('Efectivo'));
        await tester.pumpAndSettle();

        final payButton = find.widgetWithText(
          ElevatedButton,
          'Pagar \$17500.00',
        );
        await tester.tap(payButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('¡Pago Exitoso!'), findsOneWidget);
        expect(
          find.text('Tu pedido ha sido procesado correctamente 📦'),
          findsOneWidget,
        );

        await tester.tap(find.text('Volver al Inicio'));
        await tester.pumpAndSettle();

        expect(find.text('Home Screen'), findsOneWidget);
      },
    );
  });
}
