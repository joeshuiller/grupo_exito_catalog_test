import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

/// Envoltorio personalizado de HTTP Client para centralizar manejo de errores, logs y headers.
class HttpClient {
  final http.Client _client;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      return response;
    } on SocketException {
      throw NetworkException(
        'No se pudo establecer conexión con el servidor. Revisa tu internet.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Error de red al realizar la petición: ${e.message}',
      );
    } catch (e) {
      throw ServerException('Error inesperado durante la petición HTTP: $e');
    }
  }
}
