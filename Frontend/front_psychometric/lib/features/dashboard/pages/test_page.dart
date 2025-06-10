import 'package:flutter/material.dart';
import '../services/test_service.dart';
import 'create_test_page.dart';
import 'question_block_page.dart';
import 'edit_test_page.dart';
import 'dart:html' as html;

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TestService _testService = TestService();
  late Future<List<Map<String, dynamic>>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  void _loadTests() {
    _testsFuture = _testService.fetchTests();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = html.window.localStorage['user_type'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests'),
      ),
      floatingActionButton: (userRole == 'corporate' || userRole == 'admin')
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateTestPage()),
                );
                if (result != null) {
                  setState(() {
                    _loadTests();
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tests = snapshot.data ?? [];
          final filteredTests = (userRole == 'assessment')
              ? tests.where((t) {
                  final isActive = t['isActive'] ?? t['IsActive'];
                  return isActive == true || isActive == 'true';
                }).toList()
              : tests;
          if (filteredTests.isEmpty) {
            return const Center(child: Text('No hay tests disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTests.length,
            itemBuilder: (context, index) {
              final test = filteredTests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(test['name'] ?? 'Sin nombre'),
                  subtitle: Text(test['description'] ?? 'Sin descripción'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        test['isActive'] == true ? Icons.check_circle : Icons.cancel,
                        color: test['isActive'] == true ? Colors.green : Colors.red,
                      ),
                      if (userRole == 'corporate' || userRole == 'admin') ...[
                        const SizedBox(width: 8),
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
                              setState(() {
                                _loadTests();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
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
                            if (confirm == true) {
                              try {
                                await _testService.deleteTest(test['id']);
                                setState(() {
                                  _loadTests();
                                });
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al eliminar el test: $e')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionBlockPage(
                          testId: test['id'],
                          testTitle: test['name'] ?? 'Test',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 