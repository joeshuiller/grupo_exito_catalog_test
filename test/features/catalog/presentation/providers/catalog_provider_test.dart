import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:provider/provider.dart';

import 'package:grupo_exito_catalog_test/core/router/app_router.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';

// --- REPOSITORIOS SIMULADOS PARA EL TEST ---
class DummyCatalogRepository implements CatalogRepository {
  @override
  Future<List<String>> getCategories() async => ['lacteos', 'frutas'];

  @override
  Future<List<Product>> getProductsByCategory(String category) async => [];
}

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
  testWidgets('Carga exitosa de HomeScreen con Providers', (
    WidgetTester tester,
  ) async {
    final catalogRepository = DummyCatalogRepository();
    final cartRepository = DummyCartRepository();

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );

    // Espera a que finalicen las llamadas asíncronas iniciales
    await tester.pumpAndSettle();

    // Verificamos que la UI de la pantalla principal haya renderizado sus textos
    expect(find.text('Ecommerce App'), findsOneWidget);
    expect(find.text('¿Cómo quieres recibir tu pedido?'), findsOneWidget);
  });
}
