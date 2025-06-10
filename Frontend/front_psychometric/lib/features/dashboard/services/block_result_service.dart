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

  bool _isCorporate() {
    return _getUserRole() == 'corporate';
  }

  Future<void> saveBlockResult({
    required int blockId,
    required double totalScore,
    required double averageScore,
  }) async {
    if (!_isCorporate()) {
      throw Exception('No tienes permisos para guardar resultados de bloque');
    }

    final userId = _getUserId();
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    final token = html.window.localStorage['jwt_token'];
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId": userId,
        "blockId": blockId,
        "totalScore": totalScore,
        "averageScore": averageScore,
        "completedAt": DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Error en la respuesta: ${response.body}'); // Para debugging
      throw Exception('Error al guardar el resultado del bloque: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getBlockResultByUserAndBlock({
    required int blockId,
  }) async {
    if (!_isCorporate()) {
      throw Exception('No tienes permisos para ver resultados de bloque');
    }

    final userId = _getUserId();
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }
    
    final response = await http.get(
      Uri.parse('$_baseUrl/ByUserAndBlock?userId=$userId&blockId=$blockId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error en la respuesta: ${response.body}'); // Para debugging
      throw Exception('Error al obtener el resultado del bloque: ${response.statusCode}');
    }
  }
} 