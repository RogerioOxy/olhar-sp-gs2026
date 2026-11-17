import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/registro_local.dart';
import '../../state/controladores.dart';
import '../textos.dart';
import '../theme/app_theme.dart';
import '../validadores.dart';

class SeletorPerfil extends StatelessWidget {
  const SeletorPerfil({super.key, required this.valor, required this.onChanged});

  final Perfil valor;
  final ValueChanged<Perfil> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Perfil>(
      segments: [
        ButtonSegment(
          value: Perfil.cidadao,
          icon: const Icon(Icons.person_pin_circle_outlined),
          label: Text(Textos.perfilNome(Perfil.cidadao)),
        ),
        ButtonSegment(
          value: Perfil.gestor,
          icon: const Icon(Icons.dashboard_outlined),
          label: Text(Textos.perfilNome(Perfil.gestor)),
        ),
      ],
      selected: {valor},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class CampoDistrito extends StatelessWidget {
  const CampoDistrito({
    super.key,
    required this.territorio,
    required this.valor,
    required this.onChanged,
    this.obrigatorio = true,
    this.rotulo,
  });

  final TerritorioController territorio;
  final String? valor;
  final ValueChanged<String?> onChanged;
  final bool obrigatorio;
  final String? rotulo;

  @override
  Widget build(BuildContext context) {
    final t = territorio.territorio;
    if (territorio.estado == EstadoCarga.carregando) {
      return const LinearProgressIndicator();
    }
    if (t == null) {
      return Text(Textos.distritosIndisponiveis, style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    final ordenados = [...t.distritos]..sort((a, b) => a.nome.compareTo(b.nome));
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: rotulo ?? Textos.campoDistrito),
      items: [
        for (final d in ordenados)
          DropdownMenuItem(value: d.id, child: Text('${d.nome} (${Textos.zona(d.zona)})')),
      ],
      validator: obrigatorio ? validarObrigatorio : null,
      onChanged: onChanged,
    );
  }
}

class CampoConsentimento extends FormField<bool> {
  CampoConsentimento({
    super.key,
    required bool valor,
    required String texto,
    required String erro,
    required ValueChanged<bool> onChanged,
  }) : super(
         initialValue: valor,
         validator: (v) => v == true ? null : erro,
         builder: (estado) {
           final tema = Theme.of(estado.context);
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(AppRaio.sm),
                   border: Border.all(
                     color: estado.hasError ? tema.colorScheme.error : tema.colorScheme.outlineVariant,
                     width: estado.hasError ? 2 : 1,
                   ),
                 ),
                 child: CheckboxListTile(
                   value: estado.value ?? false,
                   controlAffinity: ListTileControlAffinity.leading,
                   title: Text(texto),
                   onChanged: (v) {
                     estado.didChange(v ?? false);
                     onChanged(v ?? false);
                   },
                 ),
               ),
               if (estado.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: AppEspaco.xs, left: AppEspaco.md),
                   child: Semantics(
                     liveRegion: true,
                     child: Text(
                       estado.errorText!,
                       style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.error),
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}

class CampoInteiro extends StatelessWidget {
  const CampoInteiro({
    super.key,
    required this.controlador,
    required this.rotulo,
    required this.ajuda,
    required this.sufixo,
    required this.faixa,
  });

  final TextEditingController controlador;
  final String rotulo;
  final String ajuda;
  final String sufixo;
  final (int, int) faixa;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
      decoration: InputDecoration(labelText: rotulo, helperText: ajuda, suffixText: sufixo),
      validator: (v) => validarInteiroNaFaixa(v, faixa.$1, faixa.$2),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
