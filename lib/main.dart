import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart';
import 'services/database.dart';

Map<String, dynamic>? usuarioLogado;

final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final usuarioId = prefs.getInt('usuarioId');

  final temaSalvo = prefs.getString('tema');

  if (temaSalvo == 'dark') {
    temaNotifier.value = ThemeMode.dark;
  } else {
    temaNotifier.value = ThemeMode.light;
  }

  if (usuarioId != null) {
    usuarioLogado = await DatabaseService.instance.buscarUsuarioPorId(
      usuarioId,
    );
  }

  runApp(const MyApp());
}

Future<void> alternarTema() async {
  final prefs = await SharedPreferences.getInstance();

  if (temaNotifier.value == ThemeMode.dark) {
    temaNotifier.value = ThemeMode.light;
    await prefs.setString('tema', 'light');
  } else {
    temaNotifier.value = ThemeMode.dark;
    await prefs.setString('tema', 'dark');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _gerarRotas(RouteSettings settings) {
    return AppRoutes.gerarRotas(settings, usuarioLogado: usuarioLogado);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, temaAtual, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NexBank',

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF3F6FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1),
              foregroundColor: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D47A1),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF0A0A0A),
              foregroundColor: Colors.white,
            ),
            cardColor: Color(0xFF1E1E1E),
          ),

          themeMode: temaAtual,

          initialRoute: usuarioLogado != null
              ? AppRoutes.principal
              : AppRoutes.login,

          onGenerateRoute: _gerarRotas,
        );
      },
    );
  }
}
