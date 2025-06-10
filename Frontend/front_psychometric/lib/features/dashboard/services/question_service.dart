import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class QuestionService {
  static const _baseUrl = 'http://localhost:5194/api/Question';

  Future<List<Map<String, dynamic>>> fetchQuestionsByBlock(int blockId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ByBlock/$blockId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Ordenar las preguntas por orderNumber
        final questions = data.cast<Map<String, dynamic>>().toList();
        questions.sort((a, b) => a['orderNumber'].compareTo(b['orderNumber']));
        return questions;
      } else {
        throw Exception('Error al obtener las preguntas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en fetchQuestionsByBlock: $e');
      throw Exception('Error al obtener las preguntas: $e');
    }
  }

  Future<Map<String, dynamic>> fetchQuestionById(int questionId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$questionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener la pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener la pregunta: $e');
    }
  }

  Future<Map<String, dynamic>> createQuestion({
    required String text,
    required int blockId,
    required int orderNumber,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "questionBlockId": blockId,
        "text": text,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (!responseData.containsKey('id')) {
        throw Exception('La respuesta del servidor no incluye el ID de la pregunta');
      }
      return responseData;
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error desconocido'}');
    } else {
      throw Exception('Error al crear la pregunta: ${response.statusCode}');
    }
  }

  Future<void> updateQuestion({
    required int id,
    required String text,
    required int questionBlockId,
    required int orderNumber,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": id,
        "questionBlockId": questionBlockId,
        "text": text,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception('Error al actualizar la pregunta: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }

  Future<void> deleteQuestion(int id) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception('Error al eliminar la pregunta: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }
}