import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class BlockService {
  static const _baseUrl = 'http://localhost:5194/api/QuestionBlock';

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  bool _canViewBlocks() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin' || role == 'assessment';
  }

  bool _canManageBlocks() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin';
  }

  Future<List<Map<String, dynamic>>> fetchBlocks() async {
    if (!_canViewBlocks()) {
      throw Exception('No tienes permiso para ver los bloques');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener los bloques: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los bloques: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBlocksByTestId(int testId) async {
    if (!_canViewBlocks()) {
      throw Exception('No tienes permiso para ver los bloques');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/by-test/$testId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener los bloques: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los bloques: $e');
    }
  }

  Future<Map<String, dynamic>> createBlock(Map<String, dynamic> blockData) async {
    if (!_canManageBlocks()) {
      throw Exception('No tienes permiso para crear bloques');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final requestBody = {
        "testId": blockData['testId'],
        "title": blockData['title'],
        "description": blockData['description'],
        "orderNumber": blockData['orderNumber'],
      };
      
      print('Enviando datos al servidor: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Respuesta del servidor - Status: ${response.statusCode}');
      print('Respuesta del servidor - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear el bloque: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en createBlock: $e');
      throw Exception('Error al crear el bloque: $e');
    }
  }

  Future<void> updateBlock(int id, Map<String, dynamic> blockData) async {
    if (!_canManageBlocks()) {
      throw Exception('No tienes permiso para actualizar bloques');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": id,
          "testId": blockData['testId'],
          "title": blockData['title'],
          "description": blockData['description'],
          "orderNumber": blockData['orderNumber'],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el bloque: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el bloque: $e');
    }
  }

  Future<void> deleteBlock(int id) async {
    if (!_canManageBlocks()) {
      throw Exception('No tienes permiso para eliminar bloques');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el bloque: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el bloque: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBlockById(int blockId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final url = '$_baseUrl/$blockId';
    print('Intentando acceder a: $url'); // Log de la URL

    try {
      final response = await http.get(
        Uri.parse(url),
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
        throw Exception('Error al obtener el bloque: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en fetchBlockById: $e');
      throw Exception('Error al obtener el bloque: $e');
    }
  }
} 