import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/alerta_card.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/com_territorio.dart';
import '../../core/widgets/estados.dart';
import '../../core/widgets/graficos.dart';
import '../../data/models/territorio.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class IndicadorDetalheTela extends StatelessWidget {
  const IndicadorDetalheTela({super.key, required this.distritoId});

  final String distritoId;

  @override
  Widget build(BuildContext context) {
    final nome = context.select<TerritorioController, String?>((c) => c.territorio?.distrito(distritoId)?.nome);
    return Scaffold(
      appBar: AppBar(title: Text(nome == null ? Textos.indicadorTitulo : Textos.indicadorTituloDe(nome))),
      body: ComTerritorio(
        builder: (context, t, c) {
          final d = t.distrito(distritoId);
          final p = c.previsaoDe(distritoId);
          if (d == null || p == null) {
            return VazioView(
              icone: Icons.location_off_outlined,
              titulo: Textos.distritoNaoEncontradoTitulo,
              mensagem: Textos.distritoNaoEncontradoTexto,
            );
          }
          final painel = CoresDoPainel.de(context);
          final alertas = context.watch<AlertasController>().doDistrito(d.id);
          final n = t.meses.length;
          final faixa = List<double?>.filled(n + 1, null)..[n] = p.faixaProximo;
          final rotulos = [...t.meses.map(Textos.mesCurto), Textos.mesCurto(DateTime(t.meses.last.year, t.meses.last.month + 1))];
          final sub = c.equidade!.subRegistro(d);
          final serieFaixa = c.equidade!.serie(d.faixaRenda);
          final atend = d.atendidos.sublist(n - 3).fold<int>(0, (s, v) => s + v) / 3 / d.populacao * 10000;
          final atendFaixa = serieFaixa.atendidosPor10mil.sublist(n - 3).reduce((a, b) => a + b) / 3;
          final cats = d.categorias.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          return PaginaRolavel(
            children: [
              Wrap(
                spacing: AppEspaco.sm,
                runSpacing: AppEspaco.xs,
                children: [
                  Etiqueta(
                    texto: Textos.zona(d.zona),
                    cor: Theme.of(context).colorScheme.onSurface,
                    fundo: Theme.of(context).colorScheme.surfaceContainerHigh,
                    icone: Icons.map_outlined,
                  ),
                  Etiqueta(
                    texto: Textos.faixa(d.faixaRenda),
                    cor: Theme.of(context).colorScheme.onSurface,
                    fundo: Theme.of(context).colorScheme.surfaceContainerHigh,
                    icone: Icons.payments_outlined,
                  ),
                  Etiqueta(
                    texto: Textos.populacao(d.populacao),
                    cor: Theme.of(context).colorScheme.onSurface,
                    fundo: Theme.of(context).colorScheme.surfaceContainerHigh,
                    icone: Icons.groups_outlined,
                  ),
                  const RotuloSintetico(),
                ],
              ),
              GradeResponsiva(
                colunasTablet: 3,
                children: [
                  Kpi(
                    rotulo: Textos.kpiUltimoMes(Textos.mesLongo(t.meses.last)),
                    valor: inteiro(p.ultimoReal),
                    detalhe: Textos.desvioLinha(p.ultimoReal, p.ultimoPrevisto, p.desvio),
                    icone: Icons.assignment_outlined,
                  ),
                  Kpi(
                    rotulo: Textos.kpiPrevistoProximo,
                    valor: inteiro(p.previstoProximo),
                    detalhe: Textos.kpiPrevistoProximoDetalhe(p.faixaProximo),
                    icone: Icons.query_stats,
                    cor: painel.seriePrevista,
                  ),
                  Kpi(
                    rotulo: Textos.kpiErroDistrito,
                    valor: inteiro(p.backtest.mae),
                    detalhe: Textos.kpiErroModeloDetalhe(p.backtest.mape, p.backtest.pontos.length),
                    icone: Icons.fact_check_outlined,
                  ),
                ],
              ),
              Secao(
                titulo: Textos.indicadorGraficoTitulo,
                subtitulo: Textos.indicadorGraficoSubtitulo,
                acao: TendenciaEtiqueta(tendencia: p.tendencia, porMes: p.tendenciaPorMes),
                child: GraficoLinha(
                  altura: 210,
                  descricao: Textos.graficoDistritoDescricao(d.nome, p.ultimoReal, p.ultimoPrevisto),
                  rotulosX: rotulos,
                  marcarIndice: n - 1,
                  series: [
                    SerieGrafico(
                      rotulo: Textos.serieRegistrados,
                      valores: [...d.registrados.map((v) => v.toDouble()), null],
                      cor: painel.serieReal,
                    ),
                    SerieGrafico(
                      rotulo: Textos.seriePrevistos,
                      valores: [...p.previstosHistorico, p.previstoProximo],
                      cor: painel.seriePrevista,
                      tracejada: true,
                      faixa: faixa,
                    ),
                  ],
                  formatarY: (v) => inteiro(v),
                ),
              ),
              Secao(
                titulo: Textos.backtestTitulo,
                subtitulo: Textos.backtestSubtitulo,
                child: _TabelaBacktest(t: t, d: d, pontos: [for (final b in p.backtest.pontos) (b.indice, b.previsto, b.real)]),
              ),
              Secao(
                titulo: Textos.categoriasTitulo,
                acao: const RotuloSintetico(),
                child: GraficoBarras(
                  descricao: Textos.categoriasDescricao(
                    d.nome,
                    [for (final e in cats) (Textos.categoria(e.key), e.value)],
                  ),
                  maximo: 1,
                  itens: [
                    for (final e in cats)
                      BarraItem(
                        rotulo: Textos.categoria(e.key),
                        valor: e.value,
                        textoValor: percentual(e.value),
                        cor: e.key == Categoria.bocaDeLobo ? painel.serieAuxiliar : painel.serieReal,
                      ),
                  ],
                ),
              ),
              Secao(
                titulo: Textos.atendimentoTitulo,
                acao: const RotuloSintetico(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinhaInfo(rotulo: Textos.atendimentoDistrito, valor: decimal(atend)),
                    LinhaInfo(rotulo: Textos.atendimentoFaixa(d.faixaRenda), valor: decimal(atendFaixa)),
                    LinhaInfo(
                      rotulo: Textos.subRegistroEstimado,
                      valor: '${percentual(sub.estimativa)} ± ${percentual(sub.margem)}',
                    ),
                  ],
                ),
              ),
              Secao(
                titulo: Textos.indicadorAlertasTitulo,
                child: alertas.isEmpty
                    ? VazioView(
                        icone: Icons.check_circle_outline,
                        titulo: Textos.meuDistritoSemAlertasTitulo,
                        mensagem: Textos.indicadorSemAlertasTexto,
                      )
                    : Column(
                        children: [
                          for (final a in alertas) ...[
                            AlertaCard(
                              alerta: a,
                              onTap: () => context.goNamed(
                                Rotas.alertaDoIndicador,
                                pathParameters: {'distritoId': d.id, 'alertaId': a.id},
                              ),
                            ),
                            const SizedBox(height: AppEspaco.sm),
                          ],
                        ],
                      ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.goNamed(Rotas.registrar, queryParameters: {'distrito': d.id}),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(Textos.registrarNesteDistrito),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabelaBacktest extends StatelessWidget {
  const _TabelaBacktest({required this.t, required this.d, required this.pontos});

  final Territorio t;
  final Distrito d;
  final List<(int, double, int)> pontos;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelLarge;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(Textos.colunaMes, style: estilo)),
            Expanded(child: Text(Textos.colunaPrevisto, style: estilo, textAlign: TextAlign.end)),
            Expanded(child: Text(Textos.colunaReal, style: estilo, textAlign: TextAlign.end)),
            Expanded(child: Text(Textos.colunaErro, style: estilo, textAlign: TextAlign.end)),
          ],
        ),
        const Divider(),
        for (final (i, prev, real) in pontos)
          Semantics(
            label: Textos.linhaBacktestSemantica(Textos.mesLongo(t.meses[i]), prev, real),
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppEspaco.xs),
              child: Row(
                children: [
                  Expanded(child: Text(Textos.mesCurto(t.meses[i]))),
                  Expanded(child: Text(inteiro(prev), textAlign: TextAlign.end)),
                  Expanded(child: Text(inteiro(real), textAlign: TextAlign.end)),
                  Expanded(child: Text(comSinal(real - prev, inteiro), textAlign: TextAlign.end)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
