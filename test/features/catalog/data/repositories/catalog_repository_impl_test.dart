import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/core/errors/failures.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/models/product_model.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

/// Mock manual del DataSource remoto para simular respuestas exitosas y con excepciones.
class MockCatalogRemoteDataSource implements CatalogRemoteDataSource {
  bool shouldThrowNetworkException = false;
  bool shouldThrowServerException = false;

  final List<String> _categories = [
    'electronics',
    'jewelery',
    'men\'s clothing',
  ];
  final List<ProductModel> _products = [
    const ProductModel(
      id: 1,
      title: 'Fjallraven Backpack',
      price: 109.95,
      category: 'men\'s clothing',
      image: 'https://via.placeholder.com/150',
    ),
  ];

  @override
  Future<List<String>> getCategories() async {
    if (shouldThrowNetworkException) {
      throw NetworkException('Sin conexión a internet');
    }
    if (shouldThrowServerException) {
      throw ServerException('Error en el servidor de FakeStore');
    }
    return _categories;
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    if (shouldThrowNetworkException) {
      throw NetworkException('Sin conexión a internet');
    }
    if (shouldThrowServerException) {
      throw ServerException('Error en el servidor de FakeStore');
    }
    return _products;
  }
}

void main() {
  late CatalogRepositoryImpl repository;
  late MockCatalogRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCatalogRemoteDataSource();
    repository = CatalogRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getCategories', () {
    test(
      'Debe retornar la lista de categorías cuando el RemoteDataSource responda con éxito',
      () async {
        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, 3);
        expect(result, equals(['electronics', 'jewelery', 'men\'s clothing']));
      },
    );

    test(
      'Debe lanzar NetworkFailure cuando el RemoteDataSource arroje NetworkException',
      () async {
        // Arrange
        mockRemoteDataSource.shouldThrowNetworkException = true;

        // Act & Assert
        expect(
          () async => await repository.getCategories(),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );

    test(
      'Debe lanzar ServerFailure cuando el RemoteDataSource arroje ServerException',
      () async {
        // Arrange
        mockRemoteDataSource.shouldThrowServerException = true;

        // Act & Assert
        expect(
          () async => await repository.getCategories(),
          throwsA(isA<ServerFailure>()),
        );
      },
    );
  });

  group('getProductsByCategory', () {
    const tCategory = 'men\'s clothing';

    test(
      'Debe retornar la lista de entidades Product cuando la respuesta sea exitosa',
      () async {
        // Act
        final result = await repository.getProductsByCategory(tCategory);

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, 1);
        expect(result.first.id, 1);
        expect(result.first.title, 'Fjallraven Backpack');
      },
    );

    test(
      'Debe lanzar NetworkFailure cuando falle la conexión de red al solicitar productos',
      () async {
        // Arrange
        mockRemoteDataSource.shouldThrowNetworkException = true;

        // Act & Assert
        expect(
          () async => await repository.getProductsByCategory(tCategory),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );

    test(
      'Debe lanzar ServerFailure cuando el servidor falle al solicitar productos',
      () async {
        // Arrange
        mockRemoteDataSource.shouldThrowServerException = true;

        // Act & Assert
        expect(
          () async => await repository.getProductsByCategory(tCategory),
          throwsA(isA<ServerFailure>()),
        );
      },
    );
  });
}
