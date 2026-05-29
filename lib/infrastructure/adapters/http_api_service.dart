import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/domain/ports/api_service_port.dart';

class HttpApiService implements ApiServicePort {
  final http.Client _client;
  final Random _random = Random();
  bool simulateFailures = true; // Permite alternar la simulación de fallas

  HttpApiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<int> uploadInspection(InspectionModel inspection) async {
    // Si la simulación de fallas está activa, jugamos con la probabilidad del 50%
    if (simulateFailures) {
      final double roll = _random.nextDouble();
      if (roll < 0.25) {
        // 25% de probabilidad: Conflicto del servidor (HTTP 409)
        return 409;
      } else if (roll < 0.50) {
        // 25% de probabilidad: Error temporal de servidor (HTTP 500)
        return 500;
      }
    }

    try {
      final url = Uri.parse('https://httpbin.org/post');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...inspection.toJson(),
          'photoName': inspection.photoPath.split('/').last,
        }),
      );

      return response.statusCode;
    } catch (e) {
      // Si hay un error real de conexión física (sin internet) retornamos un 503 (Servicio no disponible)
      return 503;
    }
  }
}
