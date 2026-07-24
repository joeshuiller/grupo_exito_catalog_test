/// Utilidad para la gestión y validación de reglas temporales de negocio.
class TimeUtils {
  /// Verifica si la hora dada se encuentra dentro del horario permitido Express (10:00 AM - 23:59 PM).
  static bool isExpressAvailable(DateTime currentTime) {
    final hour = currentTime.hour;
    // Permite de 10:00 AM inclusive hasta las 22:59 PM (11:00 PM no inclusive)
    return hour >= 10 && hour < 16;
  }
}
