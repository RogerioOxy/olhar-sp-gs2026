import '../data/models/clima.dart';
import '../data/models/registro_local.dart';
import '../data/models/territorio.dart';
import 'equidade.dart';
import 'previsao.dart';

enum TipoAlerta { picoDemanda, quedaRegistro, chuvaForte, ocorrenciasCidadao, subRegistro }

enum Confianca { baixa, media, alta }

enum Prioridade { atencao, alta }

/// Reúne os valores que permitem conferir o motivo do alerta.
class Alerta {
  const Alerta({
    required this.id,
    required this.tipo,
    required this.distrito,
    required this.confianca,
    required this.prioridade,
    required this.valores,
  });

  final String id;
  final TipoAlerta tipo;
  final Distrito distrito;
  final Confianca confianca;
  final Prioridade prioridade;
  final Map<String, num> valores;

  /// Ignora limiares na assinatura e ordena valores para reconhecer a mesma evidência.
  String get assinatura {
    final chaves = valores.keys.where((k) => !k.startsWith('limiar')).toList()..sort();
    return [id, for (final k in chaves) '$k=${valores[k]}'].join('|');
  }
}

/// MAPE até 8% indica alta confiança e até 15%, média. Desvio menor que dois RMSE reduz um nível.
Confianca confiancaPorErro(double mape, double desvioEmRmse) {
  var nivel = mape <= 0.08
      ? Confianca.alta
      : mape <= 0.15
      ? Confianca.media
      : Confianca.baixa;
  if (desvioEmRmse < 2 && nivel != Confianca.baixa) {
    nivel = Confianca.values[nivel.index - 1];
  }
  return nivel;
}

/// Aplica os limiares e organiza sinais para avaliação humana.
class MotorAlertas {
  const MotorAlertas({
    required this.territorio,
    required this.previsoes,
    required this.equidade,
    required this.limiares,
    required this.ocorrencias,
    required this.clima,
    required this.agora,
  });

  final Territorio territorio;
  final List<PrevisaoDistrito> previsoes;
  final AnaliseEquidade equidade;
  final Limiares limiares;
  final List<Ocorrencia> ocorrencias;
  final Clima? clima;
  final DateTime agora;

  /// Ordena por prioridade, confiança e identificador para manter a lista previsível.
  List<Alerta> gerar() {
    final saida = <Alerta>[
      ..._demanda(),
      ..._chuva(),
      ..._cidadao(),
      ..._subRegistro(),
    ];
    saida.sort((a, b) {
      final p = b.prioridade.index.compareTo(a.prioridade.index);
      if (p != 0) return p;
      final c = b.confianca.index.compareTo(a.confianca.index);
      if (c != 0) return c;
      return a.id.compareTo(b.id);
    });
    return saida;
  }

  /// Compara o desvio percentual com os limites de pico e queda definidos pelo usuário.
  Iterable<Alerta> _demanda() sync* {
    for (final p in previsoes) {
      final rmse = p.backtest.rmse;
      final desvioRmse = rmse == 0 ? 0.0 : (p.ultimoReal - p.ultimoPrevisto).abs() / rmse;
      final valores = <String, num>{
        'real': p.ultimoReal,
        'previsto': p.ultimoPrevisto.round(),
        'desvioPct': (p.desvio * 100).round(),
        'mae': p.backtest.mae.round(),
        'mapePct': (p.backtest.mape * 100).round(),
        'mesesBacktest': p.backtest.pontos.length,
        'limiarPct': 0,
      };
      if (p.desvio * 100 >= limiares.picoPercentual) {
        yield Alerta(
          id: 'pico-${p.distrito.id}',
          tipo: TipoAlerta.picoDemanda,
          distrito: p.distrito,
          confianca: confiancaPorErro(p.backtest.mape, desvioRmse),
          prioridade: p.desvio >= 0.4 ? Prioridade.alta : Prioridade.atencao,
            valores: {...valores, 'limiarPct': limiares.picoPercentual},
        );
      } else if (-p.desvio * 100 >= limiares.quedaPercentual) {
        yield Alerta(
          id: 'queda-${p.distrito.id}',
          tipo: TipoAlerta.quedaRegistro,
          distrito: p.distrito,
          confianca: confiancaPorErro(p.backtest.mape, desvioRmse),
          prioridade: Prioridade.atencao,
            valores: {...valores, 'limiarPct': limiares.quedaPercentual},
        );
      }
    }
  }

