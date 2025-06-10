import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class QuestionBlockService {
  static const _baseUrl = 'http://localhost:5194/api/QuestionBlock';

  Future<List<Map<String, dynamic>>> fetchBlocksByTestId(int testId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

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
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al obtener los bloques de preguntas: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchBlockWithQuestions(int blockId) async {
    final token = html.window.localStorage['jwt_token'];
    final response = await http.get(
      Uri.parse('$_baseUrl/$blockId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener el bloque y sus preguntas');
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestionsOfBlock(int blockId) async {
    final token = html.window.localStorage['jwt_token'];
    final response = await http.get(
      Uri.parse('$_baseUrl/$blockId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Suponiendo que la respuesta tiene un campo "questions"
      final questions = data['questions'] as List<dynamic>? ?? [];
      return questions.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener las preguntas del bloque');
    }
  }

  Future<Map<String, dynamic>> createQuestionBlock({
    required String name,
    required String description,
    required int testId,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    // Obtener el último número de orden
    final blocks = await fetchBlocksByTestId(testId);
    final orderNumber = blocks.isEmpty ? 1 : blocks.length + 1;

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "testId": testId,
        "title": name,
        "description": description,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (!responseData.containsKey('id')) {
        throw Exception('La respuesta del servidor no incluye el ID del bloque');
      }
      return responseData;
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error desconocido'}');
    } else {
      throw Exception('Error al crear el bloque de preguntas: ${response.statusCode}');
    }
  }

  Future<void> updateQuestionBlock({
    required int id,
    required String title,
    required String description,
    required int testId,
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
        "testId": testId,
        "title": title,
        "description": description,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception('Error al actualizar el bloque: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }

  Future<void> deleteQuestionBlock(int id) async {
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
      throw Exception('Error al eliminar el bloque: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }
}