import 'package:flutter/material.dart';
import '../services/test_service.dart';
import 'question_block_page.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TestService _testService = TestService();
  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final tests = await _testService.fetchTests();
      
      setState(() {
        _tests = tests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToQuestionBlockPage(Map<String, dynamic> test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionBlockPage(
          testId: test['id'],
          testTitle: test['name'] ?? 'Test',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests Disponibles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _tests.isEmpty
                  ? const Center(child: Text('No hay tests disponibles'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _tests.length,
                      itemBuilder: (context, index) {
                        final test = _tests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            title: Text(test['name'] ?? 'Test ${index + 1}'),
                            subtitle: Text(test['description'] ?? ''),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToQuestionBlockPage(test),
                          ),
                        );
                      },
                    ),
    );
  }
} 