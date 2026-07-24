import 'package:grupo_exito_catalog_test/features/catalog/domain/repositories/catalog_repository.dart';

/// Caso de uso encargado de obtener el listado completo de categorías disponibles.
class GetCategories {
  final CatalogRepository repository;

  GetCategories(this.repository);

  /// Ejecuta el caso de uso invocando al repositorio de catálogo.
  Future<List<String>> call() async {
    return await repository.getCategories();
  }
}
