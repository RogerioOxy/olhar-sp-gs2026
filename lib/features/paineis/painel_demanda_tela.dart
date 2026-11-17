import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/com_territorio.dart';
import '../../core/widgets/estados.dart';
import '../../core/widgets/graficos.dart';
import '../../data/models/registro_local.dart';
import '../../domain/previsao.dart';
import '../../domain/series.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class PainelDemandaTela extends StatefulWidget {
  const PainelDemandaTela({super.key, this.zonaInicial});

  final String? zonaInicial;

  @override
  State<PainelDemandaTela> createState() => _PainelDemandaTelaState();
}

enum _Ordem { desvio, nome, tendencia }

class _PainelDemandaTelaState extends State<PainelDemandaTela> {
  String? _zona;
  String _busca = '';
  _Ordem _ordem = _Ordem.desvio;

  @override
  void initState() {
    super.initState();
    _zona = widget.zonaInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.painelDemandaTitulo)),
      body: ComTerritorio(
        builder: (context, t, c) {
          final painel = CoresDoPainel.de(context);
          final limiares = context.watch<PreferenciasController>().limiares;
          final resumo = c.resumo!;
          final reg = somaRegistrados(c.previsoes);
          final prev = somaPrevistos(c.previsoes);
          final proximo = c.previsoes.fold<double>(0, (s, p) => s + p.previstoProximo);
          final indice = IndiceSazonal.calcular(t, ate: t.meses.length);
          final tendencia = inclinacaoRelativa([
            for (var i = reg.length - 12; i < reg.length; i++) reg[i] / indice.de(t.meses[i]),
          ]);
          var lista = c.previsoes.where((p) {
            if (_zona != null && p.distrito.zona != _zona) return false;
            if (_busca.isEmpty) return true;
            return normalizar(p.distrito.nome).contains(normalizar(_busca));
          }).toList();
          lista.sort(
            (a, b) => switch (_ordem) {
              _Ordem.desvio => b.desvio.abs().compareTo(a.desvio.abs()),
              _Ordem.nome => a.distrito.nome.compareTo(b.distrito.nome),
              _Ordem.tendencia => b.tendenciaPorMes.compareTo(a.tendenciaPorMes),
            },
          );
          final rotulos = [...t.meses.map(Textos.mesCurto), Textos.mesCurto(DateTime(t.meses.last.year, t.meses.last.month + 1))];
          return PaginaRolavel(
            children: [
              Text(Textos.painelDemandaIntro, style: Theme.of(context).textTheme.bodyLarge),
              GradeResponsiva(
                colunasTablet: 3,
                children: [
                  Kpi(
                    rotulo: Textos.kpiRegistradosMes(Textos.mesLongo(t.meses.last)),
                    valor: inteiro(reg.last),
                    detalhe: Textos.kpiRegistradosMesDetalhe(prev.last ?? 0),
                    icone: Icons.assignment_outlined,
                  ),
                  Kpi(
                    rotulo: Textos.kpiPrevistoCidade,
                    valor: inteiro(proximo),
                    detalhe: Textos.kpiPrevistoCidadeDetalhe(Textos.mesLongo(DateTime(t.meses.last.year, t.meses.last.month + 1))),
                    icone: Icons.query_stats,
                    cor: painel.seriePrevista,
                  ),
                  Kpi(
                    rotulo: Textos.kpiErroModelo,
                    valor: inteiro(resumo.maeMedio),
                    detalhe: Textos.kpiErroModeloDetalhe(resumo.mapeGeral, resumo.meses),
                    icone: Icons.fact_check_outlined,
                    onTap: () => context.goNamed(Rotas.sobreDados),
                  ),
                ],
              ),
              Secao(
                titulo: Textos.demandaGraficoTitulo,
                subtitulo: Textos.demandaGraficoSubtitulo,
                acao: TendenciaEtiqueta(
                  tendencia: tendencia > 0.01
                      ? Tendencia.alta
                      : tendencia < -0.01
                      ? Tendencia.queda
                      : Tendencia.estavel,
                  porMes: tendencia,
                ),
                child: GraficoLinha(
                  altura: 200,
                  descricao: Textos.graficoCidadeDescricao(reg.last, prev.last ?? 0),
                  rotulosX: rotulos,
                  marcarIndice: reg.length - 1,
                  series: [
                    SerieGrafico(rotulo: Textos.serieRegistrados, valores: [...reg, null], cor: painel.serieReal),
                    SerieGrafico(
                      rotulo: Textos.seriePrevistos,
                      valores: [...prev, proximo],
                      cor: painel.seriePrevista,
                      tracejada: true,
                    ),
                  ],
                  formatarY: (v) => inteiro(v),
                ),
              ),
              Secao(
                titulo: Textos.demandaDistritosTitulo,
                subtitulo: Textos.demandaDistritosSubtitulo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: Textos.buscarDistrito,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _busca = v.trim()),
                    ),
                    const SizedBox(height: AppEspaco.sm),
                    Wrap(
                      spacing: AppEspaco.sm,
                      runSpacing: AppEspaco.xs,
                      children: [
                        ChoiceChip(
                          label: Text(Textos.todasZonas),
                          selected: _zona == null,
                          onSelected: (_) => setState(() => _zona = null),
                        ),
                        for (final z in t.zonas)
                          ChoiceChip(
                            label: Text(Textos.zona(z)),
                            selected: _zona == z,
                            onSelected: (_) => setState(() => _zona = z),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppEspaco.sm),
                    DropdownButtonFormField<_Ordem>(
                      initialValue: _ordem,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: Textos.ordenarPor),
                      items: [
                        DropdownMenuItem(value: _Ordem.desvio, child: Text(Textos.ordemDesvio)),
                        DropdownMenuItem(value: _Ordem.tendencia, child: Text(Textos.ordemTendencia)),
                        DropdownMenuItem(value: _Ordem.nome, child: Text(Textos.ordemNome)),
                      ],
                      onChanged: (o) => setState(() => _ordem = o ?? _Ordem.desvio),
                    ),
                    if (lista.isEmpty)
                      VazioView(
                        icone: Icons.search_off,
                        titulo: Textos.buscaVaziaTitulo,
                        mensagem: Textos.buscaVaziaTexto(_busca),
                      )
                    else
                      for (final p in lista) _LinhaDistrito(p, limiares),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? para[i] : ch);
  }
  return b.toString().toLowerCase();
}

class _LinhaDistrito extends StatelessWidget {
  const _LinhaDistrito(this.p, this.limiares);

  final PrevisaoDistrito p;
  final Limiares limiares;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final painel = CoresDoPainel.de(context);
    final alto = p.desvio * 100 >= limiares.picoPercentual;
    final baixo = -p.desvio * 100 >= limiares.quedaPercentual;
    void abrir() => context.goNamed(Rotas.indicador, pathParameters: {'distritoId': p.distrito.id});
    return Semantics(
      button: true,
      onTap: abrir,
      label: Textos.linhaDistritoSemantica(p.distrito.nome, p.ultimoReal, p.ultimoPrevisto, p.desvio, p.tendencia),
      excludeSemantics: true,
      child: InkWell(
        onTap: abrir,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppEspaco.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.distrito.nome, style: tema.textTheme.titleSmall),
                    Text(
                      Textos.desvioLinha(p.ultimoReal, p.ultimoPrevisto, p.desvio),
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppEspaco.sm),
              Etiqueta(
                texto: comSinal(p.desvio * 100, (v) => '${decimal(v, 1)}%'),
                cor: alto || baixo ? painel.alertaAlta : tema.colorScheme.onSurface,
                fundo: alto || baixo ? painel.altaFundo : tema.colorScheme.surfaceContainerHigh,
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
