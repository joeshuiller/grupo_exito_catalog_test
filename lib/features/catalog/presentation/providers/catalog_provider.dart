import 'package:flutter/material.dart';
import 'package:grupo_exito_catalog_test/core/errors/failures.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_categories.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/usecases/get_products_by_category.dart';

class CatalogProvider extends ChangeNotifier {
  final GetCategories getCategoriesUseCase;
  final GetProductsByCategory getProductsByCategoryUseCase;

  CatalogProvider({
    required this.getCategoriesUseCase,
    required this.getProductsByCategoryUseCase,
  });

  List<String> _categories = [];
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get categories => _categories;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _categories = await getCategoriesUseCase();
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado al cargar categorías';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductsByCategory(String category) async {
    _setLoading(true);
    _products = [];
    _errorMessage = null;
    try {
      _products = await getProductsByCategoryUseCase(category);
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Ocurrió un error inesperado al cargar productos';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
