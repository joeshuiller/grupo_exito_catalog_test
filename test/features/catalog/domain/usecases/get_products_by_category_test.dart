import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    return [
      Product(
        id: 10,
        title: 'Leche Alquería',
        price: 4500.0,
        category: category,
        image: 'https://via.placeholder.com/150',
      ),
    ];
  }
}

void main() {
  late GetProductsByCategory useCase;
  late MockCatalogRepository mockRepository;

  setUp(() {
    mockRepository = MockCatalogRepository();
    useCase = GetProductsByCategory(mockRepository);
  });

  test(
    'Debe obtener los productos correspondientes a la categoría dada',
    () async {
      final result = await useCase('lacteos');

      expect(result.length, 1);
      expect(result.first.category, 'lacteos');
      expect(result.first.title, 'Leche Alquería');
    },
  );
}
