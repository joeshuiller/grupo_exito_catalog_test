import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/core/errors/failures.dart';

void main() {
  group('ServerFailure Tests', () {
    test('Debe asignar el mensaje por defecto si no se pasa un argumento', () {
      const failure = ServerFailure();

      expect(failure.message, 'Error en el servidor de FakeStore');
      expect(failure.toString(), 'Error en el servidor de FakeStore');
      expect(failure, isA<Failure>());
    });

    test('Debe asignar el mensaje personalizado si es provisto', () {
      const customMsg = 'Error 502: Bad Gateway';
      const failure = ServerFailure(customMsg);

      expect(failure.message, customMsg);
      expect(failure.toString(), customMsg);
    });
  });

  group('CacheFailure Tests', () {
    test('Debe asignar el mensaje por defecto si no se pasa un argumento', () {
      const failure = CacheFailure();

      expect(failure.message, 'Error al recuperar datos locales');
      expect(failure.toString(), 'Error al recuperar datos locales');
      expect(failure, isA<Failure>());
    });

    test('Debe asignar el mensaje personalizado si es provisto', () {
      const customMsg = 'Base de datos Hive corrupta';
      const failure = CacheFailure(customMsg);

      expect(failure.message, customMsg);
      expect(failure.toString(), customMsg);
    });
  });

  group('NetworkFailure Tests', () {
    test('Debe asignar el mensaje por defecto si no se pasa un argumento', () {
      const failure = NetworkFailure();

      expect(failure.message, 'Sin conexión a internet');
      expect(failure.toString(), 'Sin conexión a internet');
      expect(failure, isA<Failure>());
    });

    test('Debe asignar el mensaje personalizado si es provisto', () {
      const customMsg = 'Tiempo de espera agotado (Timeout)';
      const failure = NetworkFailure(customMsg);

      expect(failure.message, customMsg);
      expect(failure.toString(), customMsg);
    });
  });
}
