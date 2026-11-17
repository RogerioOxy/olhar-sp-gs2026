import 'territorio.dart';

class Ocorrencia {
  const Ocorrencia({
    required this.id,
    required this.distritoId,
    required this.categoria,
    required this.descricao,
    required this.referencia,
    required this.criadaEm,
  });

  final String id;
  final String distritoId;
  final Categoria categoria;
  final String descricao;
  final String referencia;
  final DateTime criadaEm;

  Map<String, dynamic> toJson() => {
    'id': id,
    'distritoId': distritoId,
    'categoria': chaveDaCategoria(categoria),
    'descricao': descricao,
    'referencia': referencia,
    'criadaEm': criadaEm.toIso8601String(),
  };

  static Ocorrencia? fromJson(Map<String, dynamic> json) {
    String texto(String k) => json[k] is String ? json[k] as String : '';
    final c = categoriaPorChave(texto('categoria'));
    final data = DateTime.tryParse(texto('criadaEm'));
    if (c == null || data == null || texto('distritoId').isEmpty) return null;
    return Ocorrencia(
      id: texto('id'),
      distritoId: texto('distritoId'),
      categoria: c,
      descricao: texto('descricao'),
      referencia: texto('referencia'),
      criadaEm: data,
    );
  }
}

class Limiares {
  const Limiares({
    this.picoPercentual = 20,
    this.quedaPercentual = 25,
    this.chuvaMm3Dias = 40,
    this.ocorrencias7Dias = 3,
    this.subRegistroPercentual = 60,
  });

  final int picoPercentual;
  final int quedaPercentual;
  final int chuvaMm3Dias;
  final int ocorrencias7Dias;
  final int subRegistroPercentual;

  static const faixaPico = (5, 100);
  static const faixaQueda = (5, 90);
  static const faixaChuva = (5, 300);
  static const faixaOcorrencias = (1, 20);
  static const faixaSubRegistro = (20, 95);

  Map<String, dynamic> toJson() => {
    'pico': picoPercentual,
    'queda': quedaPercentual,
    'chuva': chuvaMm3Dias,
    'ocorrencias': ocorrencias7Dias,
    'subRegistro': subRegistroPercentual,
  };

  factory Limiares.fromJson(Map<String, dynamic> json) {
    const p = Limiares();
    int ler(String k, int padrao, (int, int) faixa) {
      final bruto = json[k];
      final v = bruto is num ? bruto.toInt() : padrao;
      return v < faixa.$1 || v > faixa.$2 ? padrao : v;
    }

    return Limiares(
      picoPercentual: ler('pico', p.picoPercentual, faixaPico),
      quedaPercentual: ler('queda', p.quedaPercentual, faixaQueda),
      chuvaMm3Dias: ler('chuva', p.chuvaMm3Dias, faixaChuva),
      ocorrencias7Dias: ler('ocorrencias', p.ocorrencias7Dias, faixaOcorrencias),
      subRegistroPercentual: ler('subRegistro', p.subRegistroPercentual, faixaSubRegistro),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Limiares &&
      other.picoPercentual == picoPercentual &&
      other.quedaPercentual == quedaPercentual &&
      other.chuvaMm3Dias == chuvaMm3Dias &&
      other.ocorrencias7Dias == ocorrencias7Dias &&
      other.subRegistroPercentual == subRegistroPercentual;

  @override
  int get hashCode => Object.hash(
    picoPercentual,
    quedaPercentual,
    chuvaMm3Dias,
    ocorrencias7Dias,
    subRegistroPercentual,
  );
}

enum DecisaoHumana { vistoriar, monitorar, descartar }

class RegistroDecisao {
  const RegistroDecisao(this.decisao, this.em, this.assinatura);

  final DecisaoHumana decisao;
  final DateTime em;
  final String assinatura;

  Map<String, dynamic> toJson() => {'decisao': decisao.name, 'em': em.toIso8601String(), 'assinatura': assinatura};

  static RegistroDecisao? fromJson(Map<String, dynamic> json) {
    final nome = json['decisao'] is String ? json['decisao'] as String : null;
    final em = DateTime.tryParse(json['em'] is String ? json['em'] as String : '');
    final assinatura = json['assinatura'] is String ? json['assinatura'] as String : '';
    final d = DecisaoHumana.values.where((v) => v.name == nome);
    if (d.isEmpty || em == null) return null;
    return RegistroDecisao(d.first, em, assinatura);
  }
}

enum Perfil { cidadao, gestor }

enum TemaEscolhido { sistema, claro, escuro, altoContraste }
