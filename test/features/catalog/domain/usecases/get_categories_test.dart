import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<String>> getCategories() async {
    return ['electronics', 'jewelery', 'men\'s clothing'];
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async => [];
}

void main() {
  late GetCategories useCase;
  late MockCatalogRepository mockRepository;

  setUp(() {
    mockRepository = MockCatalogRepository();
    useCase = GetCategories(mockRepository);
  });

  test('Debe obtener la lista de categorías desde el repositorio', () async {
    final result = await useCase();

    expect(result, equals(['electronics', 'jewelery', 'men\'s clothing']));
    expect(result.length, 3);
  });
}