  /// Exige três dias e o limiar de chuva; seleciona até três distritos com ao menos 20% de bocas de lobo.
  Iterable<Alerta> _chuva() sync* {
    final c = clima;
    if (c == null) return;
    final proximos = c.previsao(agora).take(3).toList();
    if (proximos.length < 3) return;
    final soma = proximos.fold<double>(0, (s, d) => s + d.chuvaMm);
    if (soma < limiares.chuvaMm3Dias) return;
    final prob = proximos.map((d) => d.probChuva ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
    final candidatos = territorio.distritos
        .where((d) => (d.categorias[Categoria.bocaDeLobo] ?? 0) >= 0.2)
        .toList()
      ..sort((a, b) => (b.categorias[Categoria.bocaDeLobo] ?? 0).compareTo(a.categorias[Categoria.bocaDeLobo] ?? 0));
    for (final d in candidatos.take(3)) {
      yield Alerta(
        id: 'chuva-${d.id}',
        tipo: TipoAlerta.chuvaForte,
        distrito: d,
        confianca: prob >= 70 ? Confianca.media : Confianca.baixa,
        prioridade: soma >= limiares.chuvaMm3Dias * 2 ? Prioridade.alta : Prioridade.atencao,
        valores: {
          'chuva3DiasMm': double.parse(soma.toStringAsFixed(1)),
          'limiarMm': limiares.chuvaMm3Dias,
          'probMaxPct': prob,
          'bocaDeLoboPct': ((d.categorias[Categoria.bocaDeLobo] ?? 0) * 100).round(),
          'inicioPrevisao': proximos.first.data.millisecondsSinceEpoch,
        },
      );
    }
  }

  /// Agrupa relatos dos últimos sete dias; cinco relatos elevam a confiança para média.
  Iterable<Alerta> _cidadao() sync* {
    final corte = agora.subtract(const Duration(days: 7));
    final recentes = ocorrencias.where((o) => o.criadaEm.isAfter(corte));
    final porDistrito = <String, List<Ocorrencia>>{};
    for (final o in recentes) {
      porDistrito.putIfAbsent(o.distritoId, () => []).add(o);
    }
    for (final entrada in porDistrito.entries) {
      final d = territorio.distrito(entrada.key);
      if (d == null) continue;
      final qtd = entrada.value.length;
      if (qtd < limiares.ocorrencias7Dias) continue;
      final porCat = <Categoria, int>{};
      for (final o in entrada.value) {
        porCat[o.categoria] = (porCat[o.categoria] ?? 0) + 1;
      }
      final principal = porCat.entries.reduce((a, b) => a.value >= b.value ? a : b);
      yield Alerta(
        id: 'cidadao-${d.id}',
        tipo: TipoAlerta.ocorrenciasCidadao,
        distrito: d,
        confianca: qtd >= 5 ? Confianca.media : Confianca.baixa,
        prioridade: Prioridade.atencao,
        valores: {
          'quantidade': qtd,
          'limiar': limiares.ocorrencias7Dias,
          'categoriaPrincipal': principal.key.index,
          'qtdCategoriaPrincipal': principal.value,
          'relatos': Object.hashAll([for (final o in entrada.value) o.id]..sort()),
        },
      );
    }
  }

  /// Sinaliza estimativas acima do limiar, sempre com confiança baixa por depender de amostra.
  Iterable<Alerta> _subRegistro() sync* {
    for (final s in equidade.subRegistroTodos()) {
      if (s.estimativa * 100 < limiares.subRegistroPercentual) continue;
      yield Alerta(
        id: 'subregistro-${s.distrito.id}',
        tipo: TipoAlerta.subRegistro,
        distrito: s.distrito,
        confianca: Confianca.baixa,
        prioridade: Prioridade.atencao,
        valores: {
          'estimativaPct': (s.estimativa * 100).round(),
          'margemPct': (s.margem * 100).round(),
          'achados': s.achadosNaAmostra,
          'registrados': s.registrados,
          'amostraPct': (equidade.territorio.amostraVistoria * 100).round(),
          'limiarPct': limiares.subRegistroPercentual,
        },
      );
    }
  }
}
