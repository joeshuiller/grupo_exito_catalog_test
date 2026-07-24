import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

abstract class CatalogRepository {
  Future<List<String>> getCategories();
  Future<List<Product>> getProductsByCategory(String category);
}
