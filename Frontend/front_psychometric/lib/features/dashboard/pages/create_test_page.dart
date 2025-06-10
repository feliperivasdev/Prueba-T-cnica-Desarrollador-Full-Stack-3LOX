import 'package:flutter/material.dart';
import '../services/test_service.dart';
import 'dart:html' as html;

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isActive = true;
  bool _loading = false;
  String? _error;

  final TestService _testService = TestService();

  @override
  Widget build(BuildContext context) {
    final role = html.window.localStorage['user_type'] ?? '';
    final userId = int.tryParse(html.window.localStorage['user_id'] ?? '0') ?? 0;

    if (role != 'corporate' && role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Crear Test')),
        body: const Center(child: Text('No tienes permisos para crear un test.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              SwitchListTile(
                title: const Text('Activo'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
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
                          await _testService.createTest(
                            name: _nameController.text.trim(),
                            description: _descController.text.trim(),
                            isActive: _isActive,
                          );
                          if (mounted) {
                            Navigator.pop(context, true);
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
                    : const Text('Crear Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}