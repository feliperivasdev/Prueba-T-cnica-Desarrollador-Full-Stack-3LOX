import 'package:flutter/material.dart';
import '../services/question_service.dart';
import 'create_question_page.dart';
import 'answer_option_page.dart';

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
  late Future<List<Map<String, dynamic>>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questionsFuture = _questionService.fetchQuestionsByBlockId(widget.blockId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockName),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
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
                  trailing: Row(
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
