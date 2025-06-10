import 'package:flutter/material.dart';
import '../services/block_service.dart';
import 'question_page.dart';
import 'create_question_block.dart';
import 'edit_question_block_page.dart';
import 'dart:html' as html;
import 'create_block_page.dart';
import '../services/block_result_service.dart';

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
  final BlockResultService _blockResultService = BlockResultService();
  late Future<List<Map<String, dynamic>>> _blocksFuture;
  List<int> _completedBlockIds = [];
  bool _testCompleted = false;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _loadBlocks();
    if (userRole == 'assessment') {
      _loadCompletedBlocks();
    }
  }

  void _loadBlocks() {
    _blocksFuture = _blockService.fetchBlocksByTestId(widget.testId);
  }

  Future<void> _loadCompletedBlocks() async {
    try {
      final results = await _blockResultService.getBlockResultsReport();
      final userId = html.window.localStorage['user_id'];
      setState(() {
        _completedBlockIds = results
            .where((r) => r['userId'].toString() == userId)
            .map<int>((r) => r['blockId'] as int)
            .toList();
      });
    } catch (e) {
      // Manejo de error opcional
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = html.window.localStorage['user_type'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle),
      ),
      floatingActionButton: (userRole == 'corporate' || userRole == 'admin')
          ? FloatingActionButton(
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
            )
          : null,
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
          if (userRole == 'assessment') {
            final allCompleted = blocks.every((b) => _completedBlockIds.contains(b['id']));
            if (allCompleted && blocks.isNotEmpty) {
              return const Center(child: Text('¡Test completado! Has respondido todos los bloques.'));
            }
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final block = blocks[index];
              final isCompleted = _completedBlockIds.contains(block['id']);
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: (userRole == 'assessment' && isCompleted) ? Colors.grey[300] : null,
                child: ListTile(
                  title: Text(block['title'] ?? 'Sin nombre'),
                  subtitle: Text(block['description'] ?? 'Sin descripción'),
                  enabled: !(userRole == 'assessment' && isCompleted),
                  onTap: (userRole == 'assessment' && isCompleted)
                      ? null
                      : () async {
                          final completed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionPage(
                                blockId: block['id'],
                                blockName: block['title'],
                              ),
                            ),
                          );
                          if (completed == true) {
                            _loadCompletedBlocks();
                          }
                        },
                  trailing: (userRole == 'corporate' || userRole == 'admin')
                      ? Row(
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
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}