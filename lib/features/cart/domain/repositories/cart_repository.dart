import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Contrato abstracto para la gestión de carritos de compra (Estándar y Express).
abstract class CartRepository {
  /// Obtiene los ítems guardados del carrito estándar.
  Future<List<CartItem>> getStandardCart();

  /// Obtiene los ítems guardados del carrito express.
  Future<List<CartItem>> getExpressCart();

  /// Agrega o incrementa la cantidad de un producto en el carrito correspondiente.
  Future<void> addProduct(Product product, {required bool isExpress});

  /// Remueve o decrementa la cantidad de un producto del carrito correspondiente.
  Future<void> removeProduct(int productId, {required bool isExpress});

  /// Limpia por completo el carrito especificado.
  Future<void> clearCart({required bool isExpress});
}
