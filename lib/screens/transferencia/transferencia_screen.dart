import 'package:flutter/material.dart';
import 'package:gasapp/services/database.dart';

class TransferenciaScreen extends StatefulWidget {
  @override
  _TransferenciaScreenState createState() => _TransferenciaScreenState();
}
//Kayo Albuquerque 
class _TransferenciaScreenState extends State<TransferenciaScreen> {

  final _valorController = TextEditingController();
  final _destinoController = TextEditingController();

  double saldoSimulado = 1500.00;

  void _confirmarTransferencia() async {

    final double? valor = double.tryParse(_valorController.text);
    final String destino = _destinoController.text;

    if (valor == null || valor <= 0) {
      _mensagem("Digite um valor válido");
      return;
    }

    if (valor > saldoSimulado) {
      _mensagem("Saldo insuficiente!");
      return;
    }

    if (destino.isEmpty) {
      _mensagem("Informe o destinatário");
      return;
    }

    await DatabaseService.instance.registrarTransferencia(
      valor,
      destino,
    );

    _mensagem(
      "Transferência enviada!",
      cor: Colors.green,
    );

    _valorController.clear();
    _destinoController.clear();

    setState(() {});
  }

  void _mensagem(String texto, {Color cor = Colors.red}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: cor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Banco Digital"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.account_balance,
              size: 100,
              color: Colors.blue,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _destinoController,
              decoration: const InputDecoration(
                labelText: "Nome do Destinatário",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Valor (R\$)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmarTransferencia,
                child: const Text("TRANSFERIR"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Histórico de Transações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseService.instance.buscarHistorico(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final historico = snapshot.data!;

                  if (historico.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nenhuma transferência realizada.",
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: historico.length,

                    itemBuilder: (context, index) {

                      final item = historico[index];

                      return Card(
                        child: ListTile(

                          leading: const Icon(
                            Icons.swap_horiz,
                            color: Colors.blue,
                          ),

                          title: Text(
                            "Para: ${item['destinatario']}",
                          ),

                          subtitle: Text(
                            item['data'],
                          ),

                          trailing: Text(
                            "R\$ ${item['valor'].toStringAsFixed(2)}",

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
    );
  }
}