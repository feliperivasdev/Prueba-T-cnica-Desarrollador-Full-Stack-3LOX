import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/test_service.dart';
import 'dart:html' as html;

enum DashboardSection {
  bienvenida,
  tests,
  questionBlocks,
  questions,
  answerOptions,
  users,
  userResponses,
  blockResults,
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardSection _selectedSection = DashboardSection.bienvenida;
  final TestService _testService = TestService();

  Widget _buildContent() {
    switch (_selectedSection) {
      case DashboardSection.bienvenida:
        final nombre = Uri.decodeComponent(
            (html.window.localStorage['first_name'] ?? 'Usuario'));
        return Center(
          child: Text(
            '¡Bienvenido, $nombre!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        );
      case DashboardSection.tests:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _testService.fetchTests(),
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
                    leading: const FaIcon(FontAwesomeIcons.clipboardList),
                    title: Text(test['name'] ?? 'Sin título'),
                    subtitle: Text(test['description'] ?? ''),
                  ),
                );
              },
            );
          },
        );
      // Aquí puedes agregar más casos para las otras secciones, usando sus servicios
      default:
        return const Center(child: Text('Funcionalidad próximamente'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = (html.window.localStorage['first_name'] ?? 'Usuario');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.userCircle, size: 48, color: Colors.white),
                  const SizedBox(width: 16),
                  Text(
                    nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.house),
              title: const Text('Bienvenida'),
              selected: _selectedSection == DashboardSection.bienvenida,
              onTap: () {
                setState(() {
                  _selectedSection = DashboardSection.bienvenida;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.clipboardList),
              title: const Text('Tests'),
              selected: _selectedSection == DashboardSection.tests,
              onTap: () {
                setState(() {
                  _selectedSection = DashboardSection.tests;
                });
                Navigator.pop(context);
              },
            ),
            // ...agrega más opciones con FaIcon
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }
}