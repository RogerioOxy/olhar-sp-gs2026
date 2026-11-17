import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/textos.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/campos.dart';
import '../../data/models/registro_local.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class LimiaresTela extends StatefulWidget {
  const LimiaresTela({super.key});

  @override
  State<LimiaresTela> createState() => _LimiaresTelaState();
}

class _LimiaresTelaState extends State<LimiaresTela> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _pico;
  late final TextEditingController _queda;
  late final TextEditingController _chuva;
  late final TextEditingController _ocorrencias;
  late final TextEditingController _sub;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final l = context.read<PreferenciasController>().limiares;
    _pico = TextEditingController(text: '${l.picoPercentual}');
    _queda = TextEditingController(text: '${l.quedaPercentual}');
    _chuva = TextEditingController(text: '${l.chuvaMm3Dias}');
    _ocorrencias = TextEditingController(text: '${l.ocorrencias7Dias}');
    _sub = TextEditingController(text: '${l.subRegistroPercentual}');
  }

  @override
  void dispose() {
    for (final c in [_pico, _queda, _chuva, _ocorrencias, _sub]) {
      c.dispose();
    }
    super.dispose();
  }

  void _preencher(Limiares l) {
    _pico.text = '${l.picoPercentual}';
    _queda.text = '${l.quedaPercentual}';
    _chuva.text = '${l.chuvaMm3Dias}';
    _ocorrencias.text = '${l.ocorrencias7Dias}';
    _sub.text = '${l.subRegistroPercentual}';
  }

  Future<void> _salvar() async {
    if (!(_form.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(Textos.formularioComErros)));
      return;
    }
    setState(() => _salvando = true);
    final alertas = context.read<AlertasController>();
    final antes = alertas.alertas.map((a) => a.id).toSet();
    try {
      await context.read<PreferenciasController>().salvarLimiares(
        Limiares(
          picoPercentual: int.parse(_pico.text),
          quedaPercentual: int.parse(_queda.text),
          chuvaMm3Dias: int.parse(_chuva.text),
          ocorrencias7Dias: int.parse(_ocorrencias.text),
          subRegistroPercentual: int.parse(_sub.text),
        ),
      );
    } on Object {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(Textos.erroSalvar)));
      return;
    }
    if (!mounted) return;
    setState(() => _salvando = false);
    final depois = alertas.alertas.map((a) => a.id).toSet();
    final novos = depois.difference(antes).length;
    final sairam = antes.difference(depois).length;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          duration: const Duration(seconds: 6),
          content: Text(Textos.limiaresSalvos(novos, sairam, depois.length)),
          action: SnackBarAction(label: Textos.verAlertas, onPressed: () => context.goNamed(Rotas.alertas)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.limiaresTitulo)),
      body: Form(
        key: _form,
        child: PaginaRolavel(
          children: [
            Text(Textos.limiaresIntro, style: Theme.of(context).textTheme.bodyLarge),
            const AvisoDecisaoHumana(compacto: true),
            CampoInteiro(
              controlador: _pico,
              rotulo: Textos.limiarPicoRotulo,
              ajuda: Textos.limiarPicoAjuda,
              sufixo: '%',
              faixa: Limiares.faixaPico,
            ),
            CampoInteiro(
              controlador: _queda,
              rotulo: Textos.limiarQuedaRotulo,
              ajuda: Textos.limiarQuedaAjuda,
              sufixo: '%',
              faixa: Limiares.faixaQueda,
            ),
            CampoInteiro(
              controlador: _chuva,
              rotulo: Textos.limiarChuvaRotulo,
              ajuda: Textos.limiarChuvaAjuda,
              sufixo: 'mm',
              faixa: Limiares.faixaChuva,
            ),
            CampoInteiro(
              controlador: _ocorrencias,
              rotulo: Textos.limiarOcorrenciasRotulo,
              ajuda: Textos.limiarOcorrenciasAjuda,
              sufixo: '',
              faixa: Limiares.faixaOcorrencias,
            ),
            CampoInteiro(
              controlador: _sub,
              rotulo: Textos.limiarSubRegistroRotulo,
              ajuda: Textos.limiarSubRegistroAjuda,
              sufixo: '%',
              faixa: Limiares.faixaSubRegistro,
            ),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(Textos.limiaresSalvar),
            ),
            TextButton(
              onPressed: () => _preencher(const Limiares()),
              child: Text(Textos.limiaresPadrao),
            ),
          ],
        ),
      ),
    );
  }
}
