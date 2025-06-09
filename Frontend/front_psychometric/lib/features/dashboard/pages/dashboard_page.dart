import 'package:flutter/material.dart';
import '../services/test_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Map<String, dynamic>>> _testsFuture;
  final TestService _testService = TestService();

  @override
  void initState() {
    super.initState();
    _testsFuture = _testService.fetchTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _testsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final tests = snapshot.data ?? [];
            if (tests.isEmpty) {
              return const Center(child: Text('No hay tests disponibles.'));
            }
            return ListView.builder(
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text(test['name'] ?? 'Sin título'),
                    subtitle: Text(test['description'] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}