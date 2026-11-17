import '../data/models/clima.dart';
import 'previsao.dart';

List<double> somaRegistrados(List<PrevisaoDistrito> ps) {
  if (ps.isEmpty) return const [];
  final n = ps.first.distrito.registrados.length;
  return [
    for (var i = 0; i < n; i++) ps.fold<double>(0, (s, p) => s + p.distrito.registrados[i]),
  ];
}

/// Mantém o total ausente quando algum distrito ainda não tem previsão.
List<double?> somaPrevistos(List<PrevisaoDistrito> ps) {
  if (ps.isEmpty) return const [];
  final n = ps.first.previstosHistorico.length;
  return [
    for (var i = 0; i < n; i++)
      ps.any((p) => p.previstosHistorico[i] == null)
          ? null
          : ps.fold<double>(0, (s, p) => s + p.previstosHistorico[i]!),
  ];
}

List<T> ultimos<T>(List<T> l, int k) => l.length <= k ? l : l.sublist(l.length - k);

/// Agrupa janelas de chuva sem misturar histórico e previsão.
class ResumoClima {
  const ResumoClima({
    required this.chuvaProximos3,
    required this.chuvaUltimos7,
    required this.chuva7Anteriores,
    required this.probMaxProximos3,
    required this.diasPrevistos,
  });

  final double chuvaProximos3;
  final double chuvaUltimos7;
  final double chuva7Anteriores;
  final int probMaxProximos3;
  final int diasPrevistos;

  bool get previsaoCompleta => diasPrevistos >= 3;

  double? get variacao7Dias => chuva7Anteriores == 0 ? null : (chuvaUltimos7 - chuva7Anteriores) / chuva7Anteriores;

  static ResumoClima de(Clima c, DateTime hoje) {
    final hist = c.historico(hoje);
    final prev = c.previsao(hoje).take(3).toList();
    double soma(Iterable<DiaClima> ds) => ds.fold<double>(0, (s, d) => s + d.chuvaMm);
    final ult7 = ultimos(hist, 7);
    final ant7 = hist.length >= 14 ? hist.sublist(hist.length - 14, hist.length - 7) : const <DiaClima>[];
    return ResumoClima(
      chuvaProximos3: soma(prev),
      chuvaUltimos7: soma(ult7),
      chuva7Anteriores: soma(ant7),
      probMaxProximos3: prev.fold<int>(0, (m, d) => (d.probChuva ?? 0) > m ? d.probChuva! : m),
      diasPrevistos: prev.length,
    );
  }
}
