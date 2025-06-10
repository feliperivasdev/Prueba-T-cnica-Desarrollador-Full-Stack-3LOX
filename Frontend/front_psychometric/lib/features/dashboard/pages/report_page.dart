import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/block_result_service.dart';
import '../services/block_service.dart';
import '../services/test_service.dart';
import 'dart:html' as html;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final UserService _userService = UserService();
  final BlockResultService _blockResultService = BlockResultService();
  final BlockService _blockService = BlockService();
  final TestService _testService = TestService();
  late Future<List<Map<String, dynamic>>> _usersFuture;
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _selectedUser;
  List<Map<String, dynamic>> _blockResults = [];
  String userRole = '';
  bool _showGraph = true;

  @override
  void initState() {
    super.initState();
    userRole = html.window.localStorage['user_type'] ?? '';
    _usersFuture = _userService.fetchUsers();
  }

  Future<void> _loadUserResults(int userId) async {
    try {
      final results = await _blockResultService.getBlockResultsReport();
      setState(() {
        _blockResults = results.where((result) => result['userId'] == userId).toList();
      });
    } catch (e) {
      print('Error al obtener los resultados: $e');
    }
  }

  Future<List<Map<String, dynamic>>> enrichResultsWithTestName(List<Map<String, dynamic>> results) async {
    final Map<int, String> testNameCache = {};
    final Map<int, int> blockTestCache = {};
    final Map<int, String> blockNameCache = {};
    final tests = await _testService.fetchTests();
    for (var result in results) {
      final blockId = result['blockId'];
      if (blockId == null) continue;
      int? testId = blockTestCache[blockId];
      String? blockName = blockNameCache[blockId];
      if (testId == null || blockName == null) {
        final block = await _blockService.fetchBlockById(blockId);
        testId = block['testId'];
        blockName = block['title'] ?? 'Bloque desconocido';
        if (testId != null) {
          blockTestCache[blockId] = testId;
        }
        blockNameCache[blockId] = blockName ?? 'Bloque desconocido';
      }
      if (testId == null) {
        result['testName'] = 'Sin nombre';
        result['blockName'] = blockName ?? 'Bloque desconocido';
        continue;
      }
      String? testName = testNameCache[testId];
      if (testName == null) {
        final found = tests.firstWhere(
          (t) => t['id'] == testId,
          orElse: () => {'name': 'Sin nombre'},
        );
        testName = found['name'] ?? 'Sin nombre';
        testNameCache[testId] = testName ?? 'Sin nombre';
      }
      result['testName'] = testName;
      result['blockName'] = blockName ?? 'Bloque desconocido';
    }
    return results;
  }

  Widget _buildResultsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Bloque')),
          DataColumn(label: Text('Puntuación Total')),
          DataColumn(label: Text('Promedio')),
          DataColumn(label: Text('Fecha')),
        ],
        rows: _blockResults.map((result) {
          return DataRow(
            cells: [
              DataCell(Text(result['blockName'] ?? '')),
              DataCell(Text(result['totalScore'].toString())),
              DataCell(Text(result['averageScore'].toStringAsFixed(2))),
              DataCell(Text(DateTime.parse(result['completedAt']).toLocal().toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsGraph() {
    if (_blockResults.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    // Agrupar resultados por bloque
    final Map<String, List<double>> blockAverages = {};
    for (var result in _blockResults) {
      final blockName = result['blockName'] ?? 'Sin nombre';
      if (!blockAverages.containsKey(blockName)) {
        blockAverages[blockName] = [];
      }
      blockAverages[blockName]!.add(result['averageScore']);
    }

    // Calcular promedio por bloque
    final List<MapEntry<String, double>> blockData = blockAverages.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, average);
    }).toList();

    return ListView.builder(
      itemCount: blockData.length,
      itemBuilder: (context, index) {
        final entry = blockData[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: entry.value / 5, // Asumiendo que el máximo es 5
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    entry.value >= 4 ? Colors.green :
                    entry.value >= 3 ? Colors.blue :
                    entry.value >= 2 ? Colors.orange :
                    Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Promedio: ${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == 'assessment') {
      final userId = int.tryParse(html.window.localStorage['user_id'] ?? '');
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _blockResultService.getBlockResultsReport().then((results) => enrichResultsWithTestName(results.where((r) => r['userId'] == userId).toList())),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final myResults = snapshot.data ?? [];
          if (myResults.isEmpty) {
            return const Center(child: Text('Aún no tienes resultados para mostrar.'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Resultados',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text('Vista: '),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Gráfica'),
                          selected: _showGraph,
                          onSelected: (selected) {
                            setState(() {
                              _showGraph = selected;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Tabla'),
                          selected: !_showGraph,
                          onSelected: (selected) {
                            setState(() {
                              _showGraph = !selected;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _showGraph
                      ? _buildResultsGraphCustom(myResults)
                      : _buildResultsTableCustom(myResults),
                ),
              ),
            ],
          );
        },
      );
    }

    if (userRole != 'corporate' && userRole != 'admin') {
      return const Center(child: Text('No tienes permisos para ver reportes.'));
    }

    return Row(
      children: [
        // Lista de usuarios
        Expanded(
          flex: 2,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              _users = (snapshot.data ?? []).where((u) => u['userType'] == 'assessment').toList();
              if (_users.isEmpty) {
                return const Center(child: Text('No hay usuarios assessment.'));
              }
              return ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text('${user['firstName']} ${user['lastName']}'),
                    subtitle: Text(user['email'] ?? ''),
                    selected: _selectedUser?['id'] == user['id'],
                    onTap: () {
                      setState(() {
                        _selectedUser = user;
                        _blockResults = [];
                      });
                      _loadUserResults(user['id']);
                    },
                  );
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        // Resultados del usuario seleccionado
        Expanded(
          flex: 3,
          child: _selectedUser == null
              ? const Center(child: Text('Selecciona un usuario para ver sus resultados'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: _blockResultService.getBlockResultsReport().then((results) => enrichResultsWithTestName(results.where((r) => r['userId'] == _selectedUser!['id']).toList())),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final userResults = snapshot.data ?? [];
                    if (userResults.isEmpty) {
                      return const Center(child: Text('No hay resultados para mostrar'));
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Resultados de ${_selectedUser!['firstName']} ${_selectedUser!['lastName']}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  const Text('Vista: '),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Gráfica'),
                                    selected: _showGraph,
                                    onSelected: (selected) {
                                      setState(() {
                                        _showGraph = selected;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Tabla'),
                                    selected: !_showGraph,
                                    onSelected: (selected) {
                                      setState(() {
                                        _showGraph = !selected;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _showGraph
                                ? _buildResultsGraphCustom(userResults)
                                : _buildResultsTableCustom(userResults),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResultsTableCustom(List<Map<String, dynamic>> results) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.only(left: 100),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Bloque')),
            DataColumn(label: Text('Puntuación Total')),
            DataColumn(label: Text('Promedio')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Test')),
          ],
          rows: results.map((result) {
            final fecha = DateTime.parse(result['completedAt']).toLocal();
            final fechaStr = '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
            return DataRow(
              cells: [
                DataCell(Text(result['blockName'] ?? 'Bloque desconocido')),
                DataCell(Text(result['totalScore'].toString())),
                DataCell(Text(result['averageScore'].toStringAsFixed(2))),
                DataCell(Text(fechaStr)),
                DataCell(Text(result['testName'] ?? '')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsGraphCustom(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }
    final testName = results.first['testName'] ?? 'Test sin nombre';
    final Map<String, List<double>> blockAverages = {};
    for (var result in results) {
      final blockName = result['blockName'] ?? 'Sin nombre';
      if (!blockAverages.containsKey(blockName)) {
        blockAverages[blockName] = [];
      }
      blockAverages[blockName]!.add(result['averageScore']);
    }
    final List<MapEntry<String, double>> blockData = blockAverages.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return MapEntry(entry.key, average);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test: $testName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: blockData.length,
            itemBuilder: (context, index) {
              final entry = blockData[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: entry.value / 5, // Asumiendo que el máximo es 5
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          entry.value >= 4 ? Colors.green :
                          entry.value >= 3 ? Colors.blue :
                          entry.value >= 2 ? Colors.orange :
                          Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Promedio: ${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 