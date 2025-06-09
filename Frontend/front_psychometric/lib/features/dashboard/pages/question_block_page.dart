import 'package:flutter/material.dart';
import '../services/question_block_service.dart';
import 'question_page.dart';

class QuestionBlockPage extends StatelessWidget {
  final int testId;
  final String testName;

  const QuestionBlockPage({super.key, required this.testId, required this.testName});

  @override
  Widget build(BuildContext context) {
    final service = QuestionBlockService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bloques de "$testName"'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.fetchBlocksByTestId(testId),
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${block['orderNumber']}')),
                  title: Text(block['title'] ?? ''),
                  subtitle: Text(block['description'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionPage(
                          blocks: blocks,
                          currentBlockIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}