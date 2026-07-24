import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:grupo_exito_catalog_test/core/errors/exceptions.dart';
import 'package:grupo_exito_catalog_test/core/network/http_client.dart';

/// Client de HTTP enmascarado para controlar y simular las peticiones sin salir a red real.
class MockBaseClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request) _send;

  MockBaseClient(this._send);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _send(request);
}

void main() {
  group('HttpClient Tests', () {
    const tUrl = 'https://fakestoreapi.com/products';

    test(
      'Debe retornar un http.Response válido cuando la petición es exitosa (200 OK)',
      () async {
        // Arrange
        final mockClient = MockBaseClient((request) async {
          return http.StreamedResponse(
            Stream.value('{"data": "success"}'.codeUnits),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final httpClient = HttpClient(client: mockClient);

        // Act
        final response = await httpClient.get(tUrl);

        // Assert
        expect(response, isA<http.Response>());
        expect(response.statusCode, 200);
        expect(response.body, '{"data": "success"}');
      },
    );

    test(
      'Debe lanzar NetworkException cuando ocurre un SocketException (Sin conexión)',
      () async {
        // Arrange
        final mockClient = MockBaseClient((request) async {
          throw const SocketException('No Internet connection');
        });

        final httpClient = HttpClient(client: mockClient);

        // Act & Assert
        expect(
          () async => await httpClient.get(tUrl),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('No se pudo establecer conexión con el servidor'),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar NetworkException cuando ocurre un http.ClientException',
      () async {
        // Arrange
        final mockClient = MockBaseClient((request) async {
          throw http.ClientException('Connection closed unexpectedly');
        });

        final httpClient = HttpClient(client: mockClient);

        // Act & Assert
        expect(
          () async => await httpClient.get(tUrl),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains(
                'Error de red al realizar la petición: Connection closed unexpectedly',
              ),
            ),
          ),
        );
      },
    );

    test(
      'Debe lanzar ServerException ante cualquier otra excepción genérica',
      () async {
        // Arrange
        final mockClient = MockBaseClient((request) async {
          throw FormatException('Malformed JSON');
        });

        final httpClient = HttpClient(client: mockClient);

        // Act & Assert
        expect(
          () async => await httpClient.get(tUrl),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Error inesperado durante la petición HTTP'),
            ),
          ),
        );
      },
    );
  });
}
