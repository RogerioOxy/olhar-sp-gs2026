import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeladoria_sp/core/textos.dart';
import 'package:zeladoria_sp/data/models/registro_local.dart';
import 'package:zeladoria_sp/data/models/territorio.dart';
import 'package:zeladoria_sp/data/services/armazenamento_local.dart';
import 'package:zeladoria_sp/data/services/clima_servico.dart';
import 'package:zeladoria_sp/data/services/territorio_repositorio.dart';
import 'package:zeladoria_sp/domain/alertas.dart';
import 'package:zeladoria_sp/main.dart';

import 'apoio.dart';

final _hoje = DateTime.now();

Map<String, Object> _consentido({String perfil = 'gestor', Map<String, int>? limiares}) => {
  ArmazenamentoLocal.chaveConsentimento: DateTime(2026, 11, 16).toIso8601String(),
  ArmazenamentoLocal.chavePerfil: perfil,
  ArmazenamentoLocal.chaveDistrito: 'grajau',
  if (limiares != null) ArmazenamentoLocal.chaveLimiares: jsonEncode(limiares),
};

Future<void> _abrir(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  http.Client? cliente,
  bool comPacote = true,
  Size tamanho = const Size(412, 915),
  double escalaTexto = 1.0,
}) async {
  tester.view.physicalSize = tamanho * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = escalaTexto;
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
        cliente: cliente ?? clienteOk(_hoje),
        leitorPacote: (_) async => comPacote ? jsonClimaPacote : throw Exception('sem pacote'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _aba(String rotulo) => find.descendant(of: find.byType(NavigationBar), matching: find.text(rotulo));

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('primeiro uso pede consentimento e não avança sem aceite', (tester) async {
    await _abrir(tester);
    expect(find.text(Textos.consentimentoTitulo), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.consentimentoBotao));
    expect(find.text(Textos.consentimentoErro), findsOneWidget);
    expect(find.text(Textos.erroObrigatorio), findsOneWidget);

    await _tocar(tester, find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.textContaining('Grajaú').last);
    await tester.pumpAndSettle();
    await _tocar(tester, find.byType(CheckboxListTile));
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.consentimentoBotao));
    expect(find.text(Textos.inicioCidadaoTitulo), findsOneWidget);
    expect(find.text(Textos.meuDistritoTitulo('Grajaú')), findsWidgets);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ArmazenamentoLocal.chaveConsentimento), isNotNull);
  });

  testWidgets('gestor pode consentir sem escolher distrito', (tester) async {
    await _abrir(tester);
    await _tocar(tester, find.text(Textos.perfilNome(Perfil.gestor)));
    await _tocar(tester, find.byType(CheckboxListTile));
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.consentimentoBotao));
    expect(find.text(Textos.inicioGestorTitulo), findsOneWidget);
  });

  testWidgets('fluxo visão geral -> detalhe do indicador -> detalhe do alerta', (tester) async {
    await _abrir(tester, prefs: _consentido());
    expect(find.text(Textos.inicioGestorTitulo), findsOneWidget);
    await _tocar(tester, find.text('Grajaú').first);
    expect(find.text(Textos.indicadorTituloDe('Grajaú')), findsOneWidget);
    expect(find.text(Textos.backtestTitulo), findsOneWidget);
    await _tocar(tester, find.text(Textos.alertaTitulo(TipoAlerta.picoDemanda)).first);
    expect(find.text(Textos.justificativaTitulo), findsOneWidget);
    expect(find.text(Textos.confiancaTitulo), findsOneWidget);
    expect(find.text(Textos.limitacoesTitulo), findsOneWidget);
    expect(find.text(Textos.avisoDecisaoTitulo), findsWidgets);
    expect(find.text(Textos.decisaoTitulo), findsOneWidget);
  });

  testWidgets('salvar limiar mais sensível gera alerta novo ao vivo', (tester) async {
    await _abrir(tester, prefs: _consentido());
    await _tocar(tester, _aba(Textos.navAjustes));
    await _tocar(tester, find.text(Textos.limiaresTitulo));
    final campo = find.widgetWithText(TextFormField, Textos.limiarPicoRotulo);
    await tester.enterText(campo, '0');
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.limiaresSalvar));
    expect(find.text(Textos.erroFaixa(5, 100)), findsOneWidget);
    await tester.enterText(campo, '8');
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.limiaresSalvar));
    expect(find.byType(SnackBar), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ArmazenamentoLocal.chaveLimiares), contains('"pico":8'));
  });

  testWidgets('registrar ocorrência valida campos e gera alerta quando atinge o limiar', (tester) async {
    await _abrir(tester, prefs: _consentido(perfil: 'cidadao', limiares: {'ocorrencias': 1}));
    await _tocar(tester, _aba(Textos.navRegistrar));
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.registrarBotao));
    expect(find.text(Textos.erroDescricaoVazia), findsOneWidget);
    expect(find.text(Textos.registrarConsentimentoErro), findsOneWidget);
    expect(find.text(Textos.erroObrigatorio), findsOneWidget);

    await _tocar(tester, find.byType(DropdownButtonFormField<Categoria>));
    await tester.tap(find.text(Textos.categoria(Categoria.bocaDeLobo)).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, Textos.campoDescricao),
      'Boca de lobo entupida, me liga 11 91234-5678',
    );
    await tester.pumpAndSettle();
    expect(find.text(Textos.avisoDadoPessoal), findsOneWidget);
    await _tocar(tester, find.byType(CheckboxListTile));
    await _tocar(tester, find.widgetWithText(FilledButton, Textos.registrarBotao));
    expect(find.text(Textos.ocorrenciaSalvaTitulo), findsOneWidget);
    expect(find.text(Textos.ocorrenciaGerouAlerta(1)), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getString(ArmazenamentoLocal.chaveOcorrencias)!;
    expect(salvo, isNot(contains('91234')));
    expect(salvo, contains(Textos.marcadorRemovido));
    await _tocar(tester, find.text(Textos.verAlerta));
    expect(find.text(Textos.alertaTitulo(TipoAlerta.ocorrenciasCidadao)), findsWidgets);
  });

  testWidgets('sem internet o clima usa o último dado salvo e avisa', (tester) async {
    await _abrir(tester, prefs: _consentido(), cliente: clienteOffline());
    await _tocar(tester, _aba(Textos.navPaineis));
    await _tocar(tester, find.text(Textos.painelClimaTitulo));
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text(Textos.climaChuvaTitulo), findsOneWidget);
  });

  testWidgets('sem internet e sem dado salvo o clima mostra erro com nova tentativa', (tester) async {
    await _abrir(tester, prefs: _consentido(), cliente: clienteOffline(), comPacote: false);
    await _tocar(tester, _aba(Textos.navPaineis));
    await _tocar(tester, find.text(Textos.painelClimaTitulo));
    expect(find.text(Textos.erroClimaTitulo), findsOneWidget);
    expect(find.text(Textos.tentarDeNovo), findsOneWidget);
    await _tocar(tester, _aba(Textos.navInicio));
    expect(find.text(Textos.inicioGestorTitulo), findsOneWidget);
  });

  testWidgets('painel de equidade mostra o rótulo de dado sintético', (tester) async {
    await _abrir(tester, prefs: _consentido());
    await _tocar(tester, _aba(Textos.navPaineis));
    await _tocar(tester, find.text(Textos.painelEquidadeTitulo));
    expect(find.text(Textos.rotuloSintetico), findsWidgets);
    expect(find.text(Textos.socialTitulo), findsWidgets);
  });

  testWidgets('estado global compartilhado: perfil trocado em Ajustes muda o Início', (tester) async {
    await _abrir(tester, prefs: _consentido());
    expect(find.text(Textos.inicioGestorTitulo), findsOneWidget);
    await _tocar(tester, _aba(Textos.navAjustes));
    await _tocar(tester, find.text(Textos.perfilNome(Perfil.cidadao)).first);
    await _tocar(tester, _aba(Textos.navInicio));
    expect(find.text(Textos.inicioCidadaoTitulo), findsOneWidget);
  });

  group('acessibilidade', () {
    for (final (nome, tamanho) in [('celular', const Size(360, 780)), ('tablet', const Size(800, 1280))]) {
      testWidgets('diretrizes de toque, rótulos e contraste no $nome', (tester) async {
        final handle = tester.ensureSemantics();
        await _abrir(tester, prefs: _consentido(), tamanho: tamanho);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await _tocar(tester, _aba(Textos.navAlertas));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await _tocar(tester, _aba(Textos.navRegistrar));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }

    testWidgets('fonte ampliada em 200% não quebra as telas principais', (tester) async {
      await _abrir(tester, prefs: _consentido(), tamanho: const Size(360, 780), escalaTexto: 2.0);
      expect(tester.takeException(), isNull);
      for (final aba in [Textos.navPaineis, Textos.navAlertas, Textos.navRegistrar, Textos.navAjustes]) {
        await tester.tap(find.text(aba));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
