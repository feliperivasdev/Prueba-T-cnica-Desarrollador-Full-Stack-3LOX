import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class UserService {
  static const _baseUrl = 'http://localhost:5194/api/Users';

  Future<List<Map<String, dynamic>>> fetchUsers() async {
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
    } else {
      throw Exception('Error al obtener los usuarios');
    }
  }

  Future<void> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String userType,
  }) async {
    final token = html.window.localStorage['jwt_token'];
    if (token == null) {
      throw Exception('No autenticado');
    }
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "userType": userType,
      }),
    );
    if (response.statusCode != 204) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al actualizar el usuario: ${errorData['message'] ?? 'Error desconocido'}');
      } catch (_) {
        throw Exception('Error al actualizar el usuario: ${response.body}');
      }
    }
  }

  Future<void> deleteUser(int id) async {
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
      throw Exception('Error al eliminar el usuario');
    }
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String userType,
    required String password,
  }) async {
    final token = html.window.localStorage['jwt_token'];
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
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "userType": userType,
        "password": password,
      }),
    );
    if (response.statusCode != 201) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al crear el usuario: ${errorData['message'] ?? 'Error desconocido'}');
      } catch (_) {
        throw Exception('Error al crear el usuario: ${response.body}');
      }
    }
  }

  Future<void> createUserFull({
    required String firstName,
    required String lastName,
    required String email,
    required String userType,
    required String password,
    required String passwordHash,
    required String createdAt,
    required String updatedAt,
    int? corporateId,
  }) async {
    final token = html.window.localStorage['jwt_token'];
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
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "userType": userType,
        "password": password,
        "passwordHash": passwordHash,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "corporateId": corporateId ?? 0,
      }),
    );
    if (response.statusCode != 201) {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception('Error al crear el usuario: ${errorData['message'] ?? 'Error desconocido'}');
      } catch (_) {
        throw Exception('Error al crear el usuario: ${response.body}');
      }
    }
  }
} 