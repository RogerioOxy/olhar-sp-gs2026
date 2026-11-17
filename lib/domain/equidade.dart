import 'dart:math' as math;

import '../data/models/territorio.dart';
import 'previsao.dart';

class SerieFaixa {
  const SerieFaixa({
    required this.faixa,
    required this.populacao,
    required this.atendidosPor10mil,
    required this.registradosPor10mil,
    required this.subRegistro,
  });

  final FaixaRenda faixa;
  final int populacao;
  final List<double> atendidosPor10mil;
  final List<double> registradosPor10mil;
  final List<double> subRegistro;
}

class SubRegistroDistrito {
  const SubRegistroDistrito({
    required this.distrito,
    required this.estimativa,
    required this.achadosNaAmostra,
    required this.registrados,
    required this.problemasEstimados,
    required this.margem,
  });

  final Distrito distrito;
  final double estimativa;
  final int achadosNaAmostra;
  final int registrados;
  final double problemasEstimados;
  final double margem;
}

class IndicadorSocial {
  const IndicadorSocial({
    required this.serieDiferenca,
    required this.atualBaixa,
    required this.atualAlta,
    required this.tendenciaPorMes,
  });

  final List<double> serieDiferenca;
  final double atualBaixa;
  final double atualAlta;
  final double tendenciaPorMes;

  double get diferencaAtual => atualAlta - atualBaixa;

  Tendencia get tendencia {
    if (tendenciaPorMes > 0.01) return Tendencia.alta;
    if (tendenciaPorMes < -0.01) return Tendencia.queda;
    return Tendencia.estavel;
  }
}

double limitar01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

class AnaliseEquidade {
  AnaliseEquidade(this.territorio, {this.janela = 3});

  final Territorio territorio;
  final int janela;

  int get n => territorio.meses.length;

  SerieFaixa serie(FaixaRenda faixa) {
    final ds = territorio.distritos.where((d) => d.faixaRenda == faixa).toList();
    final pop = ds.fold<int>(0, (s, d) => s + d.populacao);
    final atend = <double>[];
    final reg = <double>[];
    final sub = <double>[];
    for (var i = 0; i < n; i++) {
      final a = ds.fold<int>(0, (s, d) => s + d.atendidos[i]);
      final r = ds.fold<int>(0, (s, d) => s + d.registrados[i]);
      final v = ds.fold<int>(0, (s, d) => s + d.achadosVistoria[i]);
      atend.add(pop == 0 ? 0 : a / pop * 10000);
      reg.add(pop == 0 ? 0 : r / pop * 10000);
      final estimados = v / territorio.amostraVistoria;
      sub.add(estimados == 0 ? 0 : limitar01(1 - r / estimados));
    }
    return SerieFaixa(
      faixa: faixa,
      populacao: pop,
      atendidosPor10mil: atend,
      registradosPor10mil: reg,
      subRegistro: sub,
    );
  }

  Map<FaixaRenda, SerieFaixa> series() => {for (final f in FaixaRenda.values) f: serie(f)};

  IndicadorSocial indicadorSocial() {
    final baixa = serie(FaixaRenda.baixa);
    final alta = serie(FaixaRenda.alta);
    final dif = <double>[
      for (var i = 0; i < n; i++) alta.atendidosPor10mil[i] - baixa.atendidosPor10mil[i],
    ];
    double mediaFinal(List<double> s) {
      final ini = n - janela < 0 ? 0 : n - janela;
      final parte = s.sublist(ini);
      return parte.reduce((a, b) => a + b) / parte.length;
    }

    final ini = n - 12 < 0 ? 0 : n - 12;
    final ultimos = dif.sublist(ini);
    final media = ultimos.reduce((a, b) => a + b) / ultimos.length;
    return IndicadorSocial(
      serieDiferenca: dif,
      atualBaixa: mediaFinal(baixa.atendidosPor10mil),
      atualAlta: mediaFinal(alta.atendidosPor10mil),
      tendenciaPorMes: media == 0 ? 0 : inclinacaoRelativa(ultimos),
    );
  }

  SubRegistroDistrito subRegistro(Distrito d) {
    final ini = n - janela < 0 ? 0 : n - janela;
    var achados = 0;
    var reg = 0;
    for (var i = ini; i < n; i++) {
      achados += d.achadosVistoria[i];
      reg += d.registrados[i];
    }
    final estimados = achados / territorio.amostraVistoria;
    final p = estimados == 0 ? 0.0 : limitar01(reg / estimados);
    final margem = achados == 0 ? 1.0 : 1.96 * math.sqrt(p * (1 - p) / achados) + 1 / achados;
    return SubRegistroDistrito(
      distrito: d,
      estimativa: estimados == 0 ? 0 : limitar01(1 - p),
      achadosNaAmostra: achados,
      registrados: reg,
      problemasEstimados: estimados,
      margem: margem,
    );
  }

  List<SubRegistroDistrito> subRegistroTodos() {
    final l = territorio.distritos.map(subRegistro).toList();
    l.sort((a, b) => b.estimativa.compareTo(a.estimativa));
    return l;
  }
}
