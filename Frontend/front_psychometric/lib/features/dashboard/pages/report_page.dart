import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/user_response_service.dart';
import 'dart:html' as html;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final UserService _userService = UserService();
  final UserResponseService _userResponseService = UserResponseService();
  late Future<List<Map<String, dynamic>>> _usersFuture;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _selectedUser;
  List<Map<String, dynamic>> _responses = [];
  String userRole = '';

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _usersFuture = _userService.fetchUsers();
  }

  Future<void> _loadUserResponses() async {
    try {
      final responses = await _userResponseService.fetchUserResponses();
      setState(() {
        _responses = responses;
      });
    } catch (e) {
      print('Error al obtener las respuestas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole != 'corporate' && userRole != 'admin') {
      return const Center(child: Text('No tienes permisos para ver reportes.'));
    }
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              _users = (snapshot.data ?? []).where((u) => u['userType'] == 'assessment').toList();
              if (_users.isEmpty) {
                return const Center(child: Text('No hay usuarios assessment.'));
              }
              return ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user['firstName'] + ' ' + (user['lastName'] ?? '')),
                    subtitle: Text(user['email'] ?? ''),
                    selected: _selectedUser?['id'] == user['id'],
                    onTap: () async {
                      setState(() {
                        _selectedUser = user;
                        _responses = [];
                      });
                      await _loadUserResponses();
                    },
                  );
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          flex: 3,
          child: _selectedUser == null
              ? const Center(child: Text('Selecciona un usuario para ver sus resultados'))
              : _responses.isEmpty
                  ? const Center(child: Text('No hay respuestas registradas para este usuario'))
                  : ListView.builder(
                      itemCount: _responses.length,
                      itemBuilder: (context, index) {
                        final resp = _responses[index];
                        return ListTile(
                          title: Text('Pregunta: ' + (resp['questionText'] ?? '')),
                          subtitle: Text('Respuesta: ' + (resp['answerOptionText'] ?? '')),
                        );
                      },
                    ),
        ),
      ],
    );
  }
} 