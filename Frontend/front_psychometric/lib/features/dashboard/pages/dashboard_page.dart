import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/test_service.dart';
import 'dart:html' as html;
import 'question_block_page.dart';
import 'create_test_page.dart'; // Asegúrate de importar la página para crear test
import 'test_page.dart';
import 'user_page.dart';

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
    if (_selectedSection == DashboardSection.tests) {
      return TestPage();
    }
    if (_selectedSection == DashboardSection.users) {
      return UserPage();
    }

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
      default:
        return const Center(child: Text('Funcionalidad próximamente'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = (html.window.localStorage['first_name'] ?? 'Usuario');
    final userRole = (html.window.localStorage['user_type'] ?? '').toLowerCase();
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
            if (userRole == 'corporate' || userRole == 'admin')
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.users),
                title: const Text('Usuarios'),
                selected: _selectedSection == DashboardSection.users,
                onTap: () {
                  setState(() {
                    _selectedSection = DashboardSection.users;
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