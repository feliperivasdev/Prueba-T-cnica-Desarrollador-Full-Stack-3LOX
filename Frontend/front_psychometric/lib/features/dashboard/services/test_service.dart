import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class TestService {
  static const _baseUrl = 'http://localhost:5194/api/Test';

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  bool _hasPermission() {
    final role = _getUserRole();
    return role == 'corporate' || role == 'admin';
  }

  Future<List<Map<String, dynamic>>> fetchTests() async {
    if (!_hasPermission()) {
      throw Exception('No tienes permiso para ver los tests');
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
        throw Exception('Error al obtener los tests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los tests: $e');
    }
  }

  Future<Map<String, dynamic>> createTest(Map<String, dynamic> testData) async {
    if (!_hasPermission()) {
      throw Exception('No tienes permiso para crear tests');
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
        body: jsonEncode(testData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear el test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear el test: $e');
    }
  }

  Future<void> updateTest(int id, Map<String, dynamic> testData) async {
    if (!_hasPermission()) {
      throw Exception('No tienes permiso para actualizar tests');
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
        body: jsonEncode(testData),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el test: $e');
    }
  }

  Future<void> deleteTest(int id) async {
    if (!_hasPermission()) {
      throw Exception('No tienes permiso para eliminar tests');
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
        throw Exception('Error al eliminar el test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar el test: $e');
    }
  }
}

