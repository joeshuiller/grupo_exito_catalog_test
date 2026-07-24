import 'dart:convert';

import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/core/network/http_client.dart';
import 'package:grupo_exito_catalog_test/features/catalog/data/models/product_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final HttpClient client;
  final String baseUrl = 'https://fakestoreapi.com';

  CatalogRemoteDataSourceImpl({required this.client});

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await client.get('$baseUrl/products/categories');

      if (response.statusCode == 200) {
        final List rawJson = json.decode(response.body);
        return rawJson.map((e) => e.toString()).toList();
      } else {
        throw ServerException('Failed to load categories');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión al cargar categorías: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final response = await client.get('$baseUrl/products/category/$category');

      if (response.statusCode == 200) {
        final List rawJson = json.decode(response.body);
        return rawJson.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw ServerException('Failed to load products for category $category');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión al cargar productos: $e');
    }
  }
}
