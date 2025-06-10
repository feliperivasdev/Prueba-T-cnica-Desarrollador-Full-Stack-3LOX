import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/question_service.dart';
import '../services/user_response_service.dart';
import '../services/block_result_service.dart';

class QuestionPage extends StatefulWidget {
  final int blockId;
  final String blockTitle;
  final String blockDescription;

  const QuestionPage({
    Key? key,
    required this.blockId,
    required this.blockTitle,
    required this.blockDescription,
  }) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final QuestionService _questionService = QuestionService();
  final UserResponseService _userResponseService = UserResponseService();
  final BlockResultService _blockResultService = BlockResultService();
  List<Map<String, dynamic>> _questions = [];
  Map<int, int> _responses = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final questions = await _questionService.fetchQuestionsByBlock(widget.blockId);
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBlockResponses() async {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay preguntas para responder')),
      );
      return;
    }

    // Verificar que todas las preguntas tengan respuesta
    for (var question in _questions) {
      if (!_responses.containsKey(question['id'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor responde todas las preguntas')),
        );
        return;
      }
    }

    try {
      // Guardar cada respuesta
      for (var entry in _responses.entries) {
        await _userResponseService.saveUserResponse(
          questionId: entry.key,
          answerOptionId: entry.value,
          responseValue: entry.value,
        );
      }

      // Calcular y guardar el resultado del bloque
      final totalScore = _responses.values.fold(0.0, (sum, value) => sum + value.toDouble());
      final averageScore = totalScore / _responses.length;

      await _blockResultService.saveBlockResult(
        blockId: widget.blockId,
        totalScore: totalScore,
        averageScore: averageScore,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuestas guardadas correctamente')),
        );
        Navigator.pop(context, true); // Retornar true para indicar que se completó el bloque
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar las respuestas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _questions.isEmpty
                  ? const Center(child: Text('No hay preguntas disponibles'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.blockDescription,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          ..._questions.map((question) => _buildQuestionCard(question)),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: _submitBlockResponses,
                              child: const Text('Enviar Respuestas'),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final value = index + 1;
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _responses[question['id']] = value;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _responses[question['id']] == value
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  child: Text(value.toString()),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
