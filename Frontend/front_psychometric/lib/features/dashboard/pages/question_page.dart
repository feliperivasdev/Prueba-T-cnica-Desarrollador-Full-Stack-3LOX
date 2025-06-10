import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/answer_option_service.dart';
import '../services/user_response_service.dart';
import 'create_question_page.dart';
import 'edit_question_page.dart';
import 'dart:html' as html;

class QuestionPage extends StatefulWidget {
  final List<Map<String, dynamic>> blocks;
  final int currentBlockIndex;

  const QuestionPage({
    super.key,
    required this.blocks,
    required this.currentBlockIndex,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final QuestionService _questionService = QuestionService();
  final AnswerOptionService _answerOptionService = AnswerOptionService();
  final UserResponseService _userResponseService = UserResponseService();

  late Future<List<Map<String, dynamic>>> _questionsFuture;
  final Map<int, int> _selectedOptions = {}; // questionId -> answerOptionId

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final blockId = widget.blocks[widget.currentBlockIndex]['id'];
    setState(() {
      _questionsFuture = _questionService.fetchQuestionsByBlockId(blockId);
    });
  }

  Future<void> _saveResponse(int questionId, int answerOptionId, int responseValue) async {
    final userId = int.tryParse(html.window.localStorage['user_id'] ?? '0') ?? 0;
    await _userResponseService.saveUserResponse(
      userId: userId,
      questionId: questionId,
      answerOptionId: answerOptionId,
      responseValue: responseValue,
    );
  }

  void _onNextBlock() {
    if (_selectedOptions.length < _questionsCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responde todas las preguntas antes de continuar.')),
      );
      return;
    }
    if (widget.currentBlockIndex + 1 < widget.blocks.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionPage(
            blocks: widget.blocks,
            currentBlockIndex: widget.currentBlockIndex + 1,
          ),
        ),
      );
    } else {
      // Fin del test
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Test completado!'),
          content: const Text('Has respondido todas las preguntas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Regresa al dashboard
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  int _questionsCount = 0;

  @override
  Widget build(BuildContext context) {
    final block = widget.blocks[widget.currentBlockIndex];
    final role = html.window.localStorage['user_type'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bloque: ${block['title']}'),
      ),
      body: Column(
        children: [
          if (role == 'corporate' || role == 'admin')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Pregunta'),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateQuestionPage(
                          blockId: block['id'],
                          orderNumber: _questionsCount + 1,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadQuestions();
                    }
                  },
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final questions = snapshot.data ?? [];
                _questionsCount = questions.length;
                if (questions.isEmpty) {
                  return const Center(child: Text('No hay preguntas disponibles.'));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: questions.map((question) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    question['text'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (role == 'corporate' || role == 'admin')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditQuestionPage(question: question),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadQuestions();
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
                                              content: const Text('¿Estás seguro de que deseas eliminar esta pregunta?'),
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
                                              await _questionService.deleteQuestion(question['id']);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Pregunta eliminada exitosamente')),
                                              );
                                              _loadQuestions();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error al eliminar la pregunta: $e')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _answerOptionService.fetchOptionsByQuestionId(question['id']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final options = snapshot.data ?? [];
                                if (options.isEmpty) {
                                  return Column(
                                    children: [
                                      const Text('No hay opciones disponibles'),
                                      if (role == 'corporate' || role == 'admin')
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.add),
                                            label: const Text('Agregar Opciones de Respuesta'),
                                            onPressed: () async {
                                              try {
                                                await _answerOptionService.createDefaultOptions(question['id']);
                                                _loadQuestions();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Opciones de respuesta creadas exitosamente'),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error al crear las opciones: $e'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: options.map((option) {
                                    return RadioListTile<int>(
                                      title: Text(option['text'] ?? ''),
                                      value: option['value'] ?? 0,
                                      groupValue: _selectedOptions[question['id']],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedOptions[question['id']] = value;
                                          });
                                          _saveResponse(
                                            question['id'],
                                            option['id'],
                                            value,
                                          );
                                        }
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
