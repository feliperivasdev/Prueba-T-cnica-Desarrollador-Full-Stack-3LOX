import 'package:flutter/material.dart';
import '../services/block_service.dart';
import 'question_page.dart';
import 'create_question_block.dart';
import 'edit_question_block_page.dart';
import 'dart:html' as html;
import 'create_block_page.dart';

class QuestionBlockPage extends StatefulWidget {
  final int testId;
  final String testTitle;

  const QuestionBlockPage({
    super.key,
    required this.testId,
    required this.testTitle,
  });

  @override
  State<QuestionBlockPage> createState() => _QuestionBlockPageState();
}

class _QuestionBlockPageState extends State<QuestionBlockPage> {
  final BlockService _blockService = BlockService();
  late Future<List<Map<String, dynamic>>> _blocksFuture;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  void _loadBlocks() {
    _blocksFuture = _blockService.fetchBlocksByTestId(widget.testId);
  }

  void _navigateToQuestionPage(Map<String, dynamic> block) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionPage(
          blockId: block['id'],
          blockName: block['title'],
        ),
      ),
    ).then((completed) {
      if (completed == true) {
        // Si el bloque se completó, recargar la lista de bloques
        _loadBlocks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBlockPage(testId: widget.testId),
            ),
          );
          if (result != null) {
            setState(() {
              _loadBlocks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _blocksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final blocks = snapshot.data ?? [];
          if (blocks.isEmpty) {
            return const Center(child: Text('No hay bloques disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final block = blocks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(block['title'] ?? 'Sin nombre'),
                  subtitle: Text(block['description'] ?? 'Sin descripción'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionPage(
                          blockId: block['id'],
                          blockName: block['title'],
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implementar edición de bloque
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text('¿Estás seguro de que deseas eliminar este bloque?'),
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
                          if (confirm == true) {
                            try {
                              await _blockService.deleteBlock(block['id']);
                              setState(() {
                                _loadBlocks();
                              });
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar el bloque: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}