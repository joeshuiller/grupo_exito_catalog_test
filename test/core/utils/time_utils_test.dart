import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_exito_catalog_test/core/utils/time_utils.dart';

void main() {
  group('TimeUtils - Lógica de Horario Express', () {
    test('Debe retornar true a las 10:00 AM (Inicio del rango)', () {
      final time = DateTime(2026, 7, 24, 10, 0);
      expect(TimeUtils.isExpressAvailable(time), isTrue);
    });

    test('Debe retornar true a las 02:30 PM (14:30 PM - Dentro del rango)', () {
      final time = DateTime(2026, 7, 24, 14, 30);
      expect(TimeUtils.isExpressAvailable(time), isTrue);
    });

    test('Debe retornar false a las 09:59 AM (Antes del rango)', () {
      final time = DateTime(2026, 7, 24, 9, 59);
      expect(TimeUtils.isExpressAvailable(time), isFalse);
    });

    test('Debe retornar false a las 04:00 PM (16:00 PM - Límite superior)', () {
      final time = DateTime(2026, 7, 24, 16, 0);
      expect(TimeUtils.isExpressAvailable(time), isFalse);
    });
  });
}
