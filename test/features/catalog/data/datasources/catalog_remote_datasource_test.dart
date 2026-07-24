import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/core/network/http_client.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/models/product_model.dart';
import 'package:http/http.dart' as http;

/// Client de HTTP simulado para controlar las respuestas en los tests.
class MockHttpClient extends HttpClient {
  Future<http.Response> Function(String url)? mockGet;

  @override
  Future<http.Response> get(String url) async {
    if (mockGet != null) {
      return await mockGet!(url);
    }
    return http.Response('[]', 200);
  }
}

void main() {
  late CatalogRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = CatalogRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getCategories', () {
    const tCategoriesJson = '["electronics", "jewelery", "men\'s clothing"]';

    test(
      'Debe retornar una lista de String cuando el servidor responde con código 200',
      () async {
        // Arrange
        mockHttpClient.mockGet = (_) async =>
            http.Response(tCategoriesJson, 200);

        // Act
        final result = await dataSource.getCategories();

        // Assert
        expect(result, equals(['electronics', 'jewelery', 'men\'s clothing']));
      },
    );

    test(
      'Debe lanzar ServerException cuando el servidor responda con código 404 o 500',
      () async {
        // Arrange
        mockHttpClient.mockGet = (_) async => http.Response('Not Found', 404);

        // Act & Assert
        expect(
          () async => await dataSource.getCategories(),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test(
      'Debe re-lanzar NetworkException cuando falle la conexión de red',
      () async {
        // Arrange
        mockHttpClient.mockGet = (_) async =>
            throw NetworkException('Error de conexión');

        // Act & Assert
        expect(
          () async => await dataSource.getCategories(),
          throwsA(isA<NetworkException>()),
        );
      },
    );
  });

  group('getProductsByCategory', () {
    const tCategory = 'electronics';
    const tProductsJson = '''
    [
      {
        "id": 1,
        "title": "Fjallraven - Foldsack No. 1 Backpack",
        "price": 109.95,
        "category": "electronics",
        "image": "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg"
      }
    ]
    ''';

    test(
      'Debe retornar una lista de ProductModel cuando la respuesta sea exitosa (200)',
      () async {
        // Arrange
        mockHttpClient.mockGet = (_) async => http.Response(tProductsJson, 200);

        // Act
        final result = await dataSource.getProductsByCategory(tCategory);

        // Assert
        expect(result, isA<List<ProductModel>>());
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.title, 'Fjallraven - Foldsack No. 1 Backpack');
        expect(result.first.price, 109.95);
      },
    );

    test(
      'Debe lanzar ServerException cuando el endpoint de productos responda con error',
      () async {
        // Arrange
        mockHttpClient.mockGet = (_) async =>
            http.Response('Internal Server Error', 500);

        // Act & Assert
        expect(
          () async => await dataSource.getProductsByCategory(tCategory),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
