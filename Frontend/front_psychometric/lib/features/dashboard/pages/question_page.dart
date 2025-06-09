import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/answer_option_service.dart';
import '../services/user_response_service.dart';
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
    final blockId = widget.blocks[widget.currentBlockIndex]['id'];
    _questionsFuture = _questionService.fetchQuestionsByBlockId(blockId);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloque: ${block['title']}'),
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
          _questionsCount = questions.length;
          if (questions.isEmpty) {
            return const Center(child: Text('No hay preguntas disponibles.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${question['orderNumber']}. ${question['text']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _answerOptionService.fetchOptionsByQuestionId(question['id']),
                              builder: (context, optionSnapshot) {
                                if (optionSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: LinearProgressIndicator(),
                                  );
                                }
                                if (optionSnapshot.hasError) {
                                  return Text('Error: ${optionSnapshot.error}');
                                }
                                final options = optionSnapshot.data ?? [];
                                if (options.isEmpty) {
                                  return const Text('No hay opciones de respuesta.');
                                }
                                return Column(
                                  children: options.map((option) {
                                    return RadioListTile<int>(
                                      title: Text(option['text']),
                                      value: option['id'],
                                      groupValue: _selectedOptions[question['id']],
                                      onChanged: (value) async {
                                        setState(() {
                                          _selectedOptions[question['id']] = value!;
                                        });
                                        await _saveResponse(
                                          question['id'],
                                          option['id'],
                                          option['value'],
                                        );
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
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    widget.currentBlockIndex + 1 < widget.blocks.length
                        ? 'Siguiente bloque'
                        : 'Finalizar',
                  ),
                  onPressed: _onNextBlock,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
