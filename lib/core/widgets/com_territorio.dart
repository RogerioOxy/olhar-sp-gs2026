import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/territorio.dart';
import '../../state/controladores.dart';
import '../textos.dart';
import 'estados.dart';

class ComTerritorio extends StatelessWidget {
  const ComTerritorio({super.key, required this.builder});

  final Widget Function(BuildContext context, Territorio territorio, TerritorioController controle) builder;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<TerritorioController>();
    return switch (c.estado) {
      EstadoCarga.carregando => CarregandoView(mensagem: Textos.carregandoTerritorio),
      EstadoCarga.erro => ErroView(
        titulo: Textos.erroTerritorioTitulo,
        mensagem: Textos.erroTerritorioTexto,
        onTentar: c.carregar,
      ),
      EstadoCarga.pronto => builder(context, c.territorio!, c),
    };
  }
}
