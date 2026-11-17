import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/alerta_card.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/com_territorio.dart';
import '../../core/widgets/estados.dart';
import '../../data/models/registro_local.dart';
import '../../domain/alertas.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class AlertasTela extends StatefulWidget {
  const AlertasTela({super.key});

  @override
  State<AlertasTela> createState() => _AlertasTelaState();
}

class _AlertasTelaState extends State<AlertasTela> {
  TipoAlerta? _tipo;
  bool _soMeuDistrito = false;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferenciasController>();
    final ctrl = context.watch<AlertasController>();
    final clima = context.watch<ClimaController>();
    final cidadao = prefs.perfil == Perfil.cidadao && prefs.meuDistritoId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(Textos.alertasTitulo),
        actions: [
          if (prefs.perfil == Perfil.gestor)
            IconButton(
              tooltip: Textos.ajustarLimiares,
              icon: const Icon(Icons.tune),
              onPressed: () => context.goNamed(Rotas.limiares),
            ),
        ],
      ),
      body: ComTerritorio(
        builder: (context, t, c) {
          final filtrados = ctrl.alertas.where((a) {
            if (_tipo != null && a.tipo != _tipo) return false;
            if (_soMeuDistrito && a.distrito.id != prefs.meuDistritoId) return false;
            return true;
          }).toList();
          return PaginaRolavel(
            onRefresh: clima.atualizar,
            children: [
              const AvisoDecisaoHumana(),
              if (ctrl.novos.isNotEmpty)
                Semantics(
                  liveRegion: true,
                  child: Etiqueta(
                    texto: Textos.alertasNovosAviso(ctrl.novos.length),
                    cor: Theme.of(context).colorScheme.onSecondaryContainer,
                    fundo: Theme.of(context).colorScheme.secondaryContainer,
                    icone: Icons.fiber_new_outlined,
                  ),
                ),
              if (clima.clima == null)
                Text(Textos.alertasSemClima, style: Theme.of(context).textTheme.bodySmall),
              Wrap(
                spacing: AppEspaco.sm,
                runSpacing: AppEspaco.xs,
                children: [
                  ChoiceChip(
                    label: Text(Textos.filtroTodos(ctrl.alertas.length)),
                    selected: _tipo == null,
                    onSelected: (_) => setState(() => _tipo = null),
                  ),
                  for (final tipo in TipoAlerta.values)
                    ChoiceChip(
                      label: Text(Textos.filtroTipo(tipo, ctrl.alertas.where((a) => a.tipo == tipo).length)),
                      selected: _tipo == tipo,
                      onSelected: (_) => setState(() => _tipo = tipo),
                    ),
                ],
              ),
              if (cidadao)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(Textos.soMeuDistrito),
                  value: _soMeuDistrito,
                  onChanged: (v) => setState(() => _soMeuDistrito = v),
                ),
              if (filtrados.isEmpty)
                VazioView(
                  icone: Icons.notifications_off_outlined,
                  titulo: Textos.alertasVazioTitulo,
                  mensagem: ctrl.alertas.isEmpty ? Textos.alertasVazioTexto : Textos.alertasFiltroVazio,
                )
              else
                for (final a in filtrados)
                  AlertaCard(
                    alerta: a,
                    onTap: () => context.goNamed(Rotas.alerta, pathParameters: {'alertaId': a.id}),
                  ),
            ],
          );
        },
      ),
    );
  }
}
