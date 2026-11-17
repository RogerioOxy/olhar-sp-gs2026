import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/campos.dart';
import '../../data/models/registro_local.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class AjustesTela extends StatelessWidget {
  const AjustesTela({super.key});

  Future<void> _apagar(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: Text(Textos.apagarDadosTitulo),
        content: Text(Textos.apagarDadosTexto),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(Textos.cancelar)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(Textos.apagarDadosConfirmar)),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    final ocorrencias = context.read<OcorrenciasController>();
    final clima = context.read<ClimaController>();
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await context.read<PreferenciasController>().apagarTudo();
    } on Object {
      mensageiro.showSnackBar(SnackBar(content: Text(Textos.erroSalvar)));
      return;
    }
    ocorrencias.recarregar();
    await clima.reiniciar();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferenciasController>();
    final territorio = context.watch<TerritorioController>();
    return Scaffold(
      appBar: AppBar(title: Text(Textos.ajustesTitulo)),
      body: PaginaRolavel(
        children: [
          Secao(
            titulo: Textos.ajustesPerfilTitulo,
            subtitulo: Textos.ajustesPerfilSubtitulo,
            child: SeletorPerfil(valor: prefs.perfil, onChanged: prefs.definirPerfil),
          ),
          Secao(
            titulo: Textos.ajustesDistritoTitulo,
            child: CampoDistrito(
              key: ValueKey(prefs.meuDistritoId),
              territorio: territorio,
              valor: prefs.meuDistritoId,
              obrigatorio: false,
              onChanged: (v) {
                if (v != null) prefs.definirDistrito(v);
              },
            ),
          ),
          Secao(
            titulo: Textos.ajustesTemaTitulo,
            child: RadioGroup<TemaEscolhido>(
              groupValue: prefs.tema,
              onChanged: (t) {
                if (t != null) prefs.definirTema(t);
              },
              child: Column(
                children: [
                  for (final t in TemaEscolhido.values)
                    RadioListTile<TemaEscolhido>(
                      contentPadding: EdgeInsets.zero,
                      value: t,
                      title: Text(Textos.temaNome(t)),
                    ),
                ],
              ),
            ),
          ),
          Card(
            semanticContainer: false,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(Textos.limiaresTitulo),
                  subtitle: Text(Textos.ajustesLimiaresResumo(prefs.limiares)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(Rotas.limiares),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(Textos.sobreDadosTitulo),
                  subtitle: Text(Textos.sobreDadosResumo),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(Rotas.sobreDados),
                ),
              ],
            ),
          ),
          Secao(
            titulo: Textos.privacidadeTitulo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListaMarcadores(itens: Textos.privacidadeItens),
                if (prefs.consentimentoEm != null)
                  LinhaInfo(rotulo: Textos.consentimentoDadoEm, valor: dataHora(prefs.consentimentoEm!)),
                const SizedBox(height: AppEspaco.sm),
                OutlinedButton.icon(
                  onPressed: () => _apagar(context),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(Textos.apagarDadosBotao),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
