import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../pages/test_page.dart';
import '../pages/report_page.dart';
import '../pages/question_block_page.dart';
import '../pages/question_page.dart';
import '../pages/answer_option_page.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  @override
  Widget build(BuildContext context) {
    final userRole = _getUserRole();
    final isAdmin = userRole == 'admin';
    final isCorporate = userRole == 'corporate';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú Principal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          if (isAdmin || isCorporate) ...[
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Tests'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Bloques de Preguntas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionBlockPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('Preguntas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Opciones de Respuesta'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnswerOptionPage()),
                );
              },
            ),
          ],
          if (isAdmin || isCorporate)
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reportes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              html.window.localStorage.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
} 