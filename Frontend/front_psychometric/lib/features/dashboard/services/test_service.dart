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
}