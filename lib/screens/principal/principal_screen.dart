import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../routes/app_routes.dart';
import '../../services/database.dart';

class PrincipalScreen extends StatefulWidget {
  final Map<String, dynamic>? usuarioInicial;

  const PrincipalScreen({
    super.key,
    this.usuarioInicial,
  });

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  Map<String, dynamic>? usuario;
  bool ocultarSaldo = false;

  String formatarMoeda(double valor) {
    final texto = valor.toStringAsFixed(2).replaceAll('.', ',');
    final partes = texto.split(',');
    final reais = partes[0];
    final centavos = partes[1];

    final buffer = StringBuffer();

    for (int i = 0; i < reais.length; i++) {
      final posicao = reais.length - i;
      buffer.write(reais[i]);

      if (posicao > 1 && posicao % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'R\$ ${buffer.toString()},$centavos';
  }

  Future<void> atualizarUsuario() async {
    final id = usuario?['id'];
    if (id == null) return;

    final usuarioAtualizado = await DatabaseService.instance.buscarUsuarioPorId(
      id as int,
    );

    if (!mounted) return;

    if (usuarioAtualizado != null) {
      setState(() {
        usuario = usuarioAtualizado;
      });
    }
  }

  Future<void> abrirTransferencia() async {
    final usuarioAtual = usuario;
    if (usuarioAtual == null) return;

    final usuarioAtualizado = await Navigator.pushNamed(
      context,
      AppRoutes.transferencia,
      arguments: usuarioAtual,
    );

    if (!mounted) return;

    if (usuarioAtualizado is Map<String, dynamic>) {
      setState(() {
        usuario = usuarioAtualizado;
      });
    } else {
      await atualizarUsuario();
    }
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuarioId');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    usuario ??=
        widget.usuarioInicial ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {
          'id': null,
          'nome': 'Usuário',
          'saldo': 1500.00,
        };

    final nome = usuario?['nome'] ?? 'Usuário';
    final saldo = ((usuario?['saldo'] ?? 0) as num).toDouble();
    final inicial = nome.toString().isNotEmpty
        ? nome.toString()[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'NexBank',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Atualizar saldo',
            icon: const Icon(Icons.refresh),
            onPressed: atualizarUsuario,
          ),

          ValueListenableBuilder<ThemeMode>(
            valueListenable: temaNotifier,
            builder: (context, temaAtual, _) {
              return IconButton(
                tooltip: 'Alternar tema',
                icon: Icon(
                  temaAtual == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: alternarTema,
              );
            },
          ),

          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: sair,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: atualizarUsuario,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF0D47A1),
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo de volta,',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.65),
                            fontSize: 14,
                          ),
                        ),

                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo disponível',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      ocultarSaldo ? 'R\$ ••••••' : formatarMoeda(saldo),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ocultarSaldo
                              ? 'Saldo ocultado'
                              : 'Toque no olho para ocultar',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarSaldo = !ocultarSaldo;
                            });
                          },
                          icon: Icon(
                            ocultarSaldo
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Ações rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _MenuItem(
                    icon: Icons.swap_horiz,
                    label: 'Transferir',
                    onTap: abrirTransferencia,
                  ),

                  _MenuItem(
                    icon: Icons.trending_up,
                    label: 'Cotação',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.cotacao);
                    },
                  ),

                  _MenuItem(
                    icon: Icons.receipt_long,
                    label: 'Extrato',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.extrato,
                        arguments: usuario,
                      );
                    },
                  ),

                  _MenuItem(
                    icon: Icons.pix,
                    label: 'Pix',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Em desenvolvimento...'),
                        ),
                      );
                    },
                  ),

                  _MenuItem(
                    icon: Icons.person,
                    label: 'Perfil',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Em desenvolvimento...'),
                        ),
                      );
                    },
                  ),

                  _MenuItem(
                    icon: Icons.refresh,
                    label: 'Atualizar',
                    onTap: atualizarUsuario,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool darkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: darkMode ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: darkMode
                    ? Colors.black.withOpacity(0.20)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    darkMode ? const Color(0xFF263238) : const Color(0xFFE3F2FD),
                child: Icon(
                  icon,
                  color: darkMode
                      ? const Color(0xFF90CAF9)
                      : const Color(0xFF0D47A1),
                  size: 26,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}