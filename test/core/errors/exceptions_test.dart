import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';

void main() {
  group('ServerException Tests', () {
    test('Debe usar el mensaje por defecto cuando no se pasa un parámetro', () {
      final exception = ServerException();

      expect(exception.message, 'Error al comunicarse con el servidor');
      expect(
        exception.toString(),
        'ServerException: Error al comunicarse con el servidor',
      );
    });

    test(
      'Debe asignar el mensaje personalizado cuando se pasa por parámetro',
      () {
        const customMessage = 'Error 500: Fallo interno en la FakeStore API';
        final exception = ServerException(customMessage);

        expect(exception.message, customMessage);
        expect(exception.toString(), 'ServerException: $customMessage');
      },
    );

    test('Debe ser una instancia válida de Exception', () {
      final exception = ServerException();

      expect(exception, isA<Exception>());
    });
  });

  group('NetworkException Tests', () {
    test('Debe usar el mensaje por defecto cuando no se pasa un parámetro', () {
      final exception = NetworkException();

      expect(exception.message, 'Sin conexión a internet');
      expect(exception.toString(), 'NetworkException: Sin conexión a internet');
    });

    test(
      'Debe asignar el mensaje personalizado cuando se pasa por parámetro',
      () {
        const customMessage =
            'No fue posible resolver el host fakestoreapi.com';
        final exception = NetworkException(customMessage);

        expect(exception.message, customMessage);
        expect(exception.toString(), 'NetworkException: $customMessage');
      },
    );

    test('Debe ser una instancia válida de Exception', () {
      final exception = NetworkException();

      expect(exception, isA<Exception>());
    });
  });
}
