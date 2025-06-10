import 'package:flutter/material.dart';
import '../services/question_block_service.dart';
import 'dart:html' as html;

class CreateQuestionBlockPage extends StatefulWidget {
  final int testId;

  const CreateQuestionBlockPage({
    super.key,
    required this.testId,
  });

  @override
  State<CreateQuestionBlockPage> createState() => _CreateQuestionBlockPageState();
}

class _CreateQuestionBlockPageState extends State<CreateQuestionBlockPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _loading = false;
  String? _error;

  final QuestionBlockService _blockService = QuestionBlockService();

  @override
  Widget build(BuildContext context) {
    final role = html.window.localStorage['user_type'] ?? '';

    if (role != 'corporate' && role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Bloque de Preguntas')),
        body: const Center(child: Text('No tienes permisos para crear un bloque de preguntas.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Bloque de Preguntas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Bloque'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
                          final createdBlock = await _blockService.createQuestionBlock(
                            name: _nameController.text.trim(),
                            description: _descController.text.trim(),
                            testId: widget.testId,
                          );
                          
                          if (!createdBlock.containsKey('id')) {
                            throw Exception('No se pudo obtener el ID del bloque creado');
                          }

                          if (mounted) {
                            Navigator.pop(context, createdBlock);
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
                    : const Text('Crear Bloque'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
