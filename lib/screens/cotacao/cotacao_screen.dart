import 'package:flutter/material.dart';
import '../../models/cotacao_model.dart';
import '../../services/cotacao_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CotacaoService _cotacaoService = CotacaoService();
  final TextEditingController _valorController = TextEditingController();

  CotacaoModel? _cotacao;
  bool _isLoading = false;
  String? _erro;

  // Resultado da conversão
  double? _resultadoDolar;
  double? _resultadoEuro;

  @override
  void initState() {
    super.initState();
    _buscarCotacao();
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _buscarCotacao() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final cotacao = await _cotacaoService.getData();
      setState(() {
        _cotacao = cotacao;
        _isLoading = false;
        _calcularConversao();
      });
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível carregar as cotações. Verifique sua conexão.';
        _isLoading = false;
      });
    }
  }

  void _calcularConversao() {
    if (_cotacao == null) return;

    final texto = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(texto);

    if (valor != null && valor > 0) {
      setState(() {
        _resultadoDolar = valor / _cotacao!.dolar;
        _resultadoEuro = valor / _cotacao!.euro;
      });
    } else {
      setState(() {
        _resultadoDolar = null;
        _resultadoEuro = null;
      });
    }
  }

  String _formatarMoeda(double valor, String simbolo) {
    return '$simbolo ${valor.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cotação de Moedas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _buscarCotacao,
            tooltip: 'Atualizar cotações',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Buscando cotações...'),
                ],
              ),
            )
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _buscarCotacao,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cards de cotação
                      const Text(
                        'Câmbio Atual',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _CotacaoCard(
                              titulo: 'Dólar',
                              codigo: 'USD',
                              valor: _cotacao!.dolar,
                              icone: Icons.attach_money,
                              cor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CotacaoCard(
                              titulo: 'Euro',
                              codigo: 'EUR',
                              valor: _cotacao!.euro,
                              icone: Icons.euro,
                              cor: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Conversor
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Conversor Rápido',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Digite um valor em reais para converter',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _valorController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _calcularConversao(),
                              decoration: InputDecoration(
                                labelText: 'Valor em BRL',
                                prefixText: 'R\$ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            if (_resultadoDolar != null && _resultadoEuro != null) ...[
                              const SizedBox(height: 16),
                              _ResultadoConversao(
                                moeda: 'Dólar Americano',
                                codigo: 'USD',
                                valor: _formatarMoeda(_resultadoDolar!, 'US\$'),
                                cor: Colors.green,
                                icone: Icons.attach_money,
                              ),
                              const SizedBox(height: 8),
                              _ResultadoConversao(
                                moeda: 'Euro',
                                codigo: 'EUR',
                                valor: _formatarMoeda(_resultadoEuro!, '€'),
                                cor: Colors.indigo,
                                icone: Icons.euro,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nota de atualização
                      Center(
                        child: Text(
                          'Cotações fornecidas por AwesomeAPI',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }
}

class _CotacaoCard extends StatelessWidget {
  final String titulo;
  final String codigo;
  final double valor;
  final IconData icone;
  final Color cor;

  const _CotacaoCard({
    required this.titulo,
    required this.codigo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                codigo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultadoConversao extends StatelessWidget {
  final String moeda;
  final String codigo;
  final String valor;
  final Color cor;
  final IconData icone;

  const _ResultadoConversao({
    required this.moeda,
    required this.codigo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              moeda,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}