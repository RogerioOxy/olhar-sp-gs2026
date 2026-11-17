import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FalhaDeGravacao implements Exception {
  const FalhaDeGravacao(this.chave);

  final String chave;
}

class ArmazenamentoLocal {
  ArmazenamentoLocal(this._prefs);

  final SharedPreferences _prefs;

  static const chaveConsentimento = 'consentimento_em';
  static const chavePerfil = 'perfil';
  static const chaveDistrito = 'meu_distrito';
  static const chaveTema = 'tema';
  static const chaveLimiares = 'limiares';
  static const chaveOcorrencias = 'ocorrencias';
  static const chaveDecisoes = 'decisoes';
  static const chaveClima = 'clima_cache';

  static Future<ArmazenamentoLocal> abrir() async =>
      ArmazenamentoLocal(await SharedPreferences.getInstance());

  String? texto(String chave) {
    final v = _prefs.get(chave);
    return v is String ? v : null;
  }

  Future<void> gravarTexto(String chave, String valor) async {
    if (!await _prefs.setString(chave, valor)) throw FalhaDeGravacao(chave);
  }

  Object? json(String chave) {
    final bruto = texto(chave);
    if (bruto == null) return null;
    try {
      return jsonDecode(bruto);
    } on FormatException {
      return null;
    }
  }

  Future<void> gravarJson(String chave, Object valor) => gravarTexto(chave, jsonEncode(valor));

  Future<void> apagarTudo() async {
    if (!await _prefs.clear()) throw const FalhaDeGravacao('*');
  }
}
