import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../router/app_router.dart';

class PaineisTela extends StatelessWidget {
  const PaineisTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.paineisTitulo)),
      body: PaginaRolavel(
        children: [
          Text(Textos.paineisIntro, style: Theme.of(context).textTheme.bodyLarge),
          GradeResponsiva(
            colunasTablet: 3,
            children: [
              _AtalhoPainel(
                icone: Icons.stacked_line_chart,
                titulo: Textos.painelDemandaTitulo,
                texto: Textos.painelDemandaResumo,
                rota: Rotas.painelDemanda,
              ),
              _AtalhoPainel(
                icone: Icons.thunderstorm_outlined,
                titulo: Textos.painelClimaTitulo,
                texto: Textos.painelClimaResumo,
                rota: Rotas.painelClima,
              ),
              _AtalhoPainel(
                icone: Icons.balance_outlined,
                titulo: Textos.painelEquidadeTitulo,
                texto: Textos.painelEquidadeResumo,
                rota: Rotas.painelEquidade,
                sintetico: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtalhoPainel extends StatelessWidget {
  const _AtalhoPainel({
    required this.icone,
    required this.titulo,
    required this.texto,
    required this.rota,
    this.sintetico = false,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final String rota;
  final bool sintetico;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Semantics(
      button: true,
      label: '$titulo. $texto${sintetico ? '. ${Textos.rotuloSintetico}' : ''}',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.goNamed(rota),
          child: Padding(
            padding: const EdgeInsets.all(AppEspaco.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: tema.colorScheme.primaryContainer,
                      foregroundColor: tema.colorScheme.onPrimaryContainer,
                      child: Icon(icone),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: AppEspaco.md),
                Text(titulo, style: tema.textTheme.titleMedium),
                const SizedBox(height: AppEspaco.xs),
                Text(texto),
                if (sintetico) ...[const SizedBox(height: AppEspaco.sm), const RotuloSintetico()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
