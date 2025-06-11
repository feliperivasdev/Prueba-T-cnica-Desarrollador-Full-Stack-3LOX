import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class AnswerOptionService {
  static const _baseUrl = 'http://localhost:5194/api/AnswerOption';

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  bool _canViewOptions() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin' || role == 'assessment';
  }

  bool _canManageOptions() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin';
  }

  Future<List<Map<String, dynamic>>> fetchAnswerOptionsByQuestionId(int questionId) async {
    if (!_canViewOptions()) {
      throw Exception('No tienes permiso para ver las opciones de respuesta');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
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
        throw Exception('Error al obtener las opciones de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las opciones de respuesta: $e');
    }
  }

  Future<Map<String, dynamic>> createAnswerOption(Map<String, dynamic> optionData) async {
    if (!_canManageOptions()) {
      throw Exception('No tienes permiso para crear opciones de respuesta');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "questionId": optionData['questionId'],
          "value": optionData['value'],
          "text": optionData['text'],
          "orderNumber": optionData['orderNumber'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear la opción de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear la opción de respuesta: $e');
    }
  }

  Future<void> createDefaultOptions(int questionId) async {
    if (!_canManageOptions()) {
      throw Exception('No tienes permiso para crear opciones de respuesta');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final List<Map<String, dynamic>> options = [
      {"text": "Totalmente en desacuerdo", "value": 1, "orderNumber": 1},
      {"text": "En desacuerdo", "value": 2, "orderNumber": 2},
      {"text": "Neutral", "value": 3, "orderNumber": 3},
      {"text": "De acuerdo", "value": 4, "orderNumber": 4},
      {"text": "Totalmente de acuerdo", "value": 5, "orderNumber": 5},
    ];

    for (var option in options) {
      try {
        await createAnswerOption({
          "questionId": questionId,
          "text": option["text"],
          "value": option["value"],
          "orderNumber": option["orderNumber"],
        });
      } catch (e) {
        print('Error al crear opción por defecto: $e');
      }
    }
  }

  Future<void> updateAnswerOption(int id, Map<String, dynamic> optionData) async {
    if (!_canManageOptions()) {
      throw Exception('No tienes permiso para actualizar opciones de respuesta');
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
          "questionId": optionData['questionId'],
          "value": optionData['value'],
          "text": optionData['text'],
          "orderNumber": optionData['orderNumber'],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la opción de respuesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar la opción de respuesta: $e');
    }
  }

  Future<void> deleteAnswerOption(int id) async {
    if (!_canManageOptions()) {
      throw Exception('No tienes permiso para eliminar opciones de respuesta');
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

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar la opción de respuesta: [${response.statusCode}]');
      }
    } catch (e) {
      throw Exception('Error al eliminar la opción de respuesta: $e');
    }
  }
}