import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class AnswerOptionService {
  static const _baseUrl = 'http://localhost:5194/api/AnswerOption';

  Future<List<Map<String, dynamic>>> fetchOptionsByQuestionId(int questionId) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/ByQuestion/$questionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener las opciones de respuesta');
    }
  }

  Future<Map<String, dynamic>> createAnswerOption({
    required int questionId,
    required String text,
    required int value,
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
        "questionId": questionId,
        "text": text,
        "value": value,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (!responseData.containsKey('id')) {
        throw Exception('La respuesta del servidor no incluye el ID de la opción');
      }
      return responseData;
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error desconocido'}');
    } else {
      throw Exception('Error al crear la opción de respuesta: ${response.statusCode}');
    }
  }

  Future<void> createDefaultOptions(int questionId) async {
    final List<Map<String, dynamic>> options = [
      {"text": "Totalmente en desacuerdo", "value": 1},
      {"text": "En desacuerdo", "value": 2},
      {"text": "Neutral", "value": 3},
      {"text": "De acuerdo", "value": 4},
      {"text": "Totalmente de acuerdo", "value": 5},
    ];

    for (var i = 0; i < options.length; i++) {
      await createAnswerOption(
        questionId: questionId,
        text: options[i]["text"] as String,
        value: options[i]["value"] as int,
        orderNumber: i + 1,
      );
    }
  }

  Future<void> updateAnswerOption({
    required int id,
    required String text,
    required int value,
    required int questionId,
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
        "questionId": questionId,
        "text": text,
        "value": value,
        "orderNumber": orderNumber
      }),
    );

    if (response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception('Error al actualizar la opción de respuesta: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }

  Future<void> deleteAnswerOption(int id) async {
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
      throw Exception('Error al eliminar la opción de respuesta: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }
}