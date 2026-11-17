import 'dart:math';

final _email = RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+');
final _cpf = RegExp(r'\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b');
final _telefone = RegExp(r'(\+?\d{2}\s?)?(\(?\d{2}\)?\s?)?\d{4,5}[-\s]?\d{4}\b');
final _placa = RegExp(r'\b[A-Za-z]{3}-?\d[A-Za-z0-9]\d{2}\b');
final _numeroCasa = RegExp(r'(,|\bn[ºo°.]?)\s*\d{1,5}\b', caseSensitive: false);
final _logradouroNumero = RegExp(
  r'\b((?:rua|r\.|avenida|av\.?|travessa|tv\.|alameda|al\.|estrada|praça|largo|viela)\s+(?:[\wÀ-ÿ.]+\s+){0,4}?)\d{1,5}\b',
  caseSensitive: false,
);
final _nomeProprio = RegExp(
  r'\b([Mm]eu nome é|[Mm]e chamo|[Ss]ou o|[Ss]ou a|[Ss]ou)\s+[A-ZÀ-Ý][\wÀ-ÿ]+(?:\s+(?:da|de|do|dos|das|e)?\s*[A-ZÀ-Ý][\wÀ-ÿ]+)*',
);
final _espacos = RegExp(r'\s+');

/// Substitui padrões comuns de dados pessoais. As expressões não garantem remoção de todo dado sensível.
String anonimizar(String texto, {required String marcador}) {
  var s = texto
      .replaceAll(_email, marcador)
      .replaceAll(_cpf, marcador)
      .replaceAll(_telefone, marcador)
      .replaceAll(_placa, marcador)
      .replaceAll(_numeroCasa, ' $marcador')
      .replaceAllMapped(_logradouroNumero, (m) => '${m.group(1)}$marcador')
      .replaceAllMapped(_nomeProprio, (m) => '${m.group(1)} $marcador');
  s = s.replaceAll(_espacos, ' ').trim();
  return s;
}

/// Usa os mesmos padrões da remoção para avisar durante o preenchimento.
bool contemDadoPessoal(String texto) =>
    _email.hasMatch(texto) ||
    _cpf.hasMatch(texto) ||
    _telefone.hasMatch(texto) ||
    _placa.hasMatch(texto) ||
    _numeroCasa.hasMatch(texto) ||
    _logradouroNumero.hasMatch(texto) ||
    _nomeProprio.hasMatch(texto);

/// Gera um identificador aleatório sem usar nome ou documento do cidadão.
String gerarIdAnonimo([Random? aleatorio]) {
  final r = aleatorio ?? Random.secure();
  return List.generate(12, (_) => r.nextInt(16).toRadixString(16)).join();
}

/// Remove minutos e segundos para reduzir a precisão temporal do relato.
DateTime arredondarParaHora(DateTime d) => DateTime(d.year, d.month, d.day, d.hour);
