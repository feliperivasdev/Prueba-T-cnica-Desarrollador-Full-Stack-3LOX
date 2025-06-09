import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class AnswerOptionService {
  static const _baseUrl = 'http://localhost:5194/api/AnswerOption';

  Future<List<Map<String, dynamic>>> fetchOptionsByQuestionId(int questionId) async {
    final token = html.window.localStorage['jwt_token'];
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
}