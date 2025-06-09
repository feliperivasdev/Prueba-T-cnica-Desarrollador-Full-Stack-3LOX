import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class QuestionBlockService {
  static const _baseUrl = 'http://localhost:5194/api/QuestionBlock';

  Future<List<Map<String, dynamic>>> fetchBlocksByTestId(int testId) async {
    final token = html.window.localStorage['jwt_token'];
    final response = await http.get(
      Uri.parse('$_baseUrl?testId=$testId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener los bloques de preguntas');
    }
  }
}