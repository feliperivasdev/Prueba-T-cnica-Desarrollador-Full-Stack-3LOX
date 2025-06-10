import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class TestService {
  static const _baseUrl = 'http://localhost:5194/api/Test';

  Future<List<Map<String, dynamic>>> fetchTests() async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

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
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener los tests');
    }
  }

  Future<Map<String, dynamic>> createTest({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    final creatorId = int.tryParse(html.window.localStorage['user_id'] ?? '0') ?? 0;
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
        "name": name,
        "description": description,
        "isActive": isActive,
        "creatorId": creatorId,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (!responseData.containsKey('id')) {
        throw Exception('La respuesta del servidor no incluye el ID del test');
      }
      return responseData;
    } else if (response.statusCode == 400) {
      final errorData = jsonDecode(response.body);
      throw Exception('Datos inválidos: ${errorData['message'] ?? 'Error desconocido'}');
    } else {
      throw Exception('Error al crear el test: ${response.statusCode}');
    }
  }

  Future<void> updateTest({
    required int id,
    required String name,
    required String description,
    required bool isActive,
    required int creatorId,
    required String createdAt,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }

    final body = {
      "id": id,
      "name": name,
      "description": description,
      "isActive": isActive,
      "creatorId": creatorId,
      "createdAt": createdAt,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 204) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al actualizar el test: ${errorData['message'] ?? 'Error desconocido'}');
      } catch (_) {
        throw Exception('Error al actualizar el test: ${response.body}');
      }
    }
  }

  Future<void> deleteTest(int id) async {
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
      throw Exception('Error al eliminar el test: ${errorData['message'] ?? 'Error desconocido'}');
    }
  }
}

