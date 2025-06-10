import 'package:flutter/material.dart';
import 'dart:html' as html;

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  String? _getUserRole() {
    return html.window.localStorage['user_type'];
  }

  bool _isCorporate() {
    return _getUserRole() == 'corporate';
  }

  bool _isAssessment() {
    return _getUserRole() == 'assessment';
  }

  @override
  Widget build(BuildContext context) {
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
          if (_isCorporate()) ...[
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reportes Completos'),
              onTap: () {
                // Navegar a la vista de reportes completos
                Navigator.pushNamed(context, '/reports');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Resultados de Bloques'),
              onTap: () {
                // Navegar a la vista de resultados de bloques
                Navigator.pushNamed(context, '/block-results');
              },
            ),
          ],
          if (_isAssessment()) ...[
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Mis Respuestas'),
              onTap: () {
                // Navegar a la vista de respuestas del usuario
                Navigator.pushNamed(context, '/my-responses');
              },
            ),
          ],
        ],
      ),
    );
  }
} 