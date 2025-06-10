import 'package:flutter/material.dart';
import '../services/answer_option_service.dart';
import 'dart:html' as html;

class EditAnswerOptionPage extends StatefulWidget {
  final Map<String, dynamic> option;
  const EditAnswerOptionPage({super.key, required this.option});

  @override
  State<EditAnswerOptionPage> createState() => _EditAnswerOptionPageState();
}

class _EditAnswerOptionPageState extends State<EditAnswerOptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _valueController = TextEditingController();
  final AnswerOptionService _answerOptionService = AnswerOptionService();
  bool _isLoading = false;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _textController.text = widget.option['text'] ?? '';
    _valueController.text = widget.option['value']?.toString() ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _updateOption() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _answerOptionService.updateAnswerOption(
        widget.option['id'],
        {
          "id": widget.option['id'],
          "questionId": widget.option['questionId'],
          "text": _textController.text,
          "value": int.parse(_valueController.text),
          "orderNumber": widget.option['orderNumber'],
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opción de respuesta actualizada exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la opción: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Opción de Respuesta')),
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
                  final intValue = int.tryParse(value);
                  if (intValue == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  if (intValue < 1 || intValue > 5) {
                    return 'El valor debe estar entre 1 y 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (userRole == 'admin' && !_isLoading) ? _updateOption : null,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 