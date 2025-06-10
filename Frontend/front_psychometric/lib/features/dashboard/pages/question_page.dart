import 'package:flutter/material.dart';
import '../services/question_service.dart';
import 'create_question_page.dart';
import 'answer_option_page.dart';
import 'dart:html' as html;
import '../services/user_response_service.dart';
import '../services/answer_option_service.dart';

class QuestionPage extends StatefulWidget {
  final int blockId;
  final String blockName;

  const QuestionPage({
    super.key,
    required this.blockId,
    required this.blockName,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final QuestionService _questionService = QuestionService();
  final UserResponseService _userResponseService = UserResponseService();
  final AnswerOptionService _answerOptionService = AnswerOptionService();
  late Future<List<Map<String, dynamic>>> _questionsFuture;
  Map<int, int> _selectedAnswers = {}; // questionId -> answerOptionId
  Map<int, int> _selectedValues = {}; // questionId -> value (1-5)
  bool _blockCompleted = false;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _loadQuestions();
  }

  void _loadQuestions() {
    _questionsFuture = _questionService.fetchQuestionsByBlockId(widget.blockId);
  }

  Future<List<Map<String, dynamic>>> _fetchOptions(int questionId) async {
    return await _answerOptionService.fetchAnswerOptionsByQuestionId(questionId);
  }

  Future<void> _submitBlockResponses(List<Map<String, dynamic>> questions) async {
    // Validar que todas las preguntas tengan respuesta
    if (_selectedAnswers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes responder todas las preguntas para continuar.')),
      );
      return;
    }
    try {
      for (final question in questions) {
        final questionId = question['id'];
        final answerOptionId = _selectedAnswers[questionId]!;
        final responseValue = _selectedValues[questionId]!;
        await _userResponseService.saveUserResponse(
          questionId: questionId,
          answerOptionId: answerOptionId,
          responseValue: responseValue, // Ahora sí es el valor 1-5
        );
      }
      setState(() {
        _blockCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bloque completado!')),
      );
      Navigator.pop(context, true); // Indica al bloque que se completó
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar respuestas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockName),
      ),
      floatingActionButton: (userRole == 'corporate' || userRole == 'admin')
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateQuestionPage(blockId: widget.blockId),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _loadQuestions();
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(child: Text('No hay preguntas disponibles'));
          }
          if (userRole == 'assessment') {
            if (_blockCompleted) {
              return const Center(child: Text('¡Bloque completado!'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchOptions(question['id']),
                        builder: (context, optSnapshot) {
                          if (optSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final options = optSnapshot.data ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(question['text'] ?? 'Sin texto', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...options.map<Widget>((option) => RadioListTile<int>(
                                        title: Text(option['text'] ?? ''),
                                        value: option['id'],
                                        groupValue: _selectedAnswers[question['id']],
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedAnswers[question['id']] = val!;
                                            // Guardar el value (1-5) correspondiente a la opción seleccionada
                                            final selectedOption = options.firstWhere((o) => o['id'] == val);
                                            _selectedValues[question['id']] = selectedOption['value'];
                                          });
                                        },
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _selectedAnswers.length == questions.length
                        ? () => _submitBlockResponses(questions)
                        : null,
                    child: const Text('Siguiente bloque'),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(question['text'] ?? 'Sin texto'),
                  subtitle: Text('Tipo: ${question['type']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnswerOptionPage(
                          questionId: question['id'],
                          questionText: question['text'],
                        ),
                      ),
                    );
                  },
                  trailing: (userRole == 'corporate' || userRole == 'admin')
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Implementar edición de pregunta
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
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
                                if (confirm == true) {
                                  try {
                                    await _questionService.deleteQuestion(question['id']);
                                    setState(() {
                                      _loadQuestions();
                                    });
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al eliminar la pregunta: $e')),
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
    );
  }
}
