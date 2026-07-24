import 'package:flutter/material.dart';
import 'package:grupo_exito_catalog_test/core/utils/time_utils.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository cartRepository;

  CartProvider({required this.cartRepository});

  bool _isExpressActive = false;
  List<CartItem> _standardCartItems = [];
  List<CartItem> _expressCartItems = [];
  String? _errorMessage;

  bool get isExpressActive => _isExpressActive;
  String? get errorMessage => _errorMessage;

  /// Retorna si el switcher express puede mostrarse según el horario actual (10 AM - 4 PM)[cite: 1]
  bool canShowExpressOption([DateTime? overrideTime]) {
    final now = overrideTime ?? DateTime.now();
    return TimeUtils.isExpressAvailable(now);
  }

  void toggleExpressMode(bool value) {
    _isExpressActive = value;
    notifyListeners();
  }

  /// Retorna la lista de ítems del carrito activo
  List<CartItem> get activeCartItems =>
      _isExpressActive ? _expressCartItems : _standardCartItems;

  /// Retorna el número total de unidades en el carrito activo
  int get totalActiveUnits =>
      activeCartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Color distintivo para el carrito Express vs Estándar[cite: 1]
  Color get cartBadgeColor =>
      _isExpressActive ? Colors.deepOrange : const Color(0xFFFFDE00);

  int getProductQuantity(int productId) {
    final item = activeCartItems.cast<CartItem?>().firstWhere(
      (element) => element?.product.id == productId,
      orElse: () => null,
    );
    return item?.quantity ?? 0;
  }

  Future<void> loadCarts() async {
    try {
      _standardCartItems = await cartRepository.getStandardCart();
      _expressCartItems = await cartRepository.getExpressCart();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await cartRepository.addProduct(product, isExpress: _isExpressActive);
      if (_isExpressActive) {
        _expressCartItems = await cartRepository.getExpressCart();
      } else {
        _standardCartItems = await cartRepository.getStandardCart();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeProduct(int productId) async {
    try {
      await cartRepository.removeProduct(
        productId,
        isExpress: _isExpressActive,
      );
      if (_isExpressActive) {
        _expressCartItems = await cartRepository.getExpressCart();
      } else {
        _standardCartItems = await cartRepository.getStandardCart();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await cartRepository.clearCart(isExpress: _isExpressActive);
      if (_isExpressActive) {
        _expressCartItems = await cartRepository.getExpressCart();
      } else {
        _standardCartItems = await cartRepository.getStandardCart();
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
