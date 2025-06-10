import 'package:flutter/material.dart';
import '../services/block_service.dart';

class CreateBlockPage extends StatefulWidget {
  final int testId;

  const CreateBlockPage({
    super.key,
    required this.testId,
  });

  @override
  State<CreateBlockPage> createState() => _CreateBlockPageState();
}

class _CreateBlockPageState extends State<CreateBlockPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderNumberController = TextEditingController();
  final _blockService = BlockService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  Future<void> _createBlock() async {
    if (_formKey.currentState!.validate()) {
      try {
        final blockData = {
          "name": _nameController.text,
          "description": _descriptionController.text,
          "orderNumber": int.parse(_orderNumberController.text),
          "testId": widget.testId,
        };

        final createdBlock = await _blockService.createBlock(blockData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bloque creado exitosamente')),
          );
          Navigator.pop(context, createdBlock);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el bloque: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Bloque'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Bloque',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Orden',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un número de orden';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createBlock,
                child: const Text('Crear Bloque'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 