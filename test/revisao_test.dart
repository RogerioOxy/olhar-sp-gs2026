import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeladoria_sp/core/textos.dart';
import 'package:zeladoria_sp/core/widgets/alerta_card.dart';
import 'package:zeladoria_sp/data/models/clima.dart';
import 'package:zeladoria_sp/data/models/registro_local.dart';
import 'package:zeladoria_sp/data/models/territorio.dart';
import 'package:zeladoria_sp/data/services/armazenamento_local.dart';
import 'package:zeladoria_sp/data/services/clima_servico.dart';
import 'package:zeladoria_sp/data/services/territorio_repositorio.dart';
import 'package:zeladoria_sp/domain/alertas.dart';
import 'package:zeladoria_sp/domain/anonimizacao.dart';
import 'package:zeladoria_sp/domain/equidade.dart';
import 'package:zeladoria_sp/domain/previsao.dart';
import 'package:zeladoria_sp/domain/series.dart';
import 'package:zeladoria_sp/main.dart';
import 'package:zeladoria_sp/state/controladores.dart';

import 'apoio.dart';

Territorio _comFuturoAlterado(Territorio t, int corte) => Territorio(
  meses: t.meses,
  amostraVistoria: t.amostraVistoria,
  semente: t.semente,
  distritos: [
    for (final d in t.distritos)
      Distrito(
        id: d.id,
        nome: d.nome,
        zona: d.zona,
        faixaRenda: d.faixaRenda,
        populacao: d.populacao,
        categorias: d.categorias,
        registrados: [for (var i = 0; i < d.registrados.length; i++) i >= corte ? 50000 : d.registrados[i]],
        atendidos: d.atendidos,
        achadosVistoria: d.achadosVistoria,
      ),
  ],
);

