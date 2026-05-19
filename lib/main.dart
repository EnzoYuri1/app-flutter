import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/transferencia/transferencia_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banco Digital',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      routes: {
        ...AppRoutes.routes,
        '/transferencia': (context) => TransferenciaScreen(),
      },

      initialRoute: AppRoutes.login,
    );
  }
}