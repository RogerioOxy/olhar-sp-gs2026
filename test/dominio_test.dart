import 'package:flutter_test/flutter_test.dart';
import 'package:zeladoria_sp/data/models/registro_local.dart';
import 'package:zeladoria_sp/data/models/territorio.dart';
import 'package:zeladoria_sp/domain/alertas.dart';
import 'package:zeladoria_sp/domain/equidade.dart';
import 'package:zeladoria_sp/domain/previsao.dart';

import 'apoio.dart';

void main() {
  final t = territorioDeTeste();
  final modelo = ModeloPrevisao(t);
  final previsoes = modelo.todos();
  final equidade = AnaliseEquidade(t);
  final hoje = DateTime(2026, 11, 16);

  List<Alerta> gerar({
    Limiares limiares = const Limiares(),
    List<Ocorrencia> ocorrencias = const [],
    List<double>? chuva,
  }) => MotorAlertas(
    territorio: t,
    previsoes: previsoes,
    equidade: equidade,
    limiares: limiares,
    ocorrencias: ocorrencias,
    clima: chuva == null ? null : climaDeTeste(hoje, chuvaProximos: chuva),
    agora: hoje,
  ).gerar();

  group('dados sintéticos', () {
    test('16 distritos e 24 meses, todos com séries completas', () {
      expect(t.distritos, hasLength(16));
      expect(t.meses, hasLength(24));
      expect(t.meses.first, DateTime(2024, 11));
      expect(t.meses.last, DateTime(2026, 10));
      for (final d in t.distritos) {
        expect(d.registrados, hasLength(24));
        expect(d.atendidos.every((a) => a >= 0), isTrue);
      }
    });

    test('cada faixa de renda tem distritos', () {
      for (final f in FaixaRenda.values) {
        expect(t.distritos.where((d) => d.faixaRenda == f), isNotEmpty);
      }
    });
  });

  group('previsão e backtest', () {
    test('a previsão de um mês não usa o próprio mês nem os seguintes', () {
      final d = t.distritos.first;
      final antes = modelo.prever(d, 20);
      final alterado = Distrito(
        id: d.id,
        nome: d.nome,
        zona: d.zona,
        faixaRenda: d.faixaRenda,
        populacao: d.populacao,
        categorias: d.categorias,
        registrados: [...d.registrados.sublist(0, 20), for (var i = 20; i < 24; i++) 99999],
        atendidos: d.atendidos,
        achadosVistoria: d.achadosVistoria,
      );
      expect(modelo.prever(alterado, 20), closeTo(antes!, 1e-9));
    });

    test('sem 12 meses de histórico não há previsão', () {
      expect(modelo.prever(t.distritos.first, 11), isNull);
      expect(modelo.prever(t.distritos.first, 12), isNotNull);
    });

    test('backtest usa 6 meses anteriores ao mês avaliado', () {
      final p = previsoes.first;
      expect(p.backtest.pontos.map((x) => x.indice), [17, 18, 19, 20, 21, 22]);
      expect(p.backtest.mae, greaterThan(0));
      expect(p.backtest.rmse, greaterThanOrEqualTo(p.backtest.mae));
    });

    test('MAE e MAPE do resumo batem com os números do README', () {
      final r = ResumoBacktest.de(previsoes);
      expect(r.meses, 6);
      expect(r.maeMedio, closeTo(28.9, 0.05));
      expect(r.mapeGeral, closeTo(0.067, 0.0005));
    });

    test('inclinação relativa reconhece alta, queda e estabilidade', () {
      expect(inclinacaoRelativa([10, 11, 12, 13]), greaterThan(0));
      expect(inclinacaoRelativa([13, 12, 11, 10]), lessThan(0));
      expect(inclinacaoRelativa([5, 5, 5]), 0);
      expect(inclinacaoRelativa([5]), 0);
    });
  });

  group('equidade e indicador social', () {
    test('alta renda tem mais atendimento por 10 mil habitantes que baixa renda', () {
      final s = equidade.indicadorSocial();
      expect(s.atualAlta, greaterThan(s.atualBaixa));
      expect(s.diferencaAtual, closeTo(s.atualAlta - s.atualBaixa, 1e-9));
      expect(s.serieDiferenca, hasLength(24));
    });

    test('sub-registro estimado fica entre 0 e 1 e é maior na baixa renda', () {
      final baixa = equidade.serie(FaixaRenda.baixa).subRegistro.last;
      final alta = equidade.serie(FaixaRenda.alta).subRegistro.last;
      expect(baixa, inInclusiveRange(0, 1));
      expect(baixa, greaterThan(alta));
      for (final s in equidade.subRegistroTodos()) {
        expect(s.estimativa, inInclusiveRange(0, 1));
        expect(s.margem, greaterThan(0));
      }
    });
  });

  group('motor de alertas', () {
    test('limiares padrão geram os picos e a queda esperados', () {
      final ids = gerar().map((a) => a.id).toSet();
      expect(ids, containsAll(['pico-grajau', 'pico-penha', 'queda-cidade-tiradentes']));
      expect(ids.where((i) => i.startsWith('chuva')), isEmpty);
    });

    test('baixar o limiar de pico gera alertas novos', () {
      final padrao = gerar().where((a) => a.tipo == TipoAlerta.picoDemanda).length;
      final sensivel = gerar(limiares: const Limiares(picoPercentual: 8)).where((a) => a.tipo == TipoAlerta.picoDemanda).length;
      expect(sensivel, greaterThan(padrao));
    });

    test('sub-registro sempre sai com confiança baixa', () {
      final subs = gerar().where((a) => a.tipo == TipoAlerta.subRegistro);
      expect(subs, isNotEmpty);
      expect(subs.every((a) => a.confianca == Confianca.baixa), isTrue);
    });

    test('ocorrências do cidadão disparam alerta só ao atingir o limiar', () {
      Ocorrencia o(int h) => Ocorrencia(
        id: 'x$h',
        distritoId: 'moema',
        categoria: Categoria.buraco,
        descricao: 'buraco grande na rua',
        referencia: '',
        criadaEm: hoje.subtract(Duration(hours: h)),
      );
      expect(gerar(ocorrencias: [o(1), o(2)]).any((a) => a.id == 'cidadao-moema'), isFalse);
      final com3 = gerar(ocorrencias: [o(1), o(2), o(3)]);
      final alerta = com3.firstWhere((a) => a.id == 'cidadao-moema');
      expect(alerta.valores['quantidade'], 3);
      final antigas = [o(1), o(2), o(24 * 8)];
      expect(gerar(ocorrencias: antigas).any((a) => a.id == 'cidadao-moema'), isFalse);
    });

    test('chuva prevista acima do limiar gera alerta preventivo', () {
      expect(gerar(chuva: [5, 5, 5]).any((a) => a.tipo == TipoAlerta.chuvaForte), isFalse);
      final alertas = gerar(chuva: [30, 20, 10]).where((a) => a.tipo == TipoAlerta.chuvaForte).toList();
      expect(alertas, isNotEmpty);
      expect(alertas.length, lessThanOrEqualTo(3));
      expect(alertas.first.valores['chuva3DiasMm'], 60);
    });

    test('a confiança cai quando o erro histórico é grande ou o desvio é pequeno', () {
      expect(confiancaPorErro(0.05, 5), Confianca.alta);
      expect(confiancaPorErro(0.05, 1), Confianca.media);
      expect(confiancaPorErro(0.12, 5), Confianca.media);
      expect(confiancaPorErro(0.30, 5), Confianca.baixa);
    });
  });

  group('limiares', () {
    test('valores fora da faixa voltam ao padrão ao ler', () {
      final l = Limiares.fromJson({'pico': 500, 'queda': 10, 'chuva': -1, 'ocorrencias': 2, 'subRegistro': 70});
      expect(l.picoPercentual, const Limiares().picoPercentual);
      expect(l.quedaPercentual, 10);
      expect(l.chuvaMm3Dias, const Limiares().chuvaMm3Dias);
      expect(l.ocorrencias7Dias, 2);
      expect(Limiares.fromJson(l.toJson()), l);
    });
  });
}
