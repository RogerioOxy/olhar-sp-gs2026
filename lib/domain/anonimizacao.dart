import 'dart:math';

final _email = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+');
final _cpf = RegExp(r'\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b');
final _telefone = RegExp(r'(\+?\d{2}\s?)?(\(?\d{2}\)?\s?)?\d{4,5}[-\s]?\d{4}\b');
final _placa = RegExp(r'\b[A-Za-z]{3}-?\d[A-Za-z0-9]\d{2}\b');
final _numeroCasa = RegExp(r'(,|\bn[ºo°.]?)\s*\d{1,5}\b', caseSensitive: false);
final _espacos = RegExp(r'\s+');

String anonimizar(String texto, {required String marcador}) {
  var s = texto
      .replaceAll(_email, marcador)
      .replaceAll(_cpf, marcador)
      .replaceAll(_telefone, marcador)
      .replaceAll(_placa, marcador)
      .replaceAll(_numeroCasa, ' $marcador');
  s = s.replaceAll(_espacos, ' ').trim();
  return s;
}

bool contemDadoPessoal(String texto) =>
    _email.hasMatch(texto) ||
    _cpf.hasMatch(texto) ||
    _telefone.hasMatch(texto) ||
    _placa.hasMatch(texto) ||
    _numeroCasa.hasMatch(texto);

String gerarIdAnonimo([Random? aleatorio]) {
  final r = aleatorio ?? Random.secure();
  return List.generate(12, (_) => r.nextInt(16).toRadixString(16)).join();
}

DateTime arredondarParaHora(DateTime d) => DateTime(d.year, d.month, d.day, d.hour);
