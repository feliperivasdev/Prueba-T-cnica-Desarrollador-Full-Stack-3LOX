import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class AuthService {
  static const _baseUrl = 'http://localhost:5194/api/auth';

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      html.window.localStorage['jwt_token'] = data['token'];
      html.window.localStorage['user_id'] = data['id'].toString();
      html.window.localStorage['first_name'] = data['firstName'];
      html.window.localStorage['last_name'] = data['lastName'];
      html.window.localStorage['user_type'] = data['userType'];
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    html.window.localStorage.remove('jwt_token');
    html.window.localStorage.remove('user_id');
    html.window.localStorage.remove('first_name');
    html.window.localStorage.remove('last_name');
    html.window.localStorage.remove('user_type');
  }

  // Métodos para obtener los datos si los necesitas
  String? get token => html.window.localStorage['jwt_token'];
  String? get userId => html.window.localStorage['user_id'];
  String? get firstName => html.window.localStorage['first_name'];
  String? get lastName => html.window.localStorage['last_name'];
  String? get userType => html.window.localStorage['user_type'];
}