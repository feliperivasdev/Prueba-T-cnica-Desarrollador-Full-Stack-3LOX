import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class BlockService {
  static const _baseUrl = 'http://localhost:5194/api/QuestionBlock';

  Future<List<Map<String, dynamic>>> fetchBlocks() async {
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener los bloques: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en fetchBlocks: $e');
      throw Exception('Error al obtener los bloques: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBlocksByTestId(int testId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      // Obtener todos los bloques
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
        // Filtrar los bloques que corresponden al testId
        final filteredBlocks = data
            .where((block) => block['testId'] == testId)
            .cast<Map<String, dynamic>>()
            .toList();
        
        // Ordenar por orderNumber
        filteredBlocks.sort((a, b) => a['orderNumber'].compareTo(b['orderNumber']));
        
        return filteredBlocks;
      } else {
        throw Exception('Error al obtener los bloques del test: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en fetchBlocksByTestId: $e');
      throw Exception('Error al obtener los bloques del test: $e');
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