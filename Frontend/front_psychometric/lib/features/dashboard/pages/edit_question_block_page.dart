import 'package:flutter/material.dart';
import '../services/question_block_service.dart';

class EditQuestionBlockPage extends StatefulWidget {
  final Map<String, dynamic> block;

  const EditQuestionBlockPage({
    super.key,
    required this.block,
  });

  @override
  State<EditQuestionBlockPage> createState() => _EditQuestionBlockPageState();
}

class _EditQuestionBlockPageState extends State<EditQuestionBlockPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _questionBlockService = QuestionBlockService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.block['title'] ?? '';
    _descriptionController.text = widget.block['description'] ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateBlock() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _questionBlockService.updateQuestionBlock(
        id: widget.block['id'],
        title: _titleController.text,
        description: _descriptionController.text,
        testId: widget.block['testId'],
        orderNumber: widget.block['orderNumber'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloque actualizado exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el bloque: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Bloque de Preguntas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateBlock,
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