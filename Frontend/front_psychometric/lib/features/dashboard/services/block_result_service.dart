import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class BlockResultService {
  static const _baseUrl = 'http://localhost:5194/api/BlockResult';

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  int? _getUserId() {
    final userIdStr = html.window.localStorage['user_id'];
    return userIdStr != null ? int.parse(userIdStr) : null;
  }

  bool _isAssessment() {
    return _getUserRole() == 'assessment';
  }

  Future<void> saveBlockResult({
    required int blockId,
    required double totalScore,
    required double averageScore,
  }) async {
    if (!_isAssessment()) {
      throw Exception('Solo los usuarios de tipo assessment pueden guardar resultados');
    }

    final userId = _getUserId();
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final responseData = {
      "userId": userId,
      "blockId": blockId,
      "totalScore": totalScore,
      "averageScore": averageScore,
      "completedAt": DateTime.now().toUtc().toIso8601String(),
    };

    print('Enviando datos: ${jsonEncode(responseData)}'); // Para debugging

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(responseData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al guardar el resultado: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en la petición: $e');
      throw Exception('Error al guardar el resultado: $e');
    }
  }

  Future<Map<String, dynamic>> getBlockResultByUserAndBlock({
    required int blockId,
  }) async {
    if (!_isAssessment()) {
      throw Exception('Solo los usuarios de tipo assessment pueden ver resultados');
    }

    final userId = _getUserId();
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ByUserAndBlock?userId=$userId&blockId=$blockId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener el resultado: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en la petición: $e');
      throw Exception('Error al obtener el resultado: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBlockResultsReport() async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      // Obtener todos los resultados
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener el reporte: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en la petición: $e');
      throw Exception('Error al obtener el reporte: $e');
    }
  }
} 