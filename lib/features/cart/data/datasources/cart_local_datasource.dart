import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Contrato abstracto para la fuente de datos local del carrito.
abstract class CartLocalDataSource {
  List<CartItem> getStandardCart();
  List<CartItem> getExpressCart();
  void addProduct(Product product, {required bool isExpress});
  void removeProduct(int productId, {required bool isExpress});
  void clearCart({required bool isExpress});
}

/// Implementación en memoria del DataSource local para la gestión dual de carritos.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Map<int, CartItem> _standardCartMap = {};
  final Map<int, CartItem> _expressCartMap = {};

  Map<int, CartItem> _getCartMap(bool isExpress) {
    return isExpress ? _expressCartMap : _standardCartMap;
  }

  @override
  List<CartItem> getStandardCart() {
    try {
      return _standardCartMap.values.toList();
    } catch (e) {
      throw ServerException(
        'Error al recuperar los ítems del carrito estándar',
      );
    }
  }

  @override
  List<CartItem> getExpressCart() {
    try {
      return _expressCartMap.values.toList();
    } catch (e) {
      throw ServerException('Error al recuperar los ítems del carrito express');
    }
  }

  @override
  void addProduct(Product product, {required bool isExpress}) {
    try {
      final cartMap = _getCartMap(isExpress);
      if (cartMap.containsKey(product.id)) {
        final currentItem = cartMap[product.id]!;
        cartMap[product.id] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );
      } else {
        cartMap[product.id] = CartItem(product: product, quantity: 1);
      }
    } catch (e) {
      throw ServerException('Error al guardar el producto en el carrito local');
    }
  }

  @override
  void removeProduct(int productId, {required bool isExpress}) {
    try {
      final cartMap = _getCartMap(isExpress);
      if (!cartMap.containsKey(productId)) return;

      final currentItem = cartMap[productId]!;
      if (currentItem.quantity > 1) {
        cartMap[productId] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
      } else {
        cartMap.remove(productId);
      }
    } catch (e) {
      throw ServerException(
        'Error al actualizar la cantidad del producto en el carrito local',
      );
    }
  }

  @override
  void clearCart({required bool isExpress}) {
    try {
      _getCartMap(isExpress).clear();
    } catch (e) {
      throw ServerException('Error al limpiar el carrito local');
    }
  }
}
