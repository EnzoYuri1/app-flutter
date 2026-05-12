import 'package:flutter/material.dart';

import '../screens/login/login_screen.dart';
import '../screens//login/register_screen.dart';

class AppRoutes {

  static const String login = '/login';
  static const String register = '/register';

  //mapa de rotas do app.
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
  };
}