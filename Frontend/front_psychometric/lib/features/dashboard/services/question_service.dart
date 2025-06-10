import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class QuestionService {
  static const _baseUrl = 'http://localhost:5194/api/Question';

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  bool _canViewQuestions() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin' || role == 'assessment';
  }

  bool _canManageQuestions() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin';
  }

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    if (!_canViewQuestions()) {
      throw Exception('No tienes permiso para ver las preguntas');
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
        throw Exception('Error al obtener las preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las preguntas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestionsByBlockId(int blockId) async {
    if (!_canViewQuestions()) {
      throw Exception('No tienes permiso para ver las preguntas');
    }

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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener las preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener las preguntas: $e');
    }
  }

  Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> questionData) async {
    if (!_canManageQuestions()) {
      throw Exception('No tienes permiso para crear preguntas');
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
        body: jsonEncode(questionData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear la pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear la pregunta: $e');
    }
  }

  Future<void> updateQuestion(int id, Map<String, dynamic> questionData) async {
    if (!_canManageQuestions()) {
      throw Exception('No tienes permiso para actualizar preguntas');
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
        body: jsonEncode(questionData),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar la pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar la pregunta: $e');
    }
  }

  Future<void> deleteQuestion(int id) async {
    if (!_canManageQuestions()) {
      throw Exception('No tienes permiso para eliminar preguntas');
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
        throw Exception('Error al eliminar la pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar la pregunta: $e');
    }
  }
}