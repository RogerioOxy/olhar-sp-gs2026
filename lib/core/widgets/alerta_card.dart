import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/alertas.dart';
import '../../state/controladores.dart';
import '../textos.dart';
import '../theme/app_theme.dart';
import 'blocos.dart';

IconData iconeDoAlerta(TipoAlerta t) => switch (t) {
  TipoAlerta.picoDemanda => Icons.trending_up,
  TipoAlerta.quedaRegistro => Icons.trending_down,
  TipoAlerta.chuvaForte => Icons.water_drop_outlined,
  TipoAlerta.ocorrenciasCidadao => Icons.campaign_outlined,
  TipoAlerta.subRegistro => Icons.visibility_off_outlined,
};

class AlertaCard extends StatelessWidget {
  const AlertaCard({super.key, required this.alerta, required this.onTap});

  final Alerta alerta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final novo = context.select<AlertasController, bool>((a) => a.novos.contains(alerta.id));
    final decisao = context.select<PreferenciasController, Object?>((p) => p.decisaoPara(alerta));
    final titulo = Textos.alertaTitulo(alerta.tipo);
    final resumo = Textos.alertaResumo(alerta);
    return Semantics(
      button: true,
      onTap: onTap,
      label: [
        if (novo) Textos.alertaNovo,
        titulo,
        alerta.distrito.nome,
        Textos.prioridade(alerta.prioridade),
        Textos.confianca(alerta.confianca),
        resumo,
        if (decisao != null) Textos.alertaComDecisao,
      ].join('. '),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: novo
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRaio.md),
                side: BorderSide(color: tema.colorScheme.secondary, width: 2),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppEspaco.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(iconeDoAlerta(alerta.tipo), color: tema.colorScheme.primary),
                    const SizedBox(width: AppEspaco.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titulo, style: tema.textTheme.titleMedium),
                          Text(alerta.distrito.nome, style: tema.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: AppEspaco.sm),
                Wrap(
                  spacing: AppEspaco.sm,
                  runSpacing: AppEspaco.xs,
                  children: [
                    if (novo)
                      Etiqueta(
                        texto: Textos.alertaNovo,
                        cor: tema.colorScheme.onSecondaryContainer,
                        fundo: tema.colorScheme.secondaryContainer,
                        icone: Icons.fiber_new_outlined,
                      ),
                    SeloPrioridade(alerta.prioridade),
                    SeloConfianca(alerta.confianca),
                    if (decisao != null)
                      Etiqueta(
                        texto: Textos.alertaComDecisao,
                        cor: tema.colorScheme.onSurface,
                        fundo: tema.colorScheme.surfaceContainerHigh,
                        icone: Icons.how_to_reg_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: AppEspaco.sm),
                Text(resumo, style: tema.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
