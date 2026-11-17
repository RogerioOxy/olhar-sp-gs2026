import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/textos.dart';
import 'core/theme/app_theme.dart';
import 'data/models/registro_local.dart';
import 'data/services/armazenamento_local.dart';
import 'data/services/clima_servico.dart';
import 'data/services/territorio_repositorio.dart';
import 'router/app_router.dart';
import 'state/controladores.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final armazenamento = await ArmazenamentoLocal.abrir();
  runApp(
    ZeladoriaApp(
      armazenamento: armazenamento,
      territorioRepositorio: TerritorioRepositorio(),
      climaServico: ClimaServico(armazenamento: armazenamento),
    ),
  );
}

class ZeladoriaApp extends StatefulWidget {
  const ZeladoriaApp({
    super.key,
    required this.armazenamento,
    required this.territorioRepositorio,
    required this.climaServico,
    this.relogio,
  });

  final ArmazenamentoLocal armazenamento;
  final TerritorioRepositorio territorioRepositorio;
  final ClimaServico climaServico;
  final DateTime Function()? relogio;

  @override
  State<ZeladoriaApp> createState() => _ZeladoriaAppState();
}

class _ZeladoriaAppState extends State<ZeladoriaApp> with WidgetsBindingObserver {
  late final PreferenciasController _preferencias;
  late final TerritorioController _territorio;
  late final ClimaController _clima;
  late final OcorrenciasController _ocorrencias;
  late final AlertasController _alertas;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _preferencias = PreferenciasController(widget.armazenamento);
    _territorio = TerritorioController(widget.territorioRepositorio)..carregar();
    _clima = ClimaController(widget.climaServico)..iniciar();
    _ocorrencias = OcorrenciasController(widget.armazenamento);
    _alertas = AlertasController(
      territorio: _territorio,
      clima: _clima,
      ocorrencias: _ocorrencias,
      preferencias: _preferencias,
      relogio: widget.relogio,
    );
    _router = criarRouter(_preferencias);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _alertas.recalcular();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alertas.dispose();
    _router.dispose();
    _preferencias.dispose();
    _territorio.dispose();
    _clima.dispose();
    _ocorrencias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _preferencias),
        ChangeNotifierProvider.value(value: _territorio),
        ChangeNotifierProvider.value(value: _clima),
        ChangeNotifierProvider.value(value: _ocorrencias),
        ChangeNotifierProvider.value(value: _alertas),
      ],
      child: Consumer<PreferenciasController>(
        builder: (context, prefs, _) {
          final (claro, escuro, modo) = switch (prefs.tema) {
            TemaEscolhido.sistema => (AppTheme.claro(), AppTheme.escuro(), ThemeMode.system),
            TemaEscolhido.claro => (AppTheme.claro(), AppTheme.escuro(), ThemeMode.light),
            TemaEscolhido.escuro => (AppTheme.claro(), AppTheme.escuro(), ThemeMode.dark),
            TemaEscolhido.altoContraste => (AppTheme.altoContraste(), AppTheme.altoContraste(), ThemeMode.light),
          };
          return MaterialApp.router(
            title: Textos.appNome,
            debugShowCheckedModeBanner: false,
            theme: claro,
            darkTheme: escuro,
            themeMode: modo,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
