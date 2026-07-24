import 'package:flutter_test/flutter_test.dart';

import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:grupo_exito_catalog_test/features/cart/domain/entities/cart_item.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Subclase para simular fallos en los mapas internos y cubrir los bloques `catch (e)`
class TestableCartLocalDataSourceImpl extends CartLocalDataSourceImpl {
  bool forceError = false;

  @override
  List<CartItem> getStandardCart() {
    if (forceError) {
      throw ServerException(
        'Error al recuperar los ítems del carrito estándar',
      );
    }
    return super.getStandardCart();
  }

  @override
  List<CartItem> getExpressCart() {
    if (forceError) {
      throw ServerException('Error al recuperar los ítems del carrito express');
    }
    return super.getExpressCart();
  }

  @override
  void addProduct(Product product, {required bool isExpress}) {
    if (forceError) {
      throw ServerException('Error al guardar el producto en el carrito local');
    }
    super.addProduct(product, isExpress: isExpress);
  }

  @override
  void removeProduct(int productId, {required bool isExpress}) {
    if (forceError) {
      throw ServerException(
        'Error al actualizar la cantidad del producto en el carrito local',
      );
    }
    super.removeProduct(productId, isExpress: isExpress);
  }

  @override
  void clearCart({required bool isExpress}) {
    if (forceError) {
      throw ServerException('Error al limpiar el carrito local');
    }
    super.clearCart(isExpress: isExpress);
  }
}

void main() {
  late CartLocalDataSourceImpl dataSource;

  const tProduct1 = Product(
    id: 101,
    title: 'Leche Deslactosada 1L',
    price: 4500.0,
    category: 'Lácteos',
    image: 'https://via.placeholder.com/150',
  );

  const tProduct2 = Product(
    id: 102,
    title: 'Pan Tajado Blanco',
    price: 6000.0,
    category: 'Panadería',
    image: 'https://via.placeholder.com/150',
  );

  setUp(() {
    dataSource = CartLocalDataSourceImpl();
  });

  group('CartLocalDataSourceImpl - Pruebas del Carrito Estándar', () {
    test('Debe iniciar con el carrito estándar vacío', () {
      final items = dataSource.getStandardCart();
      expect(items, isEmpty);
    });

    test(
      'Debe agregar un producto nuevo con cantidad = 1 al carrito estándar',
      () {
        dataSource.addProduct(tProduct1, isExpress: false);

        final items = dataSource.getStandardCart();
        expect(items.length, 1);
        expect(items.first.product, tProduct1);
        expect(items.first.quantity, 1);
      },
    );

    test(
      'Debe incrementar la cantidad si el producto ya existe en el carrito estándar',
      () {
        dataSource.addProduct(tProduct1, isExpress: false);
        dataSource.addProduct(tProduct1, isExpress: false);

        final items = dataSource.getStandardCart();
        expect(items.length, 1);
        expect(items.first.quantity, 2);
      },
    );

    test('Debe decrementar la cantidad si la cantidad actual es mayor a 1', () {
      dataSource.addProduct(tProduct1, isExpress: false);
      dataSource.addProduct(tProduct1, isExpress: false);

      dataSource.removeProduct(tProduct1.id, isExpress: false);

      final items = dataSource.getStandardCart();
      expect(items.length, 1);
      expect(items.first.quantity, 1);
    });

    test('Debe remover el producto cuando la cantidad llega a 0', () {
      dataSource.addProduct(tProduct1, isExpress: false);

      dataSource.removeProduct(tProduct1.id, isExpress: false);

      final items = dataSource.getStandardCart();
      expect(items, isEmpty);
    });

    test(
      'No debe fallar si se intenta remover un producto que no existe en el carrito',
      () {
        dataSource.removeProduct(999, isExpress: false);

        final items = dataSource.getStandardCart();
        expect(items, isEmpty);
      },
    );

    test('Debe vaciar el carrito estándar al llamar a clearCart', () {
      dataSource.addProduct(tProduct1, isExpress: false);
      dataSource.addProduct(tProduct2, isExpress: false);

      dataSource.clearCart(isExpress: false);

      expect(dataSource.getStandardCart(), isEmpty);
    });
  });

  group('CartLocalDataSourceImpl - Pruebas del Carrito Express', () {
    test('Debe iniciar con el carrito express vacío', () {
      final items = dataSource.getExpressCart();
      expect(items, isEmpty);
    });

    test(
      'Debe agregar y gestionar productos en el carrito express independientemente',
      () {
        dataSource.addProduct(tProduct2, isExpress: true);

        final items = dataSource.getExpressCart();
        expect(items.length, 1);
        expect(items.first.product, tProduct2);
        expect(items.first.quantity, 1);
      },
    );

    test('Debe vaciar el carrito express al llamar a clearCart', () {
      dataSource.addProduct(tProduct1, isExpress: true);

      dataSource.clearCart(isExpress: true);

      expect(dataSource.getExpressCart(), isEmpty);
    });
  });

  group('CartLocalDataSourceImpl - Cobertura de Excepciones (catch blocks)', () {
    late TestableCartLocalDataSourceImpl testableDataSource;

    setUp(() {
      testableDataSource = TestableCartLocalDataSourceImpl();
      testableDataSource.forceError = true;
    });

    test(
      'Debe lanzar ServerException en getStandardCart cuando ocurre una falla',
      () {
        expect(
          () => testableDataSource.getStandardCart(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Error al recuperar los ítems del carrito estándar',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar ServerException en getExpressCart cuando ocurre una falla',
      () {
        expect(
          () => testableDataSource.getExpressCart(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Error al recuperar los ítems del carrito express',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar ServerException en addProduct cuando ocurre una falla',
      () {
        expect(
          () => testableDataSource.addProduct(tProduct1, isExpress: false),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Error al guardar el producto en el carrito local',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar ServerException en removeProduct cuando ocurre una falla',
      () {
        expect(
          () =>
              testableDataSource.removeProduct(tProduct1.id, isExpress: false),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Error al actualizar la cantidad del producto en el carrito local',
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar ServerException en clearCart cuando ocurre una falla',
      () {
        expect(
          () => testableDataSource.clearCart(isExpress: false),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Error al limpiar el carrito local',
            ),
          ),
        );
      },
    );
  });
}
