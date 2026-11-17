import 'package:flutter/foundation.dart';

import '../data/models/clima.dart';
import '../data/models/registro_local.dart';
import '../data/models/territorio.dart';
import '../data/services/armazenamento_local.dart';
import '../data/services/clima_servico.dart';
import '../data/services/territorio_repositorio.dart';
import '../domain/alertas.dart';
import '../domain/anonimizacao.dart';
import '../domain/equidade.dart';
import '../domain/previsao.dart';

enum EstadoCarga { carregando, pronto, erro }

mixin _NotificaSeguro on ChangeNotifier {
  bool _descartado = false;

  void avisar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}

class PreferenciasController extends ChangeNotifier with _NotificaSeguro {
  PreferenciasController(this._armazenamento) {
    _ler();
  }

  final ArmazenamentoLocal _armazenamento;

  DateTime? consentimentoEm;
  Perfil perfil = Perfil.cidadao;
  String? meuDistritoId;
  TemaEscolhido tema = TemaEscolhido.sistema;
  Limiares limiares = const Limiares();
  Map<String, RegistroDecisao> decisoes = {};

  bool get consentiu => consentimentoEm != null;

  void _ler() {
    consentimentoEm = DateTime.tryParse(_armazenamento.texto(ArmazenamentoLocal.chaveConsentimento) ?? '');
    final p = _armazenamento.texto(ArmazenamentoLocal.chavePerfil);
    perfil = Perfil.values.firstWhere((v) => v.name == p, orElse: () => Perfil.cidadao);
    meuDistritoId = _armazenamento.texto(ArmazenamentoLocal.chaveDistrito);
    final t = _armazenamento.texto(ArmazenamentoLocal.chaveTema);
    tema = TemaEscolhido.values.firstWhere((v) => v.name == t, orElse: () => TemaEscolhido.sistema);
    final l = _armazenamento.json(ArmazenamentoLocal.chaveLimiares);
    limiares = l is Map<String, dynamic> ? Limiares.fromJson(l) : const Limiares();
    final d = _armazenamento.json(ArmazenamentoLocal.chaveDecisoes);
    decisoes = {};
    if (d is Map<String, dynamic>) {
      d.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          final r = RegistroDecisao.fromJson(v);
          if (r != null) decisoes[k] = r;
        }
      });
    }
  }

  Future<void> darConsentimento({
    required Perfil perfil,
    required String? distritoId,
    DateTime? agora,
  }) async {
    consentimentoEm = agora ?? DateTime.now();
    this.perfil = perfil;
    meuDistritoId = distritoId;
    await _armazenamento.gravarTexto(ArmazenamentoLocal.chaveConsentimento, consentimentoEm!.toIso8601String());
    await _armazenamento.gravarTexto(ArmazenamentoLocal.chavePerfil, perfil.name);
    if (distritoId != null) {
      await _armazenamento.gravarTexto(ArmazenamentoLocal.chaveDistrito, distritoId);
    }
    avisar();
  }

  Future<void> definirPerfil(Perfil novo) async {
    perfil = novo;
    await _armazenamento.gravarTexto(ArmazenamentoLocal.chavePerfil, novo.name);
    avisar();
  }

  Future<void> definirDistrito(String id) async {
    meuDistritoId = id;
    await _armazenamento.gravarTexto(ArmazenamentoLocal.chaveDistrito, id);
    avisar();
  }

  Future<void> definirTema(TemaEscolhido novo) async {
    tema = novo;
    await _armazenamento.gravarTexto(ArmazenamentoLocal.chaveTema, novo.name);
    avisar();
  }

  Future<void> salvarLimiares(Limiares novos) async {
    limiares = novos;
    await _armazenamento.gravarJson(ArmazenamentoLocal.chaveLimiares, novos.toJson());
    avisar();
  }

  Future<void> registrarDecisao(String alertaId, DecisaoHumana decisao, {DateTime? agora}) async {
    decisoes = {...decisoes, alertaId: RegistroDecisao(decisao, agora ?? DateTime.now())};
    await _armazenamento.gravarJson(
      ArmazenamentoLocal.chaveDecisoes,
      decisoes.map((k, v) => MapEntry(k, v.toJson())),
    );
    avisar();
  }

  Future<void> apagarTudo() async {
    await _armazenamento.apagarTudo();
    _ler();
    avisar();
  }
}

class TerritorioController extends ChangeNotifier with _NotificaSeguro {
  TerritorioController(this._repositorio);

  final TerritorioRepositorio _repositorio;

  EstadoCarga estado = EstadoCarga.carregando;
  Territorio? territorio;
  List<PrevisaoDistrito> previsoes = const [];
  AnaliseEquidade? equidade;
  ResumoBacktest? resumo;
  IndicadorSocial? social;

  Future<void> carregar() async {
    estado = EstadoCarga.carregando;
    avisar();
    try {
      final t = await _repositorio.carregar();
      final modelo = ModeloPrevisao(t);
      territorio = t;
      previsoes = modelo.todos();
      equidade = AnaliseEquidade(t);
      resumo = ResumoBacktest.de(previsoes);
      social = equidade!.indicadorSocial();
      estado = EstadoCarga.pronto;
    } on Object {
      estado = EstadoCarga.erro;
    }
    avisar();
  }

  PrevisaoDistrito? previsaoDe(String id) {
    for (final p in previsoes) {
      if (p.distrito.id == id) return p;
    }
    return null;
  }
}

class ClimaController extends ChangeNotifier with _NotificaSeguro {
  ClimaController(this._servico);

  final ClimaServico _servico;

  EstadoCarga estado = EstadoCarga.carregando;
  Clima? clima;
  FalhaClima? ultimaFalha;
  bool atualizando = false;

  Future<void> iniciar() async {
    clima = _servico.lerCache() ?? await _servico.lerPacote();
    estado = clima == null ? EstadoCarga.carregando : EstadoCarga.pronto;
    avisar();
    await atualizar();
  }

  Future<void> atualizar() async {
    if (atualizando) return;
    atualizando = true;
    avisar();
    try {
      clima = await _servico.buscarNaRede();
      ultimaFalha = null;
      estado = EstadoCarga.pronto;
    } on ClimaExcecao catch (e) {
      ultimaFalha = e.falha;
      if (clima == null) {
        estado = EstadoCarga.erro;
      } else if (clima!.origem == OrigemClima.rede) {
        clima = clima!.comOrigem(OrigemClima.cache);
      }
    } finally {
      atualizando = false;
      avisar();
    }
  }
}

class OcorrenciasController extends ChangeNotifier with _NotificaSeguro {
  OcorrenciasController(this._armazenamento) {
    _ler();
  }

  final ArmazenamentoLocal _armazenamento;
  List<Ocorrencia> ocorrencias = [];

  void _ler() {
    final bruto = _armazenamento.json(ArmazenamentoLocal.chaveOcorrencias);
    ocorrencias = bruto is List
        ? bruto.whereType<Map<String, dynamic>>().map(Ocorrencia.fromJson).whereType<Ocorrencia>().toList()
        : [];
    ocorrencias.sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
  }

  Future<Ocorrencia> registrar({
    required String distritoId,
    required Categoria categoria,
    required String descricao,
    required String referencia,
    required String marcadorRemovido,
    DateTime? agora,
  }) async {
    final o = Ocorrencia(
      id: gerarIdAnonimo(),
      distritoId: distritoId,
      categoria: categoria,
      descricao: anonimizar(descricao, marcador: marcadorRemovido),
      referencia: anonimizar(referencia, marcador: marcadorRemovido),
      criadaEm: arredondarParaHora(agora ?? DateTime.now()),
    );
    ocorrencias = [o, ...ocorrencias];
    await _salvar();
    avisar();
    return o;
  }

  Future<void> remover(String id) async {
    ocorrencias = ocorrencias.where((o) => o.id != id).toList();
    await _salvar();
    avisar();
  }

  void recarregar() {
    _ler();
    avisar();
  }

  Future<void> _salvar() => _armazenamento.gravarJson(
    ArmazenamentoLocal.chaveOcorrencias,
    ocorrencias.map((o) => o.toJson()).toList(),
  );
}

class AlertasController extends ChangeNotifier with _NotificaSeguro {
  AlertasController({
    required this.territorio,
    required this.clima,
    required this.ocorrencias,
    required this.preferencias,
    DateTime Function()? relogio,
  }) : _relogio = relogio ?? DateTime.now {
    for (final c in _fontes) {
      c.addListener(_recalcular);
    }
    _recalcular();
  }

  final TerritorioController territorio;
  final ClimaController clima;
  final OcorrenciasController ocorrencias;
  final PreferenciasController preferencias;
  final DateTime Function() _relogio;

  List<Alerta> alertas = const [];
  Set<String> novos = const {};
  bool _primeiro = true;

  List<ChangeNotifier> get _fontes => [territorio, clima, ocorrencias, preferencias];

  void _recalcular() {
    final t = territorio.territorio;
    final eq = territorio.equidade;
    if (t == null || eq == null) {
      alertas = const [];
      avisar();
      return;
    }
    final antes = alertas.map((a) => a.id).toSet();
    final gerados = MotorAlertas(
      territorio: t,
      previsoes: territorio.previsoes,
      equidade: eq,
      limiares: preferencias.limiares,
      ocorrencias: ocorrencias.ocorrencias,
      clima: clima.clima,
      agora: _relogio(),
    ).gerar();
    final ids = gerados.map((a) => a.id).toSet();
    final chegaram = ids.difference(antes);
    if (_primeiro) {
      novos = const {};
      _primeiro = false;
    } else if (chegaram.isNotEmpty) {
      novos = {...novos, ...chegaram};
    }
    novos = novos.intersection(ids);
    alertas = gerados;
    avisar();
  }

  Alerta? porId(String id) {
    for (final a in alertas) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<Alerta> doDistrito(String distritoId) =>
      alertas.where((a) => a.distrito.id == distritoId).toList();

  void marcarVisto(String id) {
    if (!novos.contains(id)) return;
    novos = {...novos}..remove(id);
    avisar();
  }

  @override
  void dispose() {
    for (final c in _fontes) {
      c.removeListener(_recalcular);
    }
    super.dispose();
  }
}
