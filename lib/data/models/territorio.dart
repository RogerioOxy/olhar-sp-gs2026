enum FaixaRenda { baixa, media, alta }

enum Categoria { buraco, iluminacao, poda, entulho, bocaDeLobo }

Categoria? categoriaPorChave(String chave) => switch (chave) {
  'buraco' => Categoria.buraco,
  'iluminacao' => Categoria.iluminacao,
  'poda' => Categoria.poda,
  'entulho' => Categoria.entulho,
  'boca_de_lobo' => Categoria.bocaDeLobo,
  _ => null,
};

String chaveDaCategoria(Categoria c) => switch (c) {
  Categoria.buraco => 'buraco',
  Categoria.iluminacao => 'iluminacao',
  Categoria.poda => 'poda',
  Categoria.entulho => 'entulho',
  Categoria.bocaDeLobo => 'boca_de_lobo',
};

FaixaRenda faixaPorChave(String chave) => switch (chave) {
  'baixa' => FaixaRenda.baixa,
  'media' => FaixaRenda.media,
  'alta' => FaixaRenda.alta,
  _ => throw FormatException(chave),
};

/// Agrupa as séries e características usadas nas análises locais.
class Distrito {
  const Distrito({
    required this.id,
    required this.nome,
    required this.zona,
    required this.faixaRenda,
    required this.populacao,
    required this.categorias,
    required this.registrados,
    required this.atendidos,
    required this.achadosVistoria,
  });

  final String id;
  final String nome;
  final String zona;
  final FaixaRenda faixaRenda;
  final int populacao;
  final Map<Categoria, double> categorias;
  final List<int> registrados;
  final List<int> atendidos;
  final List<int> achadosVistoria;

  factory Distrito.fromJson(Map<String, dynamic> json) {
    List<int> inteiros(String chave) =>
        (json[chave] as List).map((v) => (v as num).toInt()).toList();
    final cats = <Categoria, double>{};
    (json['categorias'] as Map<String, dynamic>).forEach((k, v) {
      final c = categoriaPorChave(k);
      if (c != null) cats[c] = (v as num).toDouble();
    });
    return Distrito(
      id: json['id'] as String,
      nome: json['nome'] as String,
      zona: json['zona'] as String,
      faixaRenda: faixaPorChave(json['faixaRenda'] as String),
      populacao: (json['populacao'] as num).toInt(),
      categorias: cats,
      registrados: inteiros('registrados'),
      atendidos: inteiros('atendidos'),
      achadosVistoria: inteiros('achadosVistoria'),
    );
  }
}

/// Mantém meses e distritos na mesma base de análise.
class Territorio {
  const Territorio({
    required this.meses,
    required this.distritos,
    required this.amostraVistoria,
    required this.semente,
  });

  final List<DateTime> meses;
  final List<Distrito> distritos;
  final double amostraVistoria;
  final int semente;

  Distrito? distrito(String id) {
    for (final d in distritos) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<String> get zonas => (distritos.map((d) => d.zona).toSet().toList()..sort());

  factory Territorio.fromJson(Map<String, dynamic> json) {
    final meses = (json['meses'] as List).map((m) {
      final partes = (m as String).split('-');
      return DateTime(int.parse(partes[0]), int.parse(partes[1]));
    }).toList();
    final distritos = (json['distritos'] as List)
        .map((d) => Distrito.fromJson(d as Map<String, dynamic>))
        .toList();
    for (final d in distritos) {
      if (d.registrados.length != meses.length ||
          d.atendidos.length != meses.length ||
          d.achadosVistoria.length != meses.length) {
        throw FormatException(d.id);
      }
    }
    return Territorio(
      meses: meses,
      distritos: distritos,
      amostraVistoria: (json['amostraVistoria'] as num).toDouble(),
      semente: (json['semente'] as num).toInt(),
    );
  }
}
