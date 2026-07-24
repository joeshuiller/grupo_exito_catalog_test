import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grupo_exito_catalog_test/core/errors/failures.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/repositories/cart_repository.dart';
import 'package:grupo_exito_catalog_test/features/cart/presentation/providers/cart_provider.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Fake/Mock manual de CartRepository para simular la persistencia de ambos carritos.
class MockCartRepository implements CartRepository {
  bool shouldThrowFailure = false;

  final List<CartItem> _standardCart = [];
  final List<CartItem> _expressCart = [];

  @override
  Future<List<CartItem>> getStandardCart() async {
    _checkFailure();
    return List.from(_standardCart);
  }

  @override
  Future<List<CartItem>> getExpressCart() async {
    _checkFailure();
    return List.from(_expressCart);
  }

  @override
  Future<void> addProduct(Product product, {required bool isExpress}) async {
    _checkFailure();
    final target = isExpress ? _expressCart : _standardCart;
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
    _checkFailure();
    final target = isExpress ? _expressCart : _standardCart;
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
    _checkFailure();
    if (isExpress) {
      _expressCart.clear();
    } else {
      _standardCart.clear();
    }
  }

  void _checkFailure() {
    if (shouldThrowFailure) {
      throw const CacheFailure('Fallo simulado en el repositorio');
    }
  }
}

void main() {
  late CartProvider provider;
  late MockCartRepository mockRepository;

  const tProduct1 = Product(
    id: 1,
    title: 'Manzana Gala 1kg',
    price: 6500.0,
    category: 'Frutas',
    image: 'https://via.placeholder.com/150',
  );

  const tProduct2 = Product(
    id: 2,
    title: 'Queso Doble Crema',
    price: 12000.0,
    category: 'Lácteos',
    image: 'https://via.placeholder.com/150',
  );

  setUp(() {
    mockRepository = MockCartRepository();
    provider = CartProvider(cartRepository: mockRepository);
  });

  group('CartProvider - Estados Iniciales y Propiedades', () {
    test('Estado inicial correcto', () {
      expect(provider.isExpressActive, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.activeCartItems, isEmpty);
      expect(provider.totalActiveUnits, 0);
      expect(provider.cartBadgeColor, const Color(0xFFFFDE00));
    });

    test(
      'canShowExpressOption debe retornar true dentro del rango 10 AM - 4 PM',
      () {
        final validTime = DateTime(2026, 7, 24, 11, 30);
        expect(provider.canShowExpressOption(validTime), isTrue);
      },
    );

    test(
      'canShowExpressOption debe retornar false fuera del rango 10 AM - 4 PM',
      () {
        final invalidTime = DateTime(2026, 7, 24, 8, 0);
        expect(provider.canShowExpressOption(invalidTime), isFalse);
      },
    );

    test(
      'toggleExpressMode debe alternar el estado y actualizar el color distintivo',
      () {
        provider.toggleExpressMode(true);

        expect(provider.isExpressActive, isTrue);
        expect(provider.cartBadgeColor, Colors.deepOrange);

        provider.toggleExpressMode(false);

        expect(provider.isExpressActive, isFalse);
        expect(provider.cartBadgeColor, const Color(0xFFFFDE00));
      },
    );
  });

  group('CartProvider - Operaciones de Carga y Modificación', () {
    test('loadCarts debe cargar ambos carritos desde el repositorio', () async {
      await mockRepository.addProduct(tProduct1, isExpress: false);
      await mockRepository.addProduct(tProduct2, isExpress: true);

      await provider.loadCarts();

      expect(provider.activeCartItems.length, 1);
      expect(provider.activeCartItems.first.product, tProduct1);

      provider.toggleExpressMode(true);
      expect(provider.activeCartItems.length, 1);
      expect(provider.activeCartItems.first.product, tProduct2);
    });

    test(
      'addProduct debe agregar productos al carrito correspondiente según el modo Express',
      () async {
        // Modo Estándar activo
        await provider.addProduct(tProduct1);

        expect(provider.activeCartItems.length, 1);
        expect(provider.totalActiveUnits, 1);
        expect(provider.getProductQuantity(tProduct1.id), 1);

        // Cambiamos a modo Express
        provider.toggleExpressMode(true);
        expect(provider.activeCartItems, isEmpty);

        // Agregamos al Express
        await provider.addProduct(tProduct2);
        expect(provider.activeCartItems.length, 1);
        expect(provider.getProductQuantity(tProduct2.id), 1);

        // Regresamos a Estándar y verificamos que se conserve su contenido
        provider.toggleExpressMode(false);
        expect(provider.activeCartItems.length, 1);
        expect(provider.getProductQuantity(tProduct1.id), 1);
      },
    );

    test(
      'removeProduct debe decrementar o eliminar el producto en el carrito activo',
      () async {
        await provider.addProduct(tProduct1);
        await provider.addProduct(tProduct1); // Cantidad: 2

        expect(provider.getProductQuantity(tProduct1.id), 2);

        await provider.removeProduct(tProduct1.id);
        expect(provider.getProductQuantity(tProduct1.id), 1);

        await provider.removeProduct(tProduct1.id);
        expect(provider.getProductQuantity(tProduct1.id), 0);
        expect(provider.activeCartItems, isEmpty);
      },
    );

    test('clearCart debe vaciar únicamente el carrito activo actual', () async {
      // Agregamos ítem en Estándar
      await provider.addProduct(tProduct1);

      // Agregamos ítem en Express
      provider.toggleExpressMode(true);
      await provider.addProduct(tProduct2);

      // Limpiamos Express
      await provider.clearCart();
      expect(provider.activeCartItems, isEmpty);

      // Verificamos que Estándar conserve su contenido intacto
      provider.toggleExpressMode(false);
      expect(provider.activeCartItems.length, 1);
      expect(provider.activeCartItems.first.product, tProduct1);
    });
  });

  group('CartProvider - Manejo de Excepciones', () {
    test('loadCarts debe capturar errores y establecer errorMessage', () async {
      mockRepository.shouldThrowFailure = true;

      await provider.loadCarts();

      expect(
        provider.errorMessage,
        contains('Fallo simulado en el repositorio'),
      );
    });

    test(
      'addProduct debe capturar errores y establecer errorMessage',
      () async {
        mockRepository.shouldThrowFailure = true;

        await provider.addProduct(tProduct1);

        expect(
          provider.errorMessage,
          contains('Fallo simulado en el repositorio'),
        );
      },
    );

    test(
      'removeProduct debe capturar errores y establecer errorMessage',
      () async {
        mockRepository.shouldThrowFailure = true;

        await provider.removeProduct(tProduct1.id);

        expect(
          provider.errorMessage,
          contains('Fallo simulado en el repositorio'),
        );
      },
    );

    test('clearCart debe capturar errores y establecer errorMessage', () async {
      mockRepository.shouldThrowFailure = true;

      await provider.clearCart();

      expect(
        provider.errorMessage,
        contains('Fallo simulado en el repositorio'),
      );
    });
  });
}
