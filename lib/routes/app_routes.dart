import 'package:flutter/material.dart';

import '../screens/cotacao/cotacao_screen.dart';
import '../screens/extrato/extrato_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/register_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/principal/principal_screen.dart';
import '../screens/transferencia/transferencia_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String principal = '/principal';
  static const String transferencia = '/transferencia';
  static const String cotacao = '/cotacao';
  static const String extrato = '/extrato';
  static const String perfil = '/perfil';

  static Route<dynamic> gerarRotas(
    RouteSettings settings, {
    Map<String, dynamic>? usuarioLogado,
  }) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case principal:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => PrincipalScreen(usuarioInicial: args ?? usuarioLogado),
        );

      case transferencia:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => const TransferenciaScreen(),
          settings: RouteSettings(arguments: args),
        );

      case cotacao:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case extrato:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => const ExtratoScreen(),
          settings: RouteSettings(arguments: args),
        );

      case perfil:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => const PerfilScreen(),
          settings: RouteSettings(arguments: args),
        );

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
