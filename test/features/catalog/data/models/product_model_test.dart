import 'package:flutter_test/flutter_test.dart';

import 'package:grupo_exito_catalog_test/features/catalog/data/models/product_model.dart';
import 'package:grupo_exito_catalog_test/features/catalog/domain/entities/product.dart';

void main() {
  const tProductModel = ProductModel(
    id: 1,
    title: 'Queso Mozzarella',
    price: 17100.0,
    category: 'Lácteos',
    image: 'https://via.placeholder.com/150',
  );

  test('ProductModel debe ser una subclase de la entidad Product', () {
    expect(tProductModel, isA<Product>());
  });

  group('fromJson', () {
    test(
      'Debe retornar un modelo válido cuando el precio en JSON es num/double',
      () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'title': 'Queso Mozzarella',
          'price': 17100.5,
          'category': 'Lácteos',
          'image': 'https://via.placeholder.com/150',
        };

        final result = ProductModel.fromJson(jsonMap);

        // 🟢 Compara las propiedades individuales
        expect(result.id, 1);
        expect(result.title, 'Queso Mozzarella');
        expect(result.price, 17100.5);
        expect(result.category, 'Lácteos');
        expect(result.image, 'https://via.placeholder.com/150');
      },
    );

    test(
      'Debe convertir el precio a double cuando el JSON entregue un int',
      () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'title': 'Queso Mozzarella',
          'price': 17100,
          'category': 'Lácteos',
          'image': 'https://via.placeholder.com/150',
        };

        final result = ProductModel.fromJson(jsonMap);

        expect(result.price, isA<double>());
        expect(result.price, 17100.0);
      },
    );

    test(
      'Debe aplicar los valores por defecto cuando los campos opcionales vengan nulos o ausentes',
      () {
        final Map<String, dynamic> jsonMap = {'id': 2, 'price': 5000};

        final result = ProductModel.fromJson(jsonMap);

        expect(result.id, 2);
        expect(result.title, '');
        expect(result.price, 5000.0);
        expect(result.category, '');
        expect(result.image, 'https://via.placeholder.com/150');
      },
    );
  });

  group('toJson', () {
    test('Debe retornar un Map con la estructura JSON correspondiente', () {
      final result = tProductModel.toJson();

      final expectedMap = {
        'id': 1,
        'title': 'Queso Mozzarella',
        'price': 17100.0,
        'category': 'Lácteos',
        'image': 'https://via.placeholder.com/150',
      };

      expect(result, equals(expectedMap));
    });
  });
}

extension ProductModelTestExtension on ProductModel {
  ProductModel copyWith({
    int? id,
    String? title,
    double? price,
    String? category,
    String? image,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}
