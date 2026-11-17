import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/com_territorio.dart';
import '../../core/widgets/graficos.dart';
import '../../data/models/territorio.dart';
import '../../domain/series.dart';
import '../../router/app_router.dart';

class PainelEquidadeTela extends StatelessWidget {
  const PainelEquidadeTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.painelEquidadeTitulo)),
      body: ComTerritorio(
        builder: (context, t, c) {
          final painel = CoresDoPainel.de(context);
          final eq = c.equidade!;
          final social = c.social!;
          final series = eq.series();
          final baixa = series[FaixaRenda.baixa]!;
          final media = series[FaixaRenda.media]!;
          final alta = series[FaixaRenda.alta]!;
          final rotulos = t.meses.map(Textos.mesCurto).toList();
          final subs = eq.subRegistroTodos();
          final ultimaSub = {for (final f in FaixaRenda.values) f: ultimos(series[f]!.subRegistro, 3).reduce((a, b) => a + b) / 3};
          final corFaixa = {
            FaixaRenda.baixa: painel.alertaAlta,
            FaixaRenda.media: painel.seriePrevista,
            FaixaRenda.alta: painel.serieReal,
          };
          return PaginaRolavel(
            children: [
              const Align(alignment: Alignment.centerLeft, child: RotuloSintetico()),
              Text(Textos.painelEquidadeIntro, style: Theme.of(context).textTheme.bodyLarge),
              Secao(
                titulo: Textos.socialTitulo,
                subtitulo: Textos.socialSubtitulo,
                acao: TendenciaEtiqueta(
                  tendencia: social.tendencia,
                  porMes: social.tendenciaPorMes,
                  texto: Textos.tendenciaDiferenca(social.tendencia, social.tendenciaPorMes),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradeResponsiva(
                      colunasTablet: 3,
                      children: [
                        Kpi(
                          rotulo: Textos.kpiSocial,
                          valor: decimal(social.diferencaAtual),
                          detalhe: Textos.socialDiferencaDetalhe,
                          icone: Icons.balance_outlined,
                          cor: painel.sintetico,
                        ),
                        Kpi(
                          rotulo: Textos.atendimentoFaixa(FaixaRenda.baixa),
                          valor: decimal(social.atualBaixa),
                          icone: Icons.south_east,
                          cor: corFaixa[FaixaRenda.baixa],
                        ),
                        Kpi(
                          rotulo: Textos.atendimentoFaixa(FaixaRenda.alta),
                          valor: decimal(social.atualAlta),
                          icone: Icons.north_east,
                          cor: corFaixa[FaixaRenda.alta],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppEspaco.md),
                    GraficoLinha(
                      altura: 200,
                      descricao: Textos.socialGraficoDescricao(social.atualBaixa, social.atualAlta, social.diferencaAtual),
                      rotulosX: rotulos,
                      formatarY: (v) => decimal(v, 0),
                      series: [
                        SerieGrafico(rotulo: Textos.faixa(FaixaRenda.alta), valores: alta.atendidosPor10mil, cor: corFaixa[FaixaRenda.alta]!),
                        SerieGrafico(rotulo: Textos.faixa(FaixaRenda.media), valores: media.atendidosPor10mil, cor: corFaixa[FaixaRenda.media]!, tracejada: true),
                        SerieGrafico(rotulo: Textos.faixa(FaixaRenda.baixa), valores: baixa.atendidosPor10mil, cor: corFaixa[FaixaRenda.baixa]!),
                      ],
                    ),
                    const SizedBox(height: AppEspaco.md),
                    Text(Textos.socialComoLer, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Secao(
                titulo: Textos.subRegistroTitulo,
                subtitulo: Textos.subRegistroSubtitulo((t.amostraVistoria * 100).round()),
                acao: const RotuloSintetico(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GraficoBarras(
                      maximo: 1,
                      descricao: Textos.subRegistroFaixasDescricao(
                        ultimaSub[FaixaRenda.baixa]!,
                        ultimaSub[FaixaRenda.media]!,
                        ultimaSub[FaixaRenda.alta]!,
                      ),
                      itens: [
                        for (final f in FaixaRenda.values)
                          BarraItem(
                            rotulo: Textos.faixa(f),
                            valor: ultimaSub[f]!,
                            textoValor: percentual(ultimaSub[f]!),
                            cor: corFaixa[f]!,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppEspaco.md),
                    GraficoLinha(
                      altura: 160,
                      zeroNoEixo: true,
                      descricao: Textos.subRegistroHistoricoDescricao,
                      rotulosX: rotulos,
                      formatarY: (v) => percentual(v),
                      series: [
                        SerieGrafico(rotulo: Textos.faixa(FaixaRenda.baixa), valores: baixa.subRegistro, cor: corFaixa[FaixaRenda.baixa]!),
                        SerieGrafico(rotulo: Textos.faixa(FaixaRenda.alta), valores: alta.subRegistro, cor: corFaixa[FaixaRenda.alta]!),
                      ],
                    ),
                  ],
                ),
              ),
              Secao(
                titulo: Textos.subRegistroDistritosTitulo,
                subtitulo: Textos.subRegistroDistritosSubtitulo,
                child: Column(
                  children: [
                    for (final s in subs)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.distrito.nome),
                        subtitle: Text(Textos.subRegistroLinha(s.estimativa, s.margem, s.achadosNaAmostra, s.distrito.faixaRenda)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.goNamed(Rotas.indicador, pathParameters: {'distritoId': s.distrito.id}),
                      ),
                  ],
                ),
              ),
              Secao(
                titulo: Textos.equidadeLimitacoesTitulo,
                child: ListaMarcadores(itens: Textos.equidadeLimitacoes),
              ),
            ],
          );
        },
      ),
    );
  }
}
