import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zeladoria_sp/data/models/clima.dart';
import 'package:zeladoria_sp/data/models/territorio.dart';

final String jsonTerritorio = File('assets/dados/territorio.json').readAsStringSync();
final String jsonClimaPacote = File('assets/dados/clima_snapshot.json').readAsStringSync();

Territorio territorioDeTeste() => Territorio.fromJson(jsonDecode(jsonTerritorio) as Map<String, dynamic>);

Map<String, dynamic> respostaOpenMeteo(DateTime hoje, {List<double>? chuvaProximos}) {
  final dias = <String>[];
  final chuva = <double>[];
  final tmax = <double>[];
  final tmin = <double>[];
  final prob = <int>[];
  for (var i = -30; i < 7; i++) {
    final d = DateTime(hoje.year, hoje.month, hoje.day + i);
    dias.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    final futuro = i >= 0;
    chuva.add(futuro && chuvaProximos != null && i < chuvaProximos.length ? chuvaProximos[i] : (i % 5 == 0 ? 8.0 : 0.5));
    tmax.add(27 + (i % 3));
    tmin.add(17 + (i % 2));
    prob.add(futuro ? 80 : 0);
  }
  return {
    'latitude': -23.5,
    'longitude': -46.6,
    'daily': {
      'time': dias,
      'precipitation_sum': chuva,
      'temperature_2m_max': tmax,
      'temperature_2m_min': tmin,
      'precipitation_probability_max': prob,
    },
  };
}

Clima climaDeTeste(DateTime hoje, {List<double>? chuvaProximos}) => Clima.fromOpenMeteo(
  respostaOpenMeteo(hoje, chuvaProximos: chuvaProximos),
  obtidoEm: hoje,
  origem: OrigemClima.rede,
);

http.Client clienteOk(DateTime hoje) =>
    MockClient((req) async => http.Response(jsonEncode(respostaOpenMeteo(hoje)), 200));

http.Client clienteOffline() => MockClient((req) async => throw http.ClientException('offline'));
