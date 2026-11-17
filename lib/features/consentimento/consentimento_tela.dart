import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/campos.dart';
import '../../data/models/registro_local.dart';
import '../../state/controladores.dart';

class ConsentimentoTela extends StatefulWidget {
  const ConsentimentoTela({super.key});

  @override
  State<ConsentimentoTela> createState() => _ConsentimentoTelaState();
}

class _ConsentimentoTelaState extends State<ConsentimentoTela> {
  final _form = GlobalKey<FormState>();
  Perfil _perfil = Perfil.cidadao;
  String? _distrito;
  bool _aceite = false;
  bool _enviando = false;

  Future<void> _continuar() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _enviando = true);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await context.read<PreferenciasController>().darConsentimento(perfil: _perfil, distritoId: _distrito);
    } on Object {
      mensageiro.showSnackBar(SnackBar(content: Text(Textos.erroSalvar)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final territorio = context.watch<TerritorioController>();
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
          child: PaginaRolavel(
            children: [
              const SizedBox(height: AppEspaco.lg),
              Icon(Icons.location_city, size: 48, color: tema.colorScheme.primary),
              Semantics(
                header: true,
                child: Text(Textos.appNome, style: tema.textTheme.headlineSmall),
              ),
              Text(Textos.appSlogan, style: tema.textTheme.titleMedium),
              Secao(
                titulo: Textos.consentimentoTitulo,
                child: ListaMarcadores(itens: Textos.consentimentoItens),
              ),
              Secao(
                titulo: Textos.consentimentoPerfilTitulo,
                child: SeletorPerfil(
                  valor: _perfil,
                  onChanged: (p) => setState(() => _perfil = p),
                ),
              ),
              Secao(
                titulo: Textos.consentimentoDistritoTitulo,
                subtitulo: _perfil == Perfil.cidadao
                    ? Textos.consentimentoDistritoObrigatorio
                    : Textos.consentimentoDistritoOpcional,
                child: CampoDistrito(
                  territorio: territorio,
                  valor: _distrito,
                  obrigatorio: _perfil == Perfil.cidadao,
                  onChanged: (v) => setState(() => _distrito = v),
                ),
              ),
              CampoConsentimento(
                valor: _aceite,
                texto: Textos.consentimentoAceite,
                erro: Textos.consentimentoErro,
                onChanged: (v) => setState(() => _aceite = v),
              ),
              const AvisoDecisaoHumana(compacto: true),
              FilledButton.icon(
                onPressed: _enviando ? null : _continuar,
                icon: const Icon(Icons.check),
                label: Text(Textos.consentimentoBotao),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