Future<void> _abrirApp(WidgetTester tester, Map<String, Object> prefs, {double escala = 1}) async {
  tester.view.physicalSize = const Size(720, 1560);
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  SharedPreferences.setMockInitialValues(prefs);
  final armazenamento = await ArmazenamentoLocal.abrir();
  await tester.pumpWidget(
    ZeladoriaApp(
      armazenamento: armazenamento,
      territorioRepositorio: TerritorioRepositorio(leitor: (_) async => jsonTerritorio),
      climaServico: ClimaServico(
        armazenamento: armazenamento,
        cliente: clienteOk(DateTime.now()),
        leitorPacote: (_) async => jsonClimaPacote,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _gestor = <String, Object>{
  ArmazenamentoLocal.chaveConsentimento: '2026-11-16T10:00:00.000',
  ArmazenamentoLocal.chavePerfil: 'gestor',
  ArmazenamentoLocal.chaveDistrito: 'grajau',
};

void main() {
  final t = territorioDeTeste();

  test('previsão não usa meses do futuro nem no índice sazonal da cidade', () {
    for (final corte in [14, 18, 22]) {
      final original = ModeloPrevisao(t);
      final alterado = ModeloPrevisao(_comFuturoAlterado(t, corte));
      for (var i = 0; i < t.distritos.length; i++) {
        expect(
          alterado.prever(alterado.territorio.distritos[i], corte),
          closeTo(original.prever(t.distritos[i], corte)!, 1e-9),
        );
      }
    }
  });

  test('MAPE é a média dos erros percentuais de cada ponto', () {
    const r = ResultadoBacktest([PontoBacktest(0, 90, 100), PontoBacktest(1, 30, 20)]);
    expect(r.mape, closeTo((0.10 + 0.50) / 2, 1e-12));
    expect(r.mae, closeTo(10, 1e-12));
  });

  test('anonimização cobre nome declarado e número na rua', () {
    final s = anonimizar('Sou João da Silva, moro na Rua Alfa 123 perto da praça', marcador: '[x]');
    expect(s, isNot(contains('João')));
    expect(s, isNot(contains('Silva')));
    expect(s, isNot(contains('123')));
    expect(s, contains('Rua Alfa'));
    expect(contemDadoPessoal('meu nome é Maria Souza'), isTrue);
    expect(contemDadoPessoal('Poste apagado na Rua Alfa'), isFalse);
    expect(anonimizar('Buraco na Rua 25 de Março', marcador: '[x]'), 'Buraco na Rua 25 de Março');
    expect(anonimizar('Sou morador e vi o poste apagado', marcador: '[x]'), 'Sou morador e vi o poste apagado');
    expect(anonimizar('Sou Morador do bairro', marcador: '[x]'), 'Sou Morador do bairro');
  });

  test('cache do clima com tipo errado é ignorado', () async {
    SharedPreferences.setMockInitialValues({
      ArmazenamentoLocal.chaveClima: jsonEncode({'salvoEm': 123, 'corpo': <String, dynamic>{}}),
    });
    final servico = ClimaServico(
      armazenamento: await ArmazenamentoLocal.abrir(),
      cliente: clienteOffline(),
      leitorPacote: (_) async => jsonClimaPacote,
    );
    expect(servico.lerCache(), isNull);
    expect(await servico.lerPacote(), isNotNull);
  });

  test('duas exclusões seguidas não ressuscitam ocorrência', () async {
    SharedPreferences.setMockInitialValues({});
    final c = OcorrenciasController(await ArmazenamentoLocal.abrir());
    final a = await c.registrar(
      distritoId: 'moema',
      categoria: Categoria.poda,
      descricao: 'galho caido na calcada',
      referencia: '',
      marcadorRemovido: '[x]',
    );
    final b = await c.registrar(
      distritoId: 'moema',
      categoria: Categoria.buraco,
      descricao: 'buraco grande na via',
      referencia: '',
      marcadorRemovido: '[x]',
    );
    await Future.wait([c.remover(a.id), c.remover(b.id)]);
    expect(c.ocorrencias, isEmpty);
    final releitura = OcorrenciasController(await ArmazenamentoLocal.abrir());
    expect(releitura.ocorrencias, isEmpty);
  });

  test('dados salvos com tipo errado não derrubam a leitura', () {
    final l = Limiares.fromJson({'pico': 'vinte', 'chuva': true});
    expect(l, const Limiares());
    expect(Ocorrencia.fromJson({'categoria': 123, 'criadaEm': 5, 'distritoId': 'x'}), isNull);
    expect(RegistroDecisao.fromJson({'decisao': 1, 'em': null}), isNull);
  });

  test('previsão vencida do cache não aparece como chuva observada', () {
    final coleta = DateTime(2026, 11, 16, 10);
    final c = Clima.fromOpenMeteo(respostaOpenMeteo(coleta), obtidoEm: coleta, origem: OrigemClima.cache);
    final depois = DateTime(2026, 11, 19);
    expect(c.historico(depois).every((d) => d.data.isBefore(DateTime(2026, 11, 16))), isTrue);
    expect(c.previsao(depois).first.data, DateTime(2026, 11, 19));
    final resumo = ResumoClima.de(c, DateTime(2026, 11, 21));
    expect(resumo.diasPrevistos, 2);
    expect(resumo.previsaoCompleta, isFalse);
  });

  test('sem 3 dias de previsão não há alerta de chuva', () {
    final coleta = DateTime(2026, 11, 16);
    final c = Clima.fromOpenMeteo(
      respostaOpenMeteo(coleta, chuvaProximos: [80, 80, 80, 80, 80, 80, 80]),
      obtidoEm: coleta,
      origem: OrigemClima.cache,
    );
    MotorAlertas motor(DateTime agora) => MotorAlertas(
      territorio: t,
      previsoes: ModeloPrevisao(t).todos(),
      equidade: AnaliseEquidade(t),
      limiares: const Limiares(),
      ocorrencias: const [],
      clima: c,
      agora: agora,
    );
    expect(motor(DateTime(2026, 11, 17)).gerar().any((a) => a.tipo == TipoAlerta.chuvaForte), isTrue);
    expect(motor(DateTime(2026, 11, 21)).gerar().any((a) => a.tipo == TipoAlerta.chuvaForte), isFalse);
  });

  test('decisão registrada vale só para a mesma evidência do alerta', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferenciasController(await ArmazenamentoLocal.abrir());
    final previsoes = ModeloPrevisao(t).todos();
    List<Alerta> gerar(List<Ocorrencia> oc) => MotorAlertas(
      territorio: t,
      previsoes: previsoes,
      equidade: AnaliseEquidade(t),
      limiares: const Limiares(ocorrencias7Dias: 1),
      ocorrencias: oc,
      clima: null,
      agora: DateTime(2026, 11, 16),
    ).gerar();
    Ocorrencia o(String id) => Ocorrencia(
      id: id,
      distritoId: 'moema',
      categoria: Categoria.poda,
      descricao: 'galho caido na calcada',
      referencia: '',
      criadaEm: DateTime(2026, 11, 15),
    );
    final a1 = gerar([o('a')]).firstWhere((a) => a.id == 'cidadao-moema');
    await prefs.registrarDecisao(a1, DecisaoHumana.monitorar);
    expect(prefs.decisaoPara(a1)?.decisao, DecisaoHumana.monitorar);
    final a2 = gerar([o('a'), o('b')]).firstWhere((a) => a.id == 'cidadao-moema');
    expect(prefs.decisaoPara(a2), isNull);
  });

  testWidgets('cartão de alerta expõe ação de toque ao leitor de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await _abrirApp(tester, _gestor);
    final card = find.byType(AlertaCard).first;
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(card), isSemantics(isButton: true, hasTapAction: true));
    tester.semantics.tap(find.semantics.byLabel(RegExp(Textos.alertaTitulo(TipoAlerta.picoDemanda))).first);
    await tester.pumpAndSettle();
    expect(find.text(Textos.justificativaTitulo), findsOneWidget);
    handle.dispose();
  });

  testWidgets('fonte em 200% nos três painéis, no indicador e no alerta', (tester) async {
    await _abrirApp(tester, _gestor, escala: 2);
    Future<void> tocar(Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    Finder aba(String r) => find.descendant(of: find.byType(NavigationBar), matching: find.text(r));
    await tocar(aba(Textos.navPaineis));
    await tocar(find.text(Textos.painelClimaTitulo));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(find.text(Textos.painelEquidadeTitulo));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tocar(find.text(Textos.painelDemandaTitulo));
    await tocar(find.text('Grajaú'));
    await tocar(find.text(Textos.alertaTitulo(TipoAlerta.picoDemanda)));
    expect(find.text(Textos.justificativaTitulo), findsOneWidget);
  });

  testWidgets('apagar todos os dados limpa ocorrências e volta ao consentimento', (tester) async {
    await _abrirApp(tester, {
      ..._gestor,
      ArmazenamentoLocal.chaveOcorrencias: jsonEncode([
        Ocorrencia(
          id: 'abc',
          distritoId: 'moema',
          categoria: Categoria.poda,
          descricao: 'galho caido na calcada',
          referencia: '',
          criadaEm: DateTime(2026, 11, 15),
        ).toJson(),
      ]),
    });
    final aba = find.descendant(of: find.byType(NavigationBar), matching: find.text(Textos.navAjustes));
    await tester.tap(aba);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Textos.apagarDadosBotao));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Textos.apagarDadosBotao));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Textos.apagarDadosConfirmar));
    await tester.pumpAndSettle();
    expect(find.text(Textos.consentimentoTitulo), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ArmazenamentoLocal.chaveOcorrencias), isNull);
  });
}
