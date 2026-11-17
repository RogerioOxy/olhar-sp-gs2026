import 'dart:math' as math;

import '../data/models/territorio.dart';

enum Tendencia { alta, estavel, queda }

class IndiceSazonal {
  const IndiceSazonal(this.porMes);

  final Map<int, double> porMes;

  double de(DateTime mes) => porMes[mes.month] ?? 1.0;

  static IndiceSazonal calcular(Territorio t, {required int ate}) {
    final totais = List<double>.filled(ate, 0);
    for (final d in t.distritos) {
      for (var i = 0; i < ate; i++) {
        totais[i] += d.registrados[i];
      }
    }
    if (ate == 0) return const IndiceSazonal({});
    final mediaGeral = totais.reduce((a, b) => a + b) / ate;
    final soma = <int, double>{};
    final conta = <int, int>{};
    for (var i = 0; i < ate; i++) {
      final m = t.meses[i].month;
      soma[m] = (soma[m] ?? 0) + totais[i];
      conta[m] = (conta[m] ?? 0) + 1;
    }
    final indice = <int, double>{};
    soma.forEach((m, s) => indice[m] = mediaGeral == 0 ? 1 : (s / conta[m]!) / mediaGeral);
    return IndiceSazonal(indice);
  }
}

class PontoBacktest {
  const PontoBacktest(this.indice, this.previsto, this.real);

  final int indice;
  final double previsto;
  final int real;

  double get erro => real - previsto;
}

class ResultadoBacktest {
  const ResultadoBacktest(this.pontos);

  final List<PontoBacktest> pontos;

  double get mae => pontos.isEmpty
      ? 0
      : pontos.map((p) => p.erro.abs()).reduce((a, b) => a + b) / pontos.length;

  double get rmse => pontos.isEmpty
      ? 0
      : math.sqrt(pontos.map((p) => p.erro * p.erro).reduce((a, b) => a + b) / pontos.length);

  double get mape {
    final validos = pontos.where((p) => p.real > 0).toList();
    if (validos.isEmpty) return 0;
    return validos.fold<double>(0, (s, p) => s + p.erro.abs() / p.real) / validos.length;
  }
}

class PrevisaoDistrito {
  const PrevisaoDistrito({
    required this.distrito,
    required this.previstosHistorico,
    required this.previstoProximo,
    required this.faixaProximo,
    required this.backtest,
    required this.ultimoReal,
    required this.ultimoPrevisto,
    required this.tendenciaPorMes,
  });

  final Distrito distrito;
  final List<double?> previstosHistorico;
  final double previstoProximo;
  final double faixaProximo;
  final ResultadoBacktest backtest;
  final int ultimoReal;
  final double ultimoPrevisto;
  final double tendenciaPorMes;

  double get desvio => ultimoPrevisto == 0 ? 0 : (ultimoReal - ultimoPrevisto) / ultimoPrevisto;

  Tendencia get tendencia {
    if (tendenciaPorMes > 0.01) return Tendencia.alta;
    if (tendenciaPorMes < -0.01) return Tendencia.queda;
    return Tendencia.estavel;
  }
}

class ModeloPrevisao {
  ModeloPrevisao(this.territorio, {this.janelaNivel = 3, this.mesesBacktest = 6});

  final Territorio territorio;
  final int janelaNivel;
  final int mesesBacktest;
  final Map<int, IndiceSazonal> _indices = {};

  int get n => territorio.meses.length;

  IndiceSazonal _indice(int ate) =>
      _indices.putIfAbsent(ate, () => IndiceSazonal.calcular(territorio, ate: ate));

  DateTime mesSeguinte(DateTime m) => DateTime(m.year, m.month + 1);

  DateTime mesDoIndice(int i) =>
      i < n ? territorio.meses[i] : mesSeguinte(mesDoIndice(i - 1));

  double? prever(Distrito d, int alvo) {
    if (alvo < 12 || alvo < janelaNivel) return null;
    final idx = _indice(alvo);
    var nivel = 0.0;
    for (var j = 1; j <= janelaNivel; j++) {
      final i = alvo - j;
      nivel += d.registrados[i] / idx.de(territorio.meses[i]);
    }
    nivel /= janelaNivel;
    return nivel * idx.de(mesDoIndice(alvo));
  }

  ResultadoBacktest backtest(Distrito d, {required int ultimoExcluido}) {
    final pontos = <PontoBacktest>[];
    for (var i = ultimoExcluido - mesesBacktest; i < ultimoExcluido; i++) {
      final p = prever(d, i);
      if (p != null) pontos.add(PontoBacktest(i, p, d.registrados[i]));
    }
    return ResultadoBacktest(pontos);
  }

  double tendencia(Distrito d, {int janela = 12}) {
    final inicio = math.max(0, n - janela);
    final idx = _indice(n);
    final ys = <double>[];
    for (var i = inicio; i < n; i++) {
      ys.add(d.registrados[i] / idx.de(territorio.meses[i]));
    }
    return inclinacaoRelativa(ys);
  }

  PrevisaoDistrito paraDistrito(Distrito d) {
    final ultimo = n - 1;
    final bt = backtest(d, ultimoExcluido: ultimo);
    final previstos = List<double?>.generate(n, (i) => prever(d, i));
    final proximo = prever(d, n) ?? 0;
    return PrevisaoDistrito(
      distrito: d,
      previstosHistorico: previstos,
      previstoProximo: proximo,
      faixaProximo: 1.28 * bt.rmse,
      backtest: bt,
      ultimoReal: d.registrados[ultimo],
      ultimoPrevisto: previstos[ultimo] ?? 0,
      tendenciaPorMes: tendencia(d),
    );
  }

  List<PrevisaoDistrito> todos() => territorio.distritos.map(paraDistrito).toList();
}

double inclinacaoRelativa(List<double> ys) {
  if (ys.length < 2) return 0;
  final nn = ys.length;
  final mx = (nn - 1) / 2;
  final my = ys.reduce((a, b) => a + b) / nn;
  var num = 0.0;
  var den = 0.0;
  for (var i = 0; i < nn; i++) {
    num += (i - mx) * (ys[i] - my);
    den += (i - mx) * (i - mx);
  }
  if (den == 0 || my == 0) return 0;
  return (num / den) / my;
}

class ResumoBacktest {
  const ResumoBacktest({required this.maeMedio, required this.mapeGeral, required this.meses});

  final double maeMedio;
  final double mapeGeral;
  final int meses;

  static ResumoBacktest de(List<PrevisaoDistrito> previsoes) {
    if (previsoes.isEmpty) return const ResumoBacktest(maeMedio: 0, mapeGeral: 0, meses: 0);
    final mae = previsoes.map((p) => p.backtest.mae).reduce((a, b) => a + b) / previsoes.length;
    final todos = [for (final p in previsoes) ...p.backtest.pontos];
    return ResumoBacktest(
      maeMedio: mae,
      mapeGeral: ResultadoBacktest(todos).mape,
      meses: previsoes.first.backtest.pontos.length,
    );
  }
}
