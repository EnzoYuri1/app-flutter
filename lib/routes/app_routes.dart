import 'package:flutter/material.dart';

import '../screens/login/login_screen.dart';
import '../screens/login/register_screen.dart';
import '../screens/principal/principal_screen.dart';
import '../screens/transferencia/transferencia_screen.dart';

class AppRoutes {

  static const String login = '/login';
  static const String register = '/register';
  static const String principal = '/principal';
  static const String transferencia = '/transferencia';

  //mapa de rotas do app.
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    principal: (context) => const PrincipalScreen(),
    transferencia: (context) => TransferenciaScreen(),
  };
}