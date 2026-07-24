import 'package:flutter_test/flutter_test.dart';

import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/core/errors/failures.dart';
import 'package:grupo_exito_catalog_test/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:grupo_exito_catalog_test/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Fake / Mock manual de CartLocalDataSource para simular retornos y excepciones controladas.
class MockCartLocalDataSource implements CartLocalDataSource {
  bool throwServerException = false;
  bool throwGenericException = false;

  final List<CartItem> _standardCart = [];
  final List<CartItem> _expressCart = [];

  @override
  List<CartItem> getStandardCart() {
    _checkExceptions('Error en datasource estándar');
    return _standardCart;
  }

  @override
  List<CartItem> getExpressCart() {
    _checkExceptions('Error en datasource express');
    return _expressCart;
  }

  @override
  void addProduct(Product product, {required bool isExpress}) {
    _checkExceptions('Error al agregar en datasource');
    final target = isExpress ? _expressCart : _standardCart;
    target.add(CartItem(product: product, quantity: 1));
  }

  @override
  void removeProduct(int productId, {required bool isExpress}) {
    _checkExceptions('Error al remover en datasource');
    final target = isExpress ? _expressCart : _standardCart;
    target.removeWhere((item) => item.product.id == productId);
  }

  @override
  void clearCart({required bool isExpress}) {
    _checkExceptions('Error al vaciar en datasource');
    if (isExpress) {
      _expressCart.clear();
    } else {
      _standardCart.clear();
    }
  }

  void _checkExceptions(String serverMessage) {
    if (throwServerException) {
      throw ServerException(serverMessage);
    }
    if (throwGenericException) {
      throw Exception('Uncaught error');
    }
  }
}

void main() {
  late CartRepositoryImpl repository;
  late MockCartLocalDataSource mockLocalDataSource;

  const tProduct = Product(
    id: 1,
    title: 'Arroz Diana 1kg',
    price: 3800.0,
    category: 'Abarrotes',
    image: 'https://via.placeholder.com/150',
  );

  setUp(() {
    mockLocalDataSource = MockCartLocalDataSource();
    repository = CartRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('getStandardCart', () {
    test(
      'Debe retornar la lista de ítems del carrito estándar si la llamada es exitosa',
      () async {
        final result = await repository.getStandardCart();

        expect(result, isA<List<CartItem>>());
        expect(result, isEmpty);
      },
    );

    test(
      'Debe transformar ServerException a CacheFailure con el mensaje de la excepción',
      () async {
        mockLocalDataSource.throwServerException = true;

        expect(
          () async => await repository.getStandardCart(),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error en datasource estándar',
            ),
          ),
        );
      },
    );

    test(
      'Debe transformar cualquier error no controlado a CacheFailure genérico',
      () async {
        mockLocalDataSource.throwGenericException = true;

        expect(
          () async => await repository.getStandardCart(),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error inesperado al cargar el carrito estándar',
            ),
          ),
        );
      },
    );
  });

  group('getExpressCart', () {
    test(
      'Debe retornar la lista de ítems del carrito express si la llamada es exitosa',
      () async {
        final result = await repository.getExpressCart();

        expect(result, isA<List<CartItem>>());
        expect(result, isEmpty);
      },
    );

    test(
      'Debe transformar ServerException a CacheFailure en getExpressCart',
      () async {
        mockLocalDataSource.throwServerException = true;

        expect(
          () async => await repository.getExpressCart(),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error en datasource express',
            ),
          ),
        );
      },
    );

    test(
      'Debe transformar errores no controlados a CacheFailure genérico en getExpressCart',
      () async {
        mockLocalDataSource.throwGenericException = true;

        expect(
          () async => await repository.getExpressCart(),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error inesperado al cargar el carrito express',
            ),
          ),
        );
      },
    );
  });

  group('addProduct', () {
    test('Debe agregar el producto exitosamente al DataSource', () async {
      await repository.addProduct(tProduct, isExpress: false);

      final items = await repository.getStandardCart();
      expect(items.length, 1);
      expect(items.first.product, tProduct);
    });

    test(
      'Debe capturar ServerException y lanzar CacheFailure al agregar producto',
      () async {
        mockLocalDataSource.throwServerException = true;

        expect(
          () async => await repository.addProduct(tProduct, isExpress: false),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al agregar en datasource',
            ),
          ),
        );
      },
    );

    test(
      'Debe capturar errores genéricos y lanzar CacheFailure al agregar producto',
      () async {
        mockLocalDataSource.throwGenericException = true;

        expect(
          () async => await repository.addProduct(tProduct, isExpress: false),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al agregar el producto al carrito',
            ),
          ),
        );
      },
    );
  });

  group('removeProduct', () {
    test('Debe remover el producto exitosamente del DataSource', () async {
      await repository.addProduct(tProduct, isExpress: false);
      await repository.removeProduct(tProduct.id, isExpress: false);

      final items = await repository.getStandardCart();
      expect(items, isEmpty);
    });

    test(
      'Debe capturar ServerException y lanzar CacheFailure al remover producto',
      () async {
        mockLocalDataSource.throwServerException = true;

        expect(
          () async =>
              await repository.removeProduct(tProduct.id, isExpress: false),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al remover en datasource',
            ),
          ),
        );
      },
    );

    test(
      'Debe capturar errores genéricos y lanzar CacheFailure al remover producto',
      () async {
        mockLocalDataSource.throwGenericException = true;

        expect(
          () async =>
              await repository.removeProduct(tProduct.id, isExpress: false),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al remover el producto del carrito',
            ),
          ),
        );
      },
    );
  });

  group('clearCart', () {
    test('Debe vaciar el carrito especificado exitosamente', () async {
      await repository.addProduct(tProduct, isExpress: true);
      await repository.clearCart(isExpress: true);

      final items = await repository.getExpressCart();
      expect(items, isEmpty);
    });

    test(
      'Debe capturar ServerException y lanzar CacheFailure al vaciar carrito',
      () async {
        mockLocalDataSource.throwServerException = true;

        expect(
          () async => await repository.clearCart(isExpress: true),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al vaciar en datasource',
            ),
          ),
        );
      },
    );

    test(
      'Debe capturar errores genéricos y lanzar CacheFailure al vaciar carrito',
      () async {
        mockLocalDataSource.throwGenericException = true;

        expect(
          () async => await repository.clearCart(isExpress: true),
          throwsA(
            isA<CacheFailure>().having(
              (f) => f.message,
              'message',
              'Error al vaciar el carrito',
            ),
          ),
        );
      },
    );
  });
}
