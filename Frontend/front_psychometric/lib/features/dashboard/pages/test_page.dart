import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/test_service.dart';
import 'edit_test_page.dart';
import 'question_block_page.dart';

class TestPage extends StatefulWidget {
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String userRole = '';
  final TestService testService = TestService();
  late Future<List<Map<String, dynamic>>> _testsFuture;

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _loadTests();
  }

  void _loadTests() {
    setState(() {
      _testsFuture = testService.fetchTests();
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
              label: const Text('Crear Test'),
              onPressed: () async {
                // Aquí deberías navegar a la página de creación de test si la tienes
                // final result = await Navigator.push(...)
                // if (result == true) _loadTests();
              },
            ),
          ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _testsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \\${snapshot.error}'));
              }
              final tests = snapshot.data ?? [];
              if (tests.isEmpty) {
                return const Center(child: Text('No hay tests disponibles.'));
              }
              return ListView.builder(
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return _buildTestCard(test);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(test['name'] ?? ''),
        subtitle: Text(test['description'] ?? ''),
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
                      builder: (context) => EditTestPage(test: test),
                    ),
                  );
                  if (result == true) {
                    _loadTests();
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
                      content: const Text('¿Estás seguro de que deseas eliminar este test?'),
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
                      await testService.deleteTest(test['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test eliminado exitosamente')),
                      );
                      _loadTests();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar el test: $e')),
                      );
                    }
                  }
                },
              ),
            ],
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionBlockPage(
                      testId: test['id'],
                      testName: test['name'] ?? '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 