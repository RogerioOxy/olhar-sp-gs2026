import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/estados.dart';
import '../../core/widgets/graficos.dart';
import '../../data/models/clima.dart';
import '../../domain/previsao.dart';
import '../../domain/series.dart';
import '../../state/controladores.dart';

class PainelClimaTela extends StatelessWidget {
  const PainelClimaTela({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ClimaController>();
    final limiar = context.select<PreferenciasController, int>((p) => p.limiares.chuvaMm3Dias);
    return Scaffold(
      appBar: AppBar(
        title: Text(Textos.painelClimaTitulo),
        actions: [
          IconButton(
            tooltip: Textos.atualizarClima,
            onPressed: c.atualizando ? null : c.atualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: switch (c.estado) {
        EstadoCarga.carregando => CarregandoView(mensagem: Textos.carregandoClima),
        EstadoCarga.erro => ErroView(
          titulo: Textos.erroClimaTitulo,
          mensagem: Textos.erroClima(c.ultimaFalha),
          onTentar: c.atualizar,
        ),
        EstadoCarga.pronto => _Conteudo(clima: c.clima!, controle: c, limiar: limiar),
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.clima, required this.controle, required this.limiar});

  final Clima clima;
  final ClimaController controle;
  final int limiar;

  @override
  Widget build(BuildContext context) {
    final painel = CoresDoPainel.de(context);
    final tema = Theme.of(context);
    final hoje = DateTime.now();
    final hist = clima.historico(hoje);
    final prev = clima.previsao(hoje);
    final todos = [...hist, ...prev];
    final r = ResumoClima.de(clima, hoje);
    final variacao = r.variacao7Dias;
    final tendTemp = inclinacaoRelativa(ultimos(hist, 14).map((d) => d.tempMax).toList());
    final rotulos = todos.isEmpty ? <String>[] : [dataCurta(todos.first.data), Textos.hoje, dataCurta(todos.last.data)];
    return PaginaRolavel(
      onRefresh: controle.atualizar,
      children: [
        Text(Textos.painelClimaIntro, style: tema.textTheme.bodyLarge),
        _FaixaOrigem(clima: clima, controle: controle),
        GradeResponsiva(
          colunasTablet: 3,
          children: [
            Kpi(
              rotulo: Textos.kpiChuva,
              valor: '${decimal(r.chuvaProximos3)} mm',
              detalhe: Textos.kpiChuvaLimiar(limiar, r.probMaxProximos3),
              icone: Icons.water_drop_outlined,
              cor: r.chuvaProximos3 >= limiar ? painel.alertaAlta : painel.serieAuxiliar,
            ),
            Kpi(
              rotulo: Textos.kpiChuva7Dias,
              valor: '${decimal(r.chuvaUltimos7)} mm',
              detalhe: variacao == null ? Textos.semComparacao : Textos.variacaoSemana(variacao),
              icone: Icons.history,
            ),
            Kpi(
              rotulo: Textos.kpiTemperatura,
              valor: prev.isEmpty ? Textos.semDado : '${decimal(prev.first.tempMax)} °C',
              detalhe: prev.isEmpty ? null : Textos.temperaturaDetalhe(prev.first.tempMin),
              icone: Icons.thermostat_outlined,
            ),
          ],
        ),
        Secao(
          titulo: Textos.climaChuvaTitulo,
          subtitulo: Textos.climaChuvaSubtitulo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GraficoColunas(
                valores: [for (final d in todos) d.chuvaMm],
                destacarAPartirDe: hist.length,
                rotulosX: rotulos,
                cor: painel.serieAuxiliar,
                corDestaque: painel.seriePrevista,
                descricao: Textos.climaChuvaDescricao(r.chuvaUltimos7, r.chuvaProximos3, hist.length, prev.length),
              ),
              const SizedBox(height: AppEspaco.sm),
              Legenda(
                itens: [
                  (Textos.legendaChuvaObservada, painel.serieAuxiliar, false),
                  (Textos.legendaChuvaPrevista, painel.seriePrevista, false),
                ],
              ),
            ],
          ),
        ),
        Secao(
          titulo: Textos.climaTempTitulo,
          acao: TendenciaEtiqueta(
            tendencia: tendTemp > 0.01
                ? Tendencia.alta
                : tendTemp < -0.01
                ? Tendencia.queda
                : Tendencia.estavel,
            porMes: tendTemp,
            texto: Textos.tendenciaTemperatura(tendTemp),
          ),
          child: GraficoLinha(
            descricao: Textos.climaTempDescricao(
              todos.isEmpty ? 0 : todos.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b),
              todos.isEmpty ? 0 : todos.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b),
            ),
            rotulosX: [for (final d in todos) dataCurta(d.data)],
            marcarIndice: hist.length,
            formatarY: (v) => '${v.round()}°',
            series: [
              SerieGrafico(rotulo: Textos.serieTempMax, valores: [for (final d in todos) d.tempMax], cor: painel.seriePrevista),
              SerieGrafico(rotulo: Textos.serieTempMin, valores: [for (final d in todos) d.tempMin], cor: painel.serieAuxiliar),
            ],
          ),
        ),
        Secao(
          titulo: Textos.climaProximosTitulo,
          child: Column(
            children: [
              for (final d in prev)
                LinhaInfo(
                  rotulo: Textos.diaSemana(d.data),
                  valor: Textos.linhaPrevisaoDia(d.chuvaMm, d.probChuva, d.tempMin, d.tempMax),
                ),
            ],
          ),
        ),
        Secao(
          titulo: Textos.climaLimitacoesTitulo,
          child: ListaMarcadores(itens: Textos.climaLimitacoes),
        ),
      ],
    );
  }
}

class _FaixaOrigem extends StatelessWidget {
  const _FaixaOrigem({required this.clima, required this.controle});

  final Clima clima;
  final ClimaController controle;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final offline = clima.origem != OrigemClima.rede;
    final texto = Textos.origemClima(clima.origem, clima.obtidoEm, controle.ultimaFalha);
    return Semantics(
      liveRegion: true,
      label: texto,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppEspaco.md),
        decoration: BoxDecoration(
          color: offline ? esquema.errorContainer : esquema.primaryContainer,
          borderRadius: BorderRadius.circular(AppRaio.sm),
        ),
        child: Row(
          children: [
            Icon(
              offline ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
              color: offline ? esquema.onErrorContainer : esquema.onPrimaryContainer,
            ),
            const SizedBox(width: AppEspaco.sm),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(color: offline ? esquema.onErrorContainer : esquema.onPrimaryContainer),
              ),
            ),
            if (controle.atualizando)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
