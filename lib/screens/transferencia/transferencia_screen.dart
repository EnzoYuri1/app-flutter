import 'package:flutter/material.dart';
import 'package:NexBank/services/database.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _valorController = TextEditingController();
  final _destinoController = TextEditingController();

  Map<String, dynamic>? usuario;
  bool transferiu = false;
  bool carregando = false;

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

  void _mensagem(String texto, {Color cor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmarAntesDeTransferir(double valor, String destino) async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar transferência'),
          content: Text(
            'Deseja transferir ${formatarMoeda(valor)} para $destino?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return resposta ?? false;
  }

  Future<void> _confirmarTransferencia() async {
    final usuarioAtual = usuario;

    if (usuarioAtual == null || usuarioAtual['id'] == null) {
      _mensagem('Não foi possível identificar o usuário logado.');
      return;
    }

    final String destino = _destinoController.text.trim();
    final valorTexto = _valorController.text.replaceAll(',', '.').trim();
    final double? valor = double.tryParse(valorTexto);
    final double saldoAtual = (usuarioAtual['saldo'] as num).toDouble();

    if (destino.isEmpty && (valorTexto.isEmpty || valor == null)) {
      _mensagem('Preencha o destinatário e o valor.');
      return;
    }

    if (destino.isEmpty) {
      _mensagem('Informe o destinatário.');
      return;
    }

    if (valorTexto.isEmpty) {
      _mensagem('Informe o valor da transferência.');
      return;
    }

    if (valor == null || valor <= 0) {
      _mensagem('Digite um valor válido.');
      return;
    }

    if (valor > saldoAtual) {
      _mensagem('Saldo insuficiente!');
      return;
    }

    final confirmar = await _confirmarAntesDeTransferir(valor, destino);
    if (!confirmar) return;

    setState(() {
      carregando = true;
    });

    try {
      final usuarioAtualizado = await DatabaseService.instance
          .registrarTransferencia(
            usuarioId: usuarioAtual['id'] as int,
            valor: valor,
            destinatario: destino,
          );

      if (!mounted) return;

      setState(() {
        usuario = usuarioAtualizado;
        transferiu = true;
        carregando = false;
      });

      _valorController.clear();
      _destinoController.clear();

      _mensagem(
        'Transferência de ${formatarMoeda(valor)} enviada com sucesso!',
        cor: Colors.green,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      _mensagem(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    usuario ??=
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final saldo = ((usuario?['saldo'] ?? 0) as num).toDouble();
    final usuarioId = usuario?['id'] as int?;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, transferiu ? usuario : null);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transferência'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, transferiu ? usuario : null);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Saldo atual: ${formatarMoeda(saldo)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _destinoController,
                decoration: const InputDecoration(
                  labelText: 'Nome do destinatário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: carregando ? null : _confirmarTransferencia,
                  child: carregando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('TRANSFERIR'),
                ),
              ),

              const SizedBox(height: 28),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Histórico de transferências',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseService.instance.buscarHistorico(
                    usuarioId: usuarioId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final historico = snapshot.data!;

                    if (historico.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma transferência realizada.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: historico.length,
                      itemBuilder: (context, index) {
                        final item = historico[index];
                        final valor = (item['valor'] as num).toDouble();

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE3F2FD),
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text('Para: ${item['destinatario']}'),
                            subtitle: Text(formatarData(item['data'])),
                            trailing: Text(
                              '- ${formatarMoeda(valor)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
