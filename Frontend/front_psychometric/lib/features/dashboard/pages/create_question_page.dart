import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/answer_option_service.dart';

class CreateQuestionPage extends StatefulWidget {
  final int blockId;

  const CreateQuestionPage({
    super.key,
    required this.blockId,
  });

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _questionService = QuestionService();
  final _answerOptionService = AnswerOptionService();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _createQuestion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final questionData = {
          "questionBlockId": widget.blockId,
          "text": _textController.text,
          "type": "Likert",
          "orderNumber": 1, // TODO: Implementar orden dinámico
        };

        final createdQuestion = await _questionService.createQuestion(questionData);
        
        // Crear opciones de respuesta por defecto
        await _answerOptionService.createDefaultOptions(createdQuestion['id']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pregunta creada exitosamente')),
          );
          Navigator.pop(context, createdQuestion);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la pregunta: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Pregunta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Texto de la Pregunta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el texto de la pregunta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createQuestion,
                child: const Text('Crear Pregunta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
