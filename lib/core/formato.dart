String inteiro(num v) {
  final n = v.round();
  final negativo = n < 0;
  final digitos = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buf.write('.');
    buf.write(digitos[i]);
  }
  return '${negativo ? '-' : ''}$buf';
}

String decimal(num v, [int casas = 1]) {
  final s = v.toStringAsFixed(casas);
  final partes = s.split('.');
  final inteiroParte = inteiro(int.parse(partes[0]));
  final sinal = v < 0 && !inteiroParte.startsWith('-') && int.parse(partes[0]) == 0 ? '-' : '';
  return partes.length == 1 ? '$sinal$inteiroParte' : '$sinal$inteiroParte,${partes[1]}';
}

String percentual(num fracao, [int casas = 0]) => '${decimal(fracao * 100, casas)}%';

String comSinal(num v, String Function(num) f) => v > 0 ? '+${f(v)}' : f(v);

String dataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String dataHora(DateTime d) =>
    '${dataCurta(d)}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
