import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaldoCard extends StatelessWidget {
  final double saldo;
  final bool mostrarSaldo;
  final VoidCallback onToggleSaldo;

  const SaldoCard({
    super.key,
    required this.saldo,
    required this.mostrarSaldo,
    required this.onToggleSaldo,
  });

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponível',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            mostrarSaldo ? moeda.format(saldo) : 'R\$ ••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          IconButton(
            onPressed: onToggleSaldo,
            icon: Icon(
              mostrarSaldo ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
