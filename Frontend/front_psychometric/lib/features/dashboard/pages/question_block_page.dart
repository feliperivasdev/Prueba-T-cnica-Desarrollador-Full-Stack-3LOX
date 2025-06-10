import 'package:flutter/material.dart';
import '../services/question_block_service.dart';
import 'question_page.dart';
import 'create_question_block.dart';
import 'edit_question_block_page.dart';
import 'dart:html' as html;

class QuestionBlockPage extends StatefulWidget {
  final int testId;
  final String testName;

  const QuestionBlockPage({super.key, required this.testId, required this.testName});

  @override
  State<QuestionBlockPage> createState() => _QuestionBlockPageState();
}

class _QuestionBlockPageState extends State<QuestionBlockPage> {
  final service = QuestionBlockService();
  List<Map<String, dynamic>> blocks = [];

  void _loadQuestionBlocks() async {
    try {
      final blocks = await service.fetchBlocksByTestId(widget.testId);
      setState(() {
        this.blocks = blocks;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los bloques: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuestionBlocks();
  }

  @override
  Widget build(BuildContext context) {
    final role = html.window.localStorage['user_type'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bloques de "${widget.testName}"'),
      ),
      body: Column(
        children: [
          if (role == 'corporate' || role == 'admin')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Bloque'),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateQuestionBlockPage(
                          testId: widget.testId,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {}); // Refrescar la lista de bloques
                    }
                  },
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: service.fetchBlocksByTestId(widget.testId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final blocks = snapshot.data ?? [];
                if (blocks.isEmpty) {
                  return const Center(child: Text('No hay bloques para este test.'));
                }
                return ListView.builder(
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    return _buildQuestionBlockCard(block);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBlockCard(Map<String, dynamic> block) {
    final role = html.window.localStorage['user_type'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(child: Text('${block['orderNumber']}')),
        title: Text(block['title'] ?? ''),
        subtitle: Text(block['description'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (role == 'corporate' || role == 'admin') ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditQuestionBlockPage(block: block),
                    ),
                  );
                  if (result == true) {
                    _loadQuestionBlocks();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Estás seguro de que deseas eliminar este bloque de preguntas?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await service.deleteQuestionBlock(block['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bloque eliminado exitosamente')),
                      );
                      _loadQuestionBlocks();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar el bloque: $e')),
                      );
                    }
                  }
                },
              ),
            ],
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(
                      blocks: [block],
                      currentBlockIndex: 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}