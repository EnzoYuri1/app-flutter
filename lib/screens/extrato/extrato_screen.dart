import 'package:flutter/material.dart';
import 'package:NexBank/services/database.dart';

class ExtratoScreen extends StatefulWidget {
  const ExtratoScreen({super.key});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  Map<String, dynamic>? usuario;

  String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatarData(String data) {
    final dateTime = DateTime.tryParse(data);
    if (dateTime == null) return data;

    final dia = dateTime.day.toString().padLeft(2, '0');
    final mes = dateTime.month.toString().padLeft(2, '0');
    final ano = dateTime.year.toString();
    final hora = dateTime.hour.toString().padLeft(2, '0');
    final minuto = dateTime.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    usuario ??=
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final usuarioId = usuario?['id'] as int?;

    return Scaffold(
      appBar: AppBar(title: const Text('Extrato'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.buscarHistorico(usuarioId: usuarioId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final historico = snapshot.data!;

          if (historico.isEmpty) {
            return const Center(
              child: Text('Nenhuma transferência encontrada.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final item = historico[index];
              final valor = (item['valor'] as num).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.arrow_upward, color: Colors.blue),
                  ),
                  title: Text(
                    'Transferência para ${item['destinatario']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(formatarData(item['data'])),
                  trailing: Text(
                    '- ${formatarMoeda(valor)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
