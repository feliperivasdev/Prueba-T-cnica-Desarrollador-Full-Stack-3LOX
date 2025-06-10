import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'edit_user_page.dart';
import 'dart:html' as html;
import 'create_user_page.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _usersFuture;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _userService.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (userRole == 'corporate' || userRole == 'admin')
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear Usuario'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateUserPage(),
                  ),
                );
                if (result == true) {
                  _loadUsers();
                }
              },
            ),
          ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Center(child: Text('No hay usuarios disponibles.'));
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(user['firstName'] + ' ' + (user['lastName'] ?? '')),
        subtitle: Text(user['email'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userRole == 'corporate' || userRole == 'admin') ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserPage(user: user),
                    ),
                  );
                  if (result == true) {
                    _loadUsers();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await _userService.deleteUser(user['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario eliminado exitosamente')),
                      );
                      _loadUsers();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar el usuario: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
} 