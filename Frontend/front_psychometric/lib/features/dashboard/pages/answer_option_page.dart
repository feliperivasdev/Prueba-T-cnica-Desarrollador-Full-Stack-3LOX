import 'package:flutter/material.dart';
import '../services/answer_option_service.dart';
import 'create_answer_option_page.dart';
import 'edit_answer_option_page.dart';
import 'dart:html' as html;

class AnswerOptionPage extends StatefulWidget {
  final int questionId;
  final String questionText;

  const AnswerOptionPage({
    super.key,
    required this.questionId,
    required this.questionText,
  });

  @override
  State<AnswerOptionPage> createState() => _AnswerOptionPageState();
}

class _AnswerOptionPageState extends State<AnswerOptionPage> {
  final AnswerOptionService _answerOptionService = AnswerOptionService();
  late Future<List<Map<String, dynamic>>> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  void _loadOptions() {
    _optionsFuture = _answerOptionService.fetchAnswerOptionsByQuestionId(widget.questionId);
  }

  @override
  Widget build(BuildContext context) {
    final userRole = html.window.localStorage['user_type'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Opciones de Respuesta'),
      ),
      floatingActionButton: (userRole == 'admin')
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAnswerOptionPage(questionId: widget.questionId),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _loadOptions();
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.questionText,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _optionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final options = snapshot.data ?? [];
                if (options.isEmpty) {
                  return const Center(child: Text('No hay opciones de respuesta disponibles'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(option['text'] ?? 'Sin texto'),
                        subtitle: Text('Valor: ${option['value']}'),
                        trailing: (userRole == 'admin')
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Confirmar eliminación'),
                                          content: const Text('¿Estás seguro de que deseas eliminar esta opción?'),
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
                                          await _answerOptionService.deleteAnswerOption(option['id']);
                                          setState(() {
                                            _loadOptions();
                                          });
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Opción de respuesta borrada correctamente')),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al eliminar la opción: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 