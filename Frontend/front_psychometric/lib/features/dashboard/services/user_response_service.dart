import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class UserResponseService {
  static const _baseUrl = 'http://localhost:5194/api/UserResponse';

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

  Future<void> saveUserResponse({
    required int questionId,
    required int answerOptionId,
    required int responseValue,
  }) async {
    if (!_isAssessment()) {
      throw Exception('Solo los usuarios de tipo assessment pueden guardar respuestas');
    }

    final userId = _getUserId();
    if (userId == null) {
      throw Exception('No se encontró el ID del usuario');
    }

    // Validar que el responseValue esté entre 1 y 5
    if (responseValue < 1 || responseValue > 5) {
      throw Exception('El valor de la respuesta debe estar entre 1 y 5');
    }

    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    // Crear el objeto de respuesta en el formato exacto requerido
    final responseData = {
      "userId": userId,
      "questionId": questionId,
      "answerOptionId": answerOptionId,
      "responseValue": responseValue,
      "respondedAt": DateTime.now().toUtc().toIso8601String(),
    };

    print('Enviando datos: ${jsonEncode(responseData)}'); // Para debugging

    try {
      // Intentamos actualizar primero
      final updateResponse = await http.put(
        Uri.parse('$_baseUrl/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(responseData),
      );

      // Si la actualización falla (404), intentamos crear
      if (updateResponse.statusCode == 404) {
        final createResponse = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(responseData),
        );

        print('Create Response status: ${createResponse.statusCode}');
        print('Create Response body: ${createResponse.body}');

        if (createResponse.statusCode != 200 && createResponse.statusCode != 201) {
          throw Exception('Error al crear la respuesta: ${createResponse.statusCode} - ${createResponse.body}');
        }
      } else {
        print('Update Response status: ${updateResponse.statusCode}');
        print('Update Response body: ${updateResponse.body}');

        if (updateResponse.statusCode != 200) {
          throw Exception('Error al actualizar la respuesta: ${updateResponse.statusCode} - ${updateResponse.body}');
        }
      }
    } catch (e) {
      print('Error en la petición: $e');
      throw Exception('Error al guardar la respuesta: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserResponses() async {
    if (!_isAssessment()) {
      throw Exception('Solo los usuarios de tipo assessment pueden ver respuestas');
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
        Uri.parse('$_baseUrl/by-user/$userId'),
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
        throw Exception('Error al obtener las respuestas del usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en la petición: $e');
      throw Exception('Error al obtener las respuestas: $e');
    }
  }
}