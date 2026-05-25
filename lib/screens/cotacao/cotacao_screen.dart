import 'package:flutter/material.dart';
import '../../services/cotacao_service.dart';
import '../../models/cotacao_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0.0;
  double euro = 0.0;

  void _realChanged(String text) {
    if (text.isEmpty) return;
    double real = double.tryParse(text) ?? 0;
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) return;
    double d = double.tryParse(text) ?? 0;
    realController.text = (d * dolar).toStringAsFixed(2);
    euroController.text = (d * dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) return;
    double e = double.tryParse(text) ?? 0;
    realController.text = (e * euro).toStringAsFixed(2);
    dolarController.text = (e * euro / dolar).toStringAsFixed(2);
  }

  Widget _campoTexto(String label, String prefix,
      TextEditingController c, Function f) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        border: const OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: const TextStyle(color: Colors.blue, fontSize: 22),
      onChanged: (value) => f(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<CotacaoModel>(
        future: CotacaoService().getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buscando cotações...'),
                  ],
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao buscar cotação.\nVerifique sua conexão.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              }

              dolar = snapshot.data!.dolar;
              euro = snapshot.data!.euro;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.attach_money,
                        size: 100, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Dólar: R\$ ${dolar.toStringAsFixed(2)} | Euro: R\$ ${euro.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _campoTexto('Reais', 'R\$ ', realController, _realChanged),
                    const Divider(height: 30),
                    _campoTexto('Dólares', 'US\$ ', dolarController, _dolarChanged),
                    const Divider(height: 30),
                    _campoTexto('Euros', '€ ', euroController, _euroChanged),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}