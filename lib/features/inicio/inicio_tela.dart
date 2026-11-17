import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/alerta_card.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/campos.dart';
import '../../core/widgets/com_territorio.dart';
import '../../core/widgets/estados.dart';
import '../../core/widgets/graficos.dart';
import '../../data/models/registro_local.dart';
import '../../data/models/territorio.dart';
import '../../domain/alertas.dart';
import '../../domain/series.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class InicioTela extends StatelessWidget {
  const InicioTela({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.select<PreferenciasController, Perfil>((p) => p.perfil);
    return Scaffold(
      appBar: AppBar(
        title: Text(perfil == Perfil.gestor ? Textos.inicioGestorTitulo : Textos.inicioCidadaoTitulo),
        actions: [
          IconButton(
            tooltip: Textos.trocarPerfilDica(perfil),
            icon: Icon(perfil == Perfil.gestor ? Icons.person_pin_circle_outlined : Icons.dashboard_outlined),
            onPressed: () => context.read<PreferenciasController>().definirPerfil(
              perfil == Perfil.gestor ? Perfil.cidadao : Perfil.gestor,
            ),
          ),
        ],
      ),
      body: ComTerritorio(
        builder: (context, t, c) => perfil == Perfil.gestor ? _VisaoGestor(t, c) : _VisaoCidadao(t, c),
      ),
    );
  }
}

class _VisaoGestor extends StatelessWidget {
  const _VisaoGestor(this.t, this.c);

  final Territorio t;
  final TerritorioController c;

  @override
  Widget build(BuildContext context) {
    final alertas = context.watch<AlertasController>().alertas;
    final clima = context.watch<ClimaController>();
    final painel = CoresDoPainel.de(context);
    final resumo = c.resumo!;
    final social = c.social!;
    final altas = alertas.where((a) => a.prioridade == Prioridade.alta).length;
    final rc = clima.clima == null ? null : ResumoClima.de(clima.clima!, DateTime.now());
    final rotulos = ultimos(t.meses, 12).map(Textos.mesCurto).toList();
    final desvios = [...c.previsoes]..sort((a, b) => b.desvio.abs().compareTo(a.desvio.abs()));
    return PaginaRolavel(
      onRefresh: () => context.read<ClimaController>().atualizar(),
      children: [
        Text(Textos.inicioGestorIntro, style: Theme.of(context).textTheme.bodyLarge),
        const AvisoDecisaoHumana(compacto: true),
        GradeResponsiva(
          colunasTablet: 4,
          children: [
            Kpi(
              rotulo: Textos.kpiAlertas,
              valor: inteiro(alertas.length),
              detalhe: Textos.kpiAlertasDetalhe(altas),
              icone: Icons.notifications_active_outlined,
              cor: painel.alertaAlerta,
              onTap: () => context.goNamed(Rotas.alertas),
            ),
            Kpi(
              rotulo: Textos.kpiAcerto,
              valor: percentual(resumo.mapeGeral, 1),
              detalhe: Textos.kpiAcertoDetalhe(resumo.maeMedio, resumo.meses),
              icone: Icons.fact_check_outlined,
              onTap: () => context.goNamed(Rotas.sobreDados),
            ),
            Kpi(
              rotulo: Textos.kpiSocial,
              valor: decimal(social.diferencaAtual),
              detalhe: Textos.kpiSocialDetalhe(social.atualBaixa, social.atualAlta),
              icone: Icons.balance_outlined,
              cor: painel.sintetico,
              onTap: () => context.goNamed(Rotas.painelEquidade),
            ),
            Kpi(
              rotulo: Textos.kpiChuva,
              valor: rc == null || !rc.previsaoCompleta ? Textos.semDado : '${decimal(rc.chuvaProximos3)} mm',
              detalhe: rc == null
                  ? Textos.climaIndisponivelCurto
                  : rc.previsaoCompleta
                  ? Textos.kpiChuvaDetalhe(rc.probMaxProximos3)
                  : Textos.climaPrevisaoParcial(rc.diasPrevistos),
              icone: Icons.water_drop_outlined,
              cor: painel.serieAuxiliar,
              onTap: () => context.goNamed(Rotas.painelClima),
            ),
          ],
        ),
        Secao(
          titulo: Textos.inicioDemandaTitulo,
          subtitulo: Textos.inicioDemandaSubtitulo,
          acao: TextButton(
            onPressed: () => context.goNamed(Rotas.painelDemanda),
            child: Text(Textos.verPainel),
          ),
          child: GraficoLinha(
            descricao: Textos.graficoCidadeDescricao(
              ultimos(somaRegistrados(c.previsoes), 12).last,
              ultimos(somaPrevistos(c.previsoes), 12).last ?? 0,
            ),
            rotulosX: rotulos,
            series: [
              SerieGrafico(
                rotulo: Textos.serieRegistrados,
                valores: ultimos(somaRegistrados(c.previsoes), 12),
                cor: painel.serieReal,
              ),
              SerieGrafico(
                rotulo: Textos.seriePrevistos,
                valores: ultimos(somaPrevistos(c.previsoes), 12),
                cor: painel.seriePrevista,
                tracejada: true,
              ),
            ],
            formatarY: (v) => inteiro(v),
          ),
        ),
        Secao(
          titulo: Textos.inicioDesviosTitulo,
          subtitulo: Textos.inicioDesviosSubtitulo,
          child: Column(
            children: [
              for (final p in desvios.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(p.desvio >= 0 ? Icons.arrow_upward : Icons.arrow_downward),
                  title: Text(p.distrito.nome),
                  subtitle: Text(Textos.desvioLinha(p.ultimoReal, p.ultimoPrevisto, p.desvio)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(Rotas.indicador, pathParameters: {'distritoId': p.distrito.id}),
                ),
            ],
          ),
        ),
        Secao(
          titulo: Textos.inicioAlertasTitulo,
          acao: TextButton(onPressed: () => context.goNamed(Rotas.alertas), child: Text(Textos.verTodos)),
          child: alertas.isEmpty
              ? VazioView(titulo: Textos.alertasVazioTitulo, mensagem: Textos.alertasVazioTexto)
              : Column(
                  children: [
                    for (final a in alertas.take(3)) ...[
                      AlertaCard(
                        alerta: a,
                        onTap: () => context.goNamed(Rotas.alerta, pathParameters: {'alertaId': a.id}),
                      ),
                      const SizedBox(height: AppEspaco.sm),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _VisaoCidadao extends StatelessWidget {
  const _VisaoCidadao(this.t, this.c);

  final Territorio t;
  final TerritorioController c;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferenciasController>();
    final id = prefs.meuDistritoId;
    final d = id == null ? null : t.distrito(id);
    if (d == null) {
      return PaginaRolavel(
        children: [
          VazioView(
            icone: Icons.place_outlined,
            titulo: Textos.meuDistritoVazioTitulo,
            mensagem: Textos.meuDistritoVazioTexto,
          ),
          CampoDistrito(
            territorio: c,
            valor: null,
            obrigatorio: false,
            onChanged: (v) {
              if (v != null) prefs.definirDistrito(v);
            },
          ),
        ],
      );
    }
    final p = c.previsaoDe(d.id)!;
    final painel = CoresDoPainel.de(context);
    final alertas = context.watch<AlertasController>().doDistrito(d.id);
    final minhas = context.watch<OcorrenciasController>().ocorrencias.where((o) => o.distritoId == d.id).toList();
    final social = c.social!;
    final eq = c.equidade!;
    final n = t.meses.length;
    final atend10k = d.atendidos.sublist(n - 3).fold<int>(0, (s, v) => s + v) / 3 / d.populacao * 10000;
    final sub = eq.subRegistro(d);
    final registrados = ultimos(d.registrados.map((v) => v.toDouble()).toList(), 12);
    final previstos = ultimos(p.previstosHistorico, 12);
    return PaginaRolavel(
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(Textos.meuDistritoTitulo(d.nome), style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            TextButton.icon(
              onPressed: () => _trocar(context, prefs),
              icon: const Icon(Icons.edit_location_alt_outlined),
              label: Text(Textos.trocarDistrito),
            ),
          ],
        ),
        Text(Textos.meuDistritoIntro, style: Theme.of(context).textTheme.bodyLarge),
        GradeResponsiva(
          children: [
            Kpi(
              rotulo: Textos.kpiPrevistoProximo,
              valor: inteiro(p.previstoProximo),
              detalhe: Textos.kpiPrevistoProximoDetalhe(p.faixaProximo),
              icone: Icons.query_stats,
              cor: painel.seriePrevista,
            ),
            Kpi(
              rotulo: Textos.kpiAtendimentoDistrito,
              valor: decimal(atend10k),
              detalhe: Textos.kpiAtendimentoDistritoDetalhe(social.atualBaixa, social.atualAlta),
              icone: Icons.handshake_outlined,
              cor: painel.serieReal,
            ),
          ],
        ),
        Secao(
          titulo: Textos.meuDistritoGraficoTitulo,
          acao: TextButton(
            onPressed: () => context.goNamed(Rotas.indicador, pathParameters: {'distritoId': d.id}),
            child: Text(Textos.verDetalhe),
          ),
          child: GraficoLinha(
            descricao: Textos.graficoDistritoDescricao(d.nome, p.ultimoReal, p.ultimoPrevisto),
            rotulosX: ultimos(t.meses, 12).map(Textos.mesCurto).toList(),
            series: [
              SerieGrafico(rotulo: Textos.serieRegistrados, valores: registrados, cor: painel.serieReal),
              SerieGrafico(
                rotulo: Textos.seriePrevistos,
                valores: previstos,
                cor: painel.seriePrevista,
                tracejada: true,
              ),
            ],
            formatarY: (v) => inteiro(v),
          ),
        ),
        Secao(
          titulo: Textos.meuDistritoAlertasTitulo,
          child: alertas.isEmpty
              ? VazioView(
                  icone: Icons.check_circle_outline,
                  titulo: Textos.meuDistritoSemAlertasTitulo,
                  mensagem: Textos.meuDistritoSemAlertasTexto,
                )
              : Column(
                  children: [
                    for (final a in alertas) ...[
                      AlertaCard(
                        alerta: a,
                        onTap: () => context.goNamed(Rotas.alerta, pathParameters: {'alertaId': a.id}),
                      ),
                      const SizedBox(height: AppEspaco.sm),
                    ],
                    const AvisoDecisaoHumana(compacto: true),
                  ],
                ),
        ),
        Secao(
          titulo: Textos.meuDistritoSubRegistroTitulo,
          acao: const RotuloSintetico(),
          child: Text(Textos.meuDistritoSubRegistroTexto(sub.estimativa, sub.margem)),
        ),
        Secao(
          titulo: Textos.minhasOcorrenciasTitulo,
          acao: FilledButton.tonalIcon(
            onPressed: () => context.goNamed(Rotas.registrar, queryParameters: {'distrito': d.id}),
            icon: const Icon(Icons.add),
            label: Text(Textos.registrarCurto),
          ),
          child: minhas.isEmpty
              ? VazioView(titulo: Textos.minhasOcorrenciasVazioTitulo, mensagem: Textos.minhasOcorrenciasVazioTexto)
              : Column(
                  children: [
                    for (final o in minhas.take(5))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(Textos.categoria(o.categoria)),
                        subtitle: Text('${dataHora(o.criadaEm)} · ${o.descricao}'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _trocar(BuildContext context, PreferenciasController prefs) async {
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppEspaco.lg),
              child: Text(Textos.trocarDistrito, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final d in [...t.distritos]..sort((a, b) => a.nome.compareTo(b.nome)))
              ListTile(
                title: Text(d.nome),
                subtitle: Text(Textos.zona(d.zona)),
                selected: d.id == prefs.meuDistritoId,
                onTap: () => Navigator.of(ctx).pop(d.id),
              ),
          ],
        ),
      ),
    );
    if (escolhido != null) await prefs.definirDistrito(escolhido);
  }
}
