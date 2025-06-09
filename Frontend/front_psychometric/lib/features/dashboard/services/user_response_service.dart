import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class UserResponseService {
  static const _baseUrl = 'http://localhost:5194/api/UserResponse';

  Future<void> saveUserResponse({
    required int userId,
    required int questionId,
    required int answerOptionId,
    required int responseValue,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId": userId,
        "questionId": questionId,
        "answerOptionId": answerOptionId,
        "responseValue": responseValue,
        "respondedAt": DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al guardar la respuesta');
    }
  }
}