import 'package:flutter/material.dart';
import 'package:gasapp/services/autenticacao.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final AuthenticationService authService = AuthenticationService();

  Future<void> registrar() async {
    String nome = nomeController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    bool sucesso = await authService.register(nome, email, senha);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conta criada com sucesso!")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao criar conta")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: registrar,
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}