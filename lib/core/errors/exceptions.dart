/// Excepción lanzada cuando el servidor responde con un código de error (e.g., 400, 404, 500).
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error al comunicarse con el servidor']);

  @override
  String toString() => 'ServerException: $message';
}

/// Excepción lanzada cuando ocurre un problema de red o falta de conexión.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexión a internet']);

  @override
  String toString() => 'NetworkException: $message';
}
