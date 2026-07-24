import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/widgets/express_switcher.dart';

class DummyCartRepository implements CartRepository {
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
  testWidgets(
    'ExpressSwitcher debe renderizar el texto y cambiar el switch al interactuar',
    (WidgetTester tester) async {
      final cartProvider = CartProvider(cartRepository: DummyCartRepository());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<CartProvider>.value(
              value: cartProvider,
              child: const ExpressSwitcher(),
            ),
          ),
        ),
      );

      // Verificamos que el widget con el texto exista
      expect(find.text('Activar la experiencia express'), findsOneWidget);

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Inicialmente el switch debe estar apagado
      Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, isFalse);

      // Hacemos tap sobre el Switcher
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verificamos que el estado del Provider haya cambiado
      expect(cartProvider.isExpressActive, isTrue);
    },
  );
}
