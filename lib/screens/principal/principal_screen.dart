import 'package:flutter/material.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega os dados do usuário passados pela rota
    final usuario = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do usuário
            Text(
              'Olá, ${usuario['nome']}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Saldo
            const Text('Saldo disponível', style: TextStyle(fontSize: 16)),
            const Text(
              'R\$ 1.500,00',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 40),

            // Botões de navegação
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.attach_money),
                label: const Text('Cotação'),
                onPressed: () {
                  Navigator.pushNamed(context, '/cotacao');
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Transferência'),
                onPressed: () {
                  Navigator.pushNamed(context, '/transferencia');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}