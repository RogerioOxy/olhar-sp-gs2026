/// Mantém as medidas diárias e aceita probabilidade de chuva ausente.
class DiaClima {
  const DiaClima({
    required this.data,
    required this.chuvaMm,
    required this.tempMax,
    required this.tempMin,
    required this.probChuva,
  });

  final DateTime data;
  final double chuvaMm;
  final double tempMax;
  final double tempMin;
  final int? probChuva;
}

enum OrigemClima { rede, cache, pacote }

/// Preserva origem e data da coleta para contextualizar dados antigos.
class Clima {
  const Clima({
    required this.dias,
    required this.obtidoEm,
    required this.origem,
    required this.latitude,
    required this.longitude,
  });

  final List<DiaClima> dias;
  final DateTime obtidoEm;
  final OrigemClima origem;
  final double latitude;
  final double longitude;

  Clima comOrigem(OrigemClima nova) => Clima(
    dias: dias,
    obtidoEm: obtidoEm,
    origem: nova,
    latitude: latitude,
    longitude: longitude,
  );

  DateTime get _diaDaColeta => DateTime(obtidoEm.year, obtidoEm.month, obtidoEm.day);

  /// Limita o histórico é coleta para não transformar previsão antiga em observação.
  List<DiaClima> historico(DateTime hoje) {
    final h = DateTime(hoje.year, hoje.month, hoje.day);
    final limite = _diaDaColeta.isBefore(h) ? _diaDaColeta : h;
    return dias.where((d) => d.data.isBefore(limite)).toList();
  }

  List<DiaClima> previsao(DateTime hoje) {
    final h = DateTime(hoje.year, hoje.month, hoje.day);
    return dias.where((d) => !d.data.isBefore(h)).toList();
  }

  factory Clima.fromOpenMeteo(
    Map<String, dynamic> json, {
    required DateTime obtidoEm,
    required OrigemClima origem,
  }) {
    final daily = json['daily'] as Map<String, dynamic>;
    final datas = (daily['time'] as List).cast<String>();
    double valor(List lista, int i) => (lista[i] as num?)?.toDouble() ?? 0;
    final chuva = daily['precipitation_sum'] as List;
    final tmax = daily['temperature_2m_max'] as List;
    final tmin = daily['temperature_2m_min'] as List;
    final prob = daily['precipitation_probability_max'] as List?;
    final dias = <DiaClima>[];
    for (var i = 0; i < datas.length; i++) {
      dias.add(
        DiaClima(
          data: DateTime.parse(datas[i]),
          chuvaMm: valor(chuva, i),
          tempMax: valor(tmax, i),
          tempMin: valor(tmin, i),
          probChuva: prob == null ? null : (prob[i] as num?)?.toInt(),
        ),
      );
    }
    if (dias.isEmpty) throw const FormatException('daily');
    return Clima(
      dias: dias,
      obtidoEm: obtidoEm,
      origem: origem,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
