import 'package:flutter/material.dart';
import '../services/answer_option_service.dart';

class CreateAnswerOptionPage extends StatefulWidget {
  final int questionId;

  const CreateAnswerOptionPage({
    super.key,
    required this.questionId,
  });

  @override
  State<CreateAnswerOptionPage> createState() => _CreateAnswerOptionPageState();
}

class _CreateAnswerOptionPageState extends State<CreateAnswerOptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _valueController = TextEditingController();
  final _answerOptionService = AnswerOptionService();

  @override
  void dispose() {
    _textController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _createAnswerOption() async {
    if (_formKey.currentState!.validate()) {
      try {
        final optionData = {
          "text": _textController.text,
          "value": int.parse(_valueController.text),
          "questionId": widget.questionId,
        };

        final createdOption = await _answerOptionService.createAnswerOption(optionData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opción de respuesta creada exitosamente')),
          );
          Navigator.pop(context, createdOption);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la opción de respuesta: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Opción de Respuesta'),
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
                  labelText: 'Texto de la Opción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el texto de la opción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un valor';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createAnswerOption,
                child: const Text('Crear Opción de Respuesta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 