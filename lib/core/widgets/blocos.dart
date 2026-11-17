import 'package:flutter/material.dart';

import '../../domain/alertas.dart';
import '../../domain/previsao.dart';
import '../textos.dart';
import '../theme/app_theme.dart';

class Secao extends StatelessWidget {
  const Secao({super.key, required this.titulo, this.subtitulo, required this.child, this.acao});

  final String titulo;
  final String? subtitulo;
  final Widget child;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      semanticContainer: false,
      child: Padding(
        padding: const EdgeInsets.all(AppEspaco.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(header: true, child: Text(titulo, style: tema.textTheme.titleMedium)),
                      if (subtitulo != null) ...[
                        const SizedBox(height: AppEspaco.xs),
                        Text(
                          subtitulo!,
                          style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                if (acao != null) ...[
                  const SizedBox(width: AppEspaco.sm),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.42),
                    child: acao!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppEspaco.md),
            child,
          ],
        ),
      ),
    );
  }
}

class Kpi extends StatelessWidget {
  const Kpi({
    super.key,
    required this.rotulo,
    required this.valor,
    this.detalhe,
    required this.icone,
    this.cor,
    this.onTap,
  });

  final String rotulo;
  final String valor;
  final String? detalhe;
  final IconData icone;
  final Color? cor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final c = cor ?? tema.colorScheme.primary;
    final conteudo = Padding(
      padding: const EdgeInsets.all(AppEspaco.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: c, size: 20),
              const SizedBox(width: AppEspaco.sm),
              Expanded(
                child: Text(
                  rotulo,
                  style: tema.textTheme.labelLarge?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppEspaco.sm),
          Text(valor, style: tema.textTheme.headlineSmall?.copyWith(color: c)),
          if (detalhe != null) ...[
            const SizedBox(height: AppEspaco.xs),
            Text(detalhe!, style: tema.textTheme.bodySmall),
          ],
        ],
      ),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label: [rotulo, valor, ?detalhe].join('. '),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? conteudo : InkWell(onTap: onTap, child: conteudo),
      ),
    );
  }
}

class GradeResponsiva extends StatelessWidget {
  const GradeResponsiva({super.key, required this.children, this.colunasTablet = 2});

  final List<Widget> children;
  final int colunasTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final colunas = c.maxWidth >= AppEspaco.quebraTablet ? colunasTablet : 1;
        if (colunas == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppEspaco.md),
                children[i],
              ],
            ],
          );
        }
        final largura = (c.maxWidth - AppEspaco.md * (colunas - 1)) / colunas;
        return Wrap(
          spacing: AppEspaco.md,
          runSpacing: AppEspaco.md,
          children: [for (final w in children) SizedBox(width: largura, child: w)],
        );
      },
    );
  }
}

class PaginaRolavel extends StatelessWidget {
  const PaginaRolavel({super.key, required this.children, this.onRefresh});

  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final lista = ListView(
      padding: const EdgeInsets.fromLTRB(AppEspaco.lg, AppEspaco.sm, AppEspaco.lg, AppEspaco.xxl),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppEspaco.larguraMaxima),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppEspaco.md),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
    return onRefresh == null ? lista : RefreshIndicator(onRefresh: onRefresh!, child: lista);
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta({super.key, required this.texto, required this.cor, required this.fundo, this.icone});

  final String texto;
  final Color cor;
  final Color fundo;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppEspaco.sm, vertical: AppEspaco.xs),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(AppRaio.lg),
        border: Border.all(color: cor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 16, color: cor), const SizedBox(width: AppEspaco.xs)],
          Flexible(
            child: Text(
              texto,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class SeloConfianca extends StatelessWidget {
  const SeloConfianca(this.confianca, {super.key});

  final Confianca confianca;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final (icone, cor, fundo) = switch (confianca) {
      Confianca.alta => (Icons.verified_outlined, esquema.onPrimaryContainer, esquema.primaryContainer),
      Confianca.media => (Icons.adjust, esquema.onTertiaryContainer, esquema.tertiaryContainer),
      Confianca.baixa => (Icons.help_outline, esquema.onSurface, esquema.surfaceContainerHigh),
    };
    return Etiqueta(texto: Textos.confianca(confianca), cor: cor, fundo: fundo, icone: icone);
  }
}

class SeloPrioridade extends StatelessWidget {
  const SeloPrioridade(this.prioridade, {super.key});

  final Prioridade prioridade;

  @override
  Widget build(BuildContext context) {
    final p = CoresDoPainel.de(context);
    final alta = prioridade == Prioridade.alta;
    return Etiqueta(
      texto: Textos.prioridade(prioridade),
      cor: alta ? p.alertaAlta : p.alertaAlerta,
      fundo: alta ? p.altaFundo : p.alertaFundo,
      icone: alta ? Icons.priority_high : Icons.flag_outlined,
    );
  }
}

class RotuloSintetico extends StatelessWidget {
  const RotuloSintetico({super.key});

  @override
  Widget build(BuildContext context) {
    final p = CoresDoPainel.de(context);
    return Etiqueta(
      texto: Textos.rotuloSintetico,
      cor: p.sintetico,
      fundo: p.sinteticoFundo,
      icone: Icons.science_outlined,
    );
  }
}

class TendenciaEtiqueta extends StatelessWidget {
  const TendenciaEtiqueta({super.key, required this.tendencia, required this.porMes, this.texto});

  final Tendencia tendencia;
  final double porMes;
  final String? texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final icone = switch (tendencia) {
      Tendencia.alta => Icons.trending_up,
      Tendencia.estavel => Icons.trending_flat,
      Tendencia.queda => Icons.trending_down,
    };
    return Etiqueta(
      texto: texto ?? Textos.tendencia(tendencia, porMes),
      cor: esquema.onSurface,
      fundo: esquema.surfaceContainerHigh,
      icone: icone,
    );
  }
}

class AvisoDecisaoHumana extends StatelessWidget {
  const AvisoDecisaoHumana({super.key, this.compacto = false});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '${Textos.avisoDecisaoTitulo}. ${compacto ? Textos.avisoDecisaoCurto : Textos.avisoDecisaoTexto}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppEspaco.md),
        decoration: BoxDecoration(
          color: esquema.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRaio.sm),
          border: Border.all(color: esquema.secondary),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.person_outline, color: esquema.onSecondaryContainer),
            const SizedBox(width: AppEspaco.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Textos.avisoDecisaoTitulo,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: esquema.onSecondaryContainer),
                  ),
                  const SizedBox(height: AppEspaco.xs),
                  Text(
                    compacto ? Textos.avisoDecisaoCurto : Textos.avisoDecisaoTexto,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: esquema.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LinhaInfo extends StatelessWidget {
  const LinhaInfo({super.key, required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Semantics(
      label: '$rotulo: $valor',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppEspaco.xs),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppEspaco.md,
          children: [
            Text(rotulo, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
            Text(valor, style: tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class ListaMarcadores extends StatelessWidget {
  const ListaMarcadores({super.key, required this.itens, this.icone = Icons.circle});

  final List<String> itens;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: AppEspaco.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(icone, size: 8, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: AppEspaco.sm),
                Expanded(child: Text(t)),
              ],
            ),
          ),
      ],
    );
  }
}
