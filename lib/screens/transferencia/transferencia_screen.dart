import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class TransferenciaScreen extends StatefulWidget {
  @override
  _TransferenciaScreenState createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  final _valorController = TextEditingController();
  final _destinoController = TextEditingController();
  double saldoSimulado = 1500.00; // Saldo de exemplo para validar

  void _confirmarTransferencia() async {
    final double? valor = double.tryParse(_valorController.text);
    final String destino = _destinoController.text;

    // --- VALIDAÇÕES (Requisito da Pessoa 4) ---
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

    // --- SALVAR NO BANCO (Requisito da Pessoa 4) ---
    await DatabaseService.instance.registrarTransferencia(valor, destino);
    
    _mensagem("Transferência enviada!", cor: Colors.green);
    _valorController.clear();
    _destinoController.clear();
    
    setState(() {}); // Atualiza a lista de histórico automaticamente
  }

  void _mensagem(String texto, {Color cor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Área de Transferência")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PARTE 1: Formulário de Envio
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _destinoController,
                      decoration: InputDecoration(labelText: "Nome do Destinatário"),
                    ),
                    TextField(
                      controller: _valorController,
                      decoration: InputDecoration(labelText: "Valor (R\$)"),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _confirmarTransferencia,
                      child: Text("Transferir Agora"),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 25),
            Text("Histórico de Transações", 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            // PARTE 2: Histórico (Requisito da Pessoa 4)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseService.instance.buscarHistorico(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  
                  final historico = snapshot.data!;
                  
                  if (historico.isEmpty) {
                    return Center(child: Text("Nenhuma transferência realizada."));
                  }

                  return ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      final item = historico[index];
                      return ListTile(
                        leading: Icon(Icons.swap_horiz, color: Colors.blue),
                        title: Text("Para: ${item['destinatario']}"),
                        subtitle: Text(item['data']),
                        trailing: Text("R\$ ${item['valor'].toStringAsFixed(2)}",
                                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
