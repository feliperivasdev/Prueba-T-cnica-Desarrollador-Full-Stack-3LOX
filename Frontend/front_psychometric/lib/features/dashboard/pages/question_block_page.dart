import 'package:flutter/material.dart';
import '../services/block_service.dart';
import 'question_page.dart';
import 'create_question_block.dart';
import 'edit_question_block_page.dart';
import 'dart:html' as html;

class QuestionBlockPage extends StatefulWidget {
  final int testId;
  final String testTitle;

  const QuestionBlockPage({
    Key? key,
    required this.testId,
    required this.testTitle,
  }) : super(key: key);

  @override
  State<QuestionBlockPage> createState() => _QuestionBlockPageState();
}

class _QuestionBlockPageState extends State<QuestionBlockPage> {
  final BlockService _blockService = BlockService();
  List<Map<String, dynamic>> _blocks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final blocks = await _blockService.fetchBlocksByTestId(widget.testId);
      
      setState(() {
        _blocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToQuestionPage(Map<String, dynamic> block) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionPage(
          blockId: block['id'],
          blockTitle: block['title'],
          blockDescription: block['description'],
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _blocks.isEmpty
                  ? const Center(child: Text('No hay bloques disponibles'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _blocks.length,
                      itemBuilder: (context, index) {
                        final block = _blocks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            title: Text(block['title']),
                            subtitle: Text(block['description']),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToQuestionPage(block),
                          ),
                        );
                      },
                    ),
    );
  }
}