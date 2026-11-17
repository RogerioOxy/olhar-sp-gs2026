import 'package:flutter/material.dart';

import '../textos.dart';
import '../theme/app_theme.dart';

class CarregandoView extends StatelessWidget {
  const CarregandoView({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: mensagem ?? Textos.carregando,
        child: Padding(
          padding: const EdgeInsets.all(AppEspaco.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppEspaco.lg),
              ExcludeSemantics(
                child: Text(mensagem ?? Textos.carregando, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MensagemView extends StatelessWidget {
  const MensagemView({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acaoRotulo,
    this.onAcao,
    this.erro = false,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? acaoRotulo;
  final VoidCallback? onAcao;
  final bool erro;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppEspaco.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: erro ? esquema.error : esquema.onSurfaceVariant),
            const SizedBox(height: AppEspaco.md),
            Semantics(
              header: true,
              liveRegion: erro,
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppEspaco.sm),
            Text(mensagem, textAlign: TextAlign.center),
            if (acaoRotulo != null && onAcao != null) ...[
              const SizedBox(height: AppEspaco.lg),
              FilledButton.icon(
                onPressed: onAcao,
                icon: const Icon(Icons.refresh),
                label: Text(acaoRotulo!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErroView extends StatelessWidget {
  const ErroView({super.key, required this.titulo, required this.mensagem, this.onTentar});

  final String titulo;
  final String mensagem;
  final VoidCallback? onTentar;

  @override
  Widget build(BuildContext context) => MensagemView(
    icone: Icons.cloud_off_outlined,
    titulo: titulo,
    mensagem: mensagem,
    acaoRotulo: Textos.tentarDeNovo,
    onAcao: onTentar,
    erro: true,
  );
}

class VazioView extends StatelessWidget {
  const VazioView({super.key, required this.titulo, required this.mensagem, this.icone = Icons.inbox_outlined});

  final String titulo;
  final String mensagem;
  final IconData icone;

  @override
  Widget build(BuildContext context) =>
      MensagemView(icone: icone, titulo: titulo, mensagem: mensagem);
}
