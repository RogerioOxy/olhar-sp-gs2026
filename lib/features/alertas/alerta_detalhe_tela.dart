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
import '../../data/models/registro_local.dart';
import '../../domain/alertas.dart';
import '../../domain/series.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class AlertaDetalheTela extends StatefulWidget {
  const AlertaDetalheTela({super.key, required this.alertaId});

  final String alertaId;

  @override
  State<AlertaDetalheTela> createState() => _AlertaDetalheTelaState();
}

class _AlertaDetalheTelaState extends State<AlertaDetalheTela> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AlertasController>().marcarVisto(widget.alertaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerta = context.select<AlertasController, Alerta?>((c) => c.porId(widget.alertaId));
    return Scaffold(
      appBar: AppBar(title: Text(alerta == null ? Textos.alertaTituloTela : Textos.alertaTitulo(alerta.tipo))),
      body: ComTerritorio(
        builder: (context, t, c) {
          if (alerta == null) {
            return MensagemView(
              icone: Icons.notifications_off_outlined,
              titulo: Textos.alertaInativoTitulo,
              mensagem: Textos.alertaInativoTexto,
              acaoRotulo: Textos.verTodos,
              onAcao: () => context.goNamed(Rotas.alertas),
            );
          }
          return _Detalhe(alerta: alerta, controle: c);
        },
      ),
    );
  }
}

/// Mostra as evidências do alerta e consulta a decisão salva para ele.
class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.alerta, required this.controle});

  final Alerta alerta;
  final TerritorioController controle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final prefs = context.watch<PreferenciasController>();
    final decisao = prefs.decisaoPara(alerta);
    final gestor = prefs.perfil == Perfil.gestor;
    final noIndicador = GoRouterState.of(context).name == Rotas.alertaDoIndicador;
    return PaginaRolavel(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: tema.colorScheme.primaryContainer,
              foregroundColor: tema.colorScheme.onPrimaryContainer,
              child: Icon(iconeDoAlerta(alerta.tipo)),
            ),
            const SizedBox(width: AppEspaco.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(alerta.distrito.nome, style: tema.textTheme.titleLarge),
                  ),
                  const SizedBox(height: AppEspaco.xs),
                  Wrap(
                    spacing: AppEspaco.sm,
                    runSpacing: AppEspaco.xs,
                    children: [
                      SeloPrioridade(alerta.prioridade),
                      SeloConfianca(alerta.confianca),
                      if (alerta.tipo == TipoAlerta.subRegistro || alerta.tipo == TipoAlerta.picoDemanda || alerta.tipo == TipoAlerta.quedaRegistro)
                        const RotuloSintetico(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(Textos.alertaResumo(alerta), style: tema.textTheme.bodyLarge),
        const AvisoDecisaoHumana(),
        Secao(
          titulo: Textos.justificativaTitulo,
          subtitulo: Textos.justificativaSubtitulo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListaMarcadores(itens: Textos.alertaJustificativa(alerta)),
              _GraficoEvidencia(alerta: alerta, controle: controle),
            ],
          ),
        ),
        Secao(
          titulo: Textos.confiancaTitulo,
          acao: SeloConfianca(alerta.confianca),
          child: Text(Textos.alertaConfiancaExplicacao(alerta)),
        ),
        Secao(
          titulo: Textos.limitacoesTitulo,
          child: ListaMarcadores(itens: Textos.alertaLimitacoes(alerta.tipo)),
        ),
        Secao(
          titulo: Textos.comoCalculadoTitulo,
          child: Text(Textos.alertaComoCalculado(alerta.tipo)),
        ),
        Secao(
          titulo: Textos.sugestoesTitulo,
          subtitulo: Textos.sugestoesSubtitulo,
          child: ListaMarcadores(itens: Textos.alertaSugestoes(alerta.tipo)),
        ),
        if (gestor)
          _DecisaoHumana(alerta: alerta, atual: decisao)
        else
          FilledButton.tonalIcon(
            onPressed: () => context.goNamed(Rotas.registrar, queryParameters: {'distrito': alerta.distrito.id}),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(Textos.registrarNesteDistrito),
          ),
        if (!noIndicador)
          OutlinedButton.icon(
            onPressed: () => context.goNamed(Rotas.indicador, pathParameters: {'distritoId': alerta.distrito.id}),
            icon: const Icon(Icons.insights_outlined),
            label: Text(Textos.verIndicadorDistrito),
          ),
      ],
    );
  }
}

class _GraficoEvidencia extends StatelessWidget {
  const _GraficoEvidencia({required this.alerta, required this.controle});

  final Alerta alerta;
  final TerritorioController controle;

  @override
  Widget build(BuildContext context) {
    final painel = CoresDoPainel.de(context);
    final t = controle.territorio!;
    switch (alerta.tipo) {
      case TipoAlerta.picoDemanda:
      case TipoAlerta.quedaRegistro:
        final p = controle.previsaoDe(alerta.distrito.id)!;
        return Padding(
          padding: const EdgeInsets.only(top: AppEspaco.md),
          child: GraficoLinha(
            descricao: Textos.graficoDistritoDescricao(alerta.distrito.nome, p.ultimoReal, p.ultimoPrevisto),
            rotulosX: ultimos(t.meses, 12).map(Textos.mesCurto).toList(),
            marcarIndice: 11,
            formatarY: (v) => inteiro(v),
            series: [
              SerieGrafico(
                rotulo: Textos.serieRegistrados,
                valores: ultimos(alerta.distrito.registrados.map((v) => v.toDouble()).toList(), 12),
                cor: painel.serieReal,
              ),
              SerieGrafico(
                rotulo: Textos.seriePrevistos,
                valores: ultimos(p.previstosHistorico, 12),
                cor: painel.seriePrevista,
                tracejada: true,
                faixa: List<double?>.filled(12, p.backtest.rmse * 1.28),
              ),
            ],
          ),
        );
      case TipoAlerta.chuvaForte:
        final clima = context.watch<ClimaController>().clima;
        if (clima == null) return const SizedBox.shrink();
        final prev = clima.previsao(DateTime.now());
        return Padding(
          padding: const EdgeInsets.only(top: AppEspaco.md),
          child: GraficoBarras(
            descricao: Textos.chuvaPrevistaDescricao(alerta.valores['chuva3DiasMm']!.toDouble(), 3),
            itens: [
              for (final d in prev)
                BarraItem(
                  rotulo: Textos.diaSemana(d.data),
                  valor: d.chuvaMm,
                  textoValor: '${decimal(d.chuvaMm)} mm',
                  cor: painel.serieAuxiliar,
                ),
            ],
          ),
        );
      case TipoAlerta.subRegistro:
      case TipoAlerta.ocorrenciasCidadao:
        return const SizedBox.shrink();
    }
  }
}

/// Registra uma escolha local; os botões não executam serviços de zeladoria.
class _DecisaoHumana extends StatelessWidget {
  const _DecisaoHumana({required this.alerta, required this.atual});

  final Alerta alerta;
  final RegistroDecisao? atual;

  @override
  Widget build(BuildContext context) {
    return Secao(
      titulo: Textos.decisaoTitulo,
      subtitulo: Textos.decisaoSubtitulo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (atual != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppEspaco.sm),
              child: Text(Textos.decisaoAtual(atual!.decisao, dataHora(atual!.em))),
            ),
          Wrap(
            spacing: AppEspaco.sm,
            runSpacing: AppEspaco.sm,
            children: [
              for (final d in DecisaoHumana.values)
                ChoiceChip(
                  label: Text(Textos.decisaoOpcao(d)),
                  selected: atual?.decisao == d,
                  onSelected: (_) async {
                    final mensageiro = ScaffoldMessenger.of(context);
                    String mensagem;
                    try {
                      await context.read<PreferenciasController>().registrarDecisao(alerta, d);
                      mensagem = Textos.decisaoSalva(d);
                    } on Object {
                      mensagem = Textos.erroSalvar;
                    }
                    mensageiro
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(mensagem)));
                  },
                ),
            ],
          ),
          const SizedBox(height: AppEspaco.sm),
          Text(Textos.decisaoNota, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
