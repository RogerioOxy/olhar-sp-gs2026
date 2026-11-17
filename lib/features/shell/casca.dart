import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/textos.dart';
import '../../core/widgets/estados.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

/// Reúne as abas e mostra a quantidade de alertas novos na navegação.
class Casca extends StatelessWidget {
  const Casca({super.key, required this.navegacao});

  final StatefulNavigationShell navegacao;

  @override
  Widget build(BuildContext context) {
    final novos = context.select<AlertasController, int>((a) => a.novos.length);
    final total = context.select<AlertasController, int>((a) => a.alertas.length);
    return Scaffold(
      body: navegacao,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navegacao.currentIndex,
        onDestinationSelected: (i) => navegacao.goBranch(i, initialLocation: i == navegacao.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: Textos.navInicio,
            tooltip: Textos.navInicioDica,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: Textos.navPaineis,
            tooltip: Textos.navPaineisDica,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: novos > 0,
              label: Text('$novos'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: novos > 0,
              label: Text('$novos'),
              child: const Icon(Icons.notifications),
            ),
            label: Textos.navAlertas,
            tooltip: Textos.navAlertasDica(total, novos),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_location_alt_outlined),
            selectedIcon: const Icon(Icons.add_location_alt),
            label: Textos.navRegistrar,
            tooltip: Textos.navRegistrarDica,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: const Icon(Icons.tune),
            label: Textos.navAjustes,
            tooltip: Textos.navAjustesDica,
          ),
        ],
      ),
    );
  }
}

class NaoEncontradaTela extends StatelessWidget {
  const NaoEncontradaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.naoEncontradaTitulo)),
      body: MensagemView(
        icone: Icons.explore_off_outlined,
        titulo: Textos.naoEncontradaTitulo,
        mensagem: Textos.naoEncontradaTexto,
        acaoRotulo: Textos.voltarAoInicio,
        onAcao: () => context.goNamed(Rotas.inicio),
      ),
    );
  }
}
