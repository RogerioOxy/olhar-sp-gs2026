import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  String? texto(String chave) => _prefs.getString(chave);

  Future<void> gravarTexto(String chave, String valor) => _prefs.setString(chave, valor);

  Future<void> remover(String chave) => _prefs.remove(chave);

  Object? json(String chave) {
    final bruto = _prefs.getString(chave);
    if (bruto == null) return null;
    try {
      return jsonDecode(bruto);
    } on FormatException {
      return null;
    }
  }

  Future<void> gravarJson(String chave, Object valor) =>
      _prefs.setString(chave, jsonEncode(valor));

  Future<void> apagarTudo() => _prefs.clear();
}
