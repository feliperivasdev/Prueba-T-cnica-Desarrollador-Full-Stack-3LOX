import 'package:flutter/material.dart';
import 'features/auth/pages/login_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Psicometría Web',
    theme: ThemeData(primarySwatch: Colors.indigo),
    initialRoute: '/login',
    routes: {
      '/login': (context) => const LoginPage(),
      '/dashboard': (context) => const DashboardPage(),
      
    },
  ));
}
