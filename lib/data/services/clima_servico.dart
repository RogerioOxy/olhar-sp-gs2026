import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/clima.dart';
import 'armazenamento_local.dart';

enum FalhaClima { semConexao, tempoEsgotado, servidor, formato }

class ClimaExcecao implements Exception {
  const ClimaExcecao(this.falha);

  final FalhaClima falha;
}

class ClimaServico {
  ClimaServico({
    required this.armazenamento,
    http.Client? cliente,
    LeitorPacote? leitorPacote,
    DateTime Function()? relogio,
  }) : _cliente = cliente ?? http.Client(),
       _leitorPacote = leitorPacote ?? rootBundle.loadString,
       _relogio = relogio ?? DateTime.now;

  static const latitude = -23.55;
  static const longitude = -46.63;
  static const caminhoPacote = 'assets/dados/clima_snapshot.json';
  static const tempoLimite = Duration(seconds: 10);

  final ArmazenamentoLocal armazenamento;
  final http.Client _cliente;
  final LeitorPacote _leitorPacote;
  final DateTime Function() _relogio;

  Uri get uri => Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '$latitude',
    'longitude': '$longitude',
    'daily': 'precipitation_sum,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    'past_days': '30',
    'forecast_days': '7',
    'timezone': 'America/Sao_Paulo',
  });

  Future<Clima> buscarNaRede() async {
    final http.Response resposta;
    try {
      resposta = await _cliente.get(uri).timeout(tempoLimite);
    } on TimeoutException {
      throw const ClimaExcecao(FalhaClima.tempoEsgotado);
    } on SocketException {
      throw const ClimaExcecao(FalhaClima.semConexao);
    } on http.ClientException {
      throw const ClimaExcecao(FalhaClima.semConexao);
    }
    if (resposta.statusCode != 200) throw const ClimaExcecao(FalhaClima.servidor);
    final agora = _relogio();
    final Clima clima;
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      clima = Clima.fromOpenMeteo(corpo, obtidoEm: agora, origem: OrigemClima.rede);
      await armazenamento.gravarJson(ArmazenamentoLocal.chaveClima, {
        'salvoEm': agora.toIso8601String(),
        'corpo': corpo,
      });
    } on Object catch (e) {
      if (e is ClimaExcecao) rethrow;
      throw const ClimaExcecao(FalhaClima.formato);
    }
    return clima;
  }

  Clima? lerCache() => _deEnvelope(armazenamento.json(ArmazenamentoLocal.chaveClima), OrigemClima.cache);

  Future<Clima?> lerPacote() async {
    try {
      return _deEnvelope(jsonDecode(await _leitorPacote(caminhoPacote)), OrigemClima.pacote);
    } on Object {
      return null;
    }
  }

  Clima? _deEnvelope(Object? envelope, OrigemClima origem) {
    if (envelope is! Map<String, dynamic>) return null;
    final salvoEm = DateTime.tryParse(envelope['salvoEm'] as String? ?? '');
    final corpo = envelope['corpo'];
    if (salvoEm == null || corpo is! Map<String, dynamic>) return null;
    try {
      return Clima.fromOpenMeteo(corpo, obtidoEm: salvoEm, origem: origem);
    } on Object {
      return null;
    }
  }
}

typedef LeitorPacote = Future<String> Function(String caminho);
