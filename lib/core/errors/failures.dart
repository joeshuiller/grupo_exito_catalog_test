/// Clase base para todos los fallos manejados en el dominio de la aplicación.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Fallo derivado de errores en el servidor o servicios externos (APIs).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor de FakeStore']);
}

/// Fallo derivado de problemas al interactuar con el almacenamiento local / caché.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al recuperar datos locales']);
}

/// Fallo derivado de problemas de conectividad a internet.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}
