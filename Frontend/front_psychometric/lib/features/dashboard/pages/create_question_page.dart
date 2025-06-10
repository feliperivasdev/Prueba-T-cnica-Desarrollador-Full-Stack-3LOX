import 'package:flutter/material.dart';
import '../services/question_service.dart';
import 'dart:html' as html;

class CreateQuestionPage extends StatefulWidget {
  final int blockId;
  final int orderNumber;

  const CreateQuestionPage({
    super.key,
    required this.blockId,
    required this.orderNumber,
  });

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _loading = false;
  String? _error;

  final QuestionService _questionService = QuestionService();

  @override
  Widget build(BuildContext context) {
    final role = html.window.localStorage['user_type'] ?? '';

    if (role != 'corporate' && role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Pregunta')),
        body: const Center(child: Text('No tienes permisos para crear una pregunta.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Pregunta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Texto de la Pregunta',
                  hintText: 'Ingrese el texto de la pregunta',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                maxLines: 3,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        try {
                          final createdQuestion = await _questionService.createQuestion(
                            text: _textController.text.trim(),
                            blockId: widget.blockId,
                            orderNumber: widget.orderNumber,
                          );
                          
                          if (!createdQuestion.containsKey('id')) {
                            throw Exception('No se pudo obtener el ID de la pregunta creada');
                          }

                          if (mounted) {
                            Navigator.pop(context, createdQuestion);
                          }
                        } catch (e) {
                          setState(() {
                            _error = e.toString();
                          });
                        } finally {
                          setState(() {
                            _loading = false;
                          });
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Crear Pregunta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
