import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validadores.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/campos.dart';
import '../../core/widgets/estados.dart';
import '../../data/models/territorio.dart';
import '../../router/app_router.dart';
import '../../state/controladores.dart';

class RegistrarTela extends StatefulWidget {
  const RegistrarTela({super.key, this.distritoInicial});

  final String? distritoInicial;

  @override
  State<RegistrarTela> createState() => _RegistrarTelaState();
}

class _RegistrarTelaState extends State<RegistrarTela> {
  final _form = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _referencia = TextEditingController();
  String? _distrito;
  Categoria? _categoria;
  bool _consentimento = false;
  bool _enviando = false;
  int _versaoForm = 0;
  String? _avisoPessoal;

  @override
  void initState() {
    super.initState();
    _distrito = widget.distritoInicial ?? context.read<PreferenciasController>().meuDistritoId;
  }

  @override
  void didUpdateWidget(covariant RegistrarTela oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.distritoInicial != null && widget.distritoInicial != oldWidget.distritoInicial) {
      setState(() {
        _distrito = widget.distritoInicial;
        _versaoForm++;
      });
    }
  }

  @override
  void dispose() {
    _descricao.dispose();
    _referencia.dispose();
    super.dispose();
  }

  void _atualizarAviso() {
    final aviso = avisoDadoPessoal('${_descricao.text} ${_referencia.text}');
    if (aviso != _avisoPessoal) setState(() => _avisoPessoal = aviso);
  }

  Future<void> _enviar() async {
    final valido = _form.currentState?.validate() ?? false;
    if (!valido) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(Textos.formularioComErros)));
      return;
    }
    setState(() => _enviando = true);
    final alertas = context.read<AlertasController>();
    final antes = alertas.alertas.map((a) => a.id).toSet();
    final o = await context.read<OcorrenciasController>().registrar(
      distritoId: _distrito!,
      categoria: _categoria!,
      descricao: _descricao.text,
      referencia: _referencia.text,
      marcadorRemovido: Textos.marcadorRemovido,
    );
    if (!mounted) return;
    final novos = alertas.alertas.where((a) => !antes.contains(a.id)).toList();
    setState(() {
      _enviando = false;
      _descricao.clear();
      _referencia.clear();
      _categoria = null;
      _consentimento = false;
      _avisoPessoal = null;
      _versaoForm++;
    });
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline),
        title: Text(Textos.ocorrenciaSalvaTitulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Textos.ocorrenciaSalvaTexto(o.id, o.descricao)),
            if (novos.isNotEmpty) ...[
              const SizedBox(height: AppEspaco.md),
              Text(Textos.ocorrenciaGerouAlerta(novos.length), style: Theme.of(ctx).textTheme.titleSmall),
            ],
          ],
        ),
        actions: [
          if (novos.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.goNamed(Rotas.alerta, pathParameters: {'alertaId': novos.first.id});
              },
              child: Text(Textos.verAlerta),
            ),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(Textos.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final territorio = context.watch<TerritorioController>();
    final ocorrencias = context.watch<OcorrenciasController>().ocorrencias;
    final limiar = context.select<PreferenciasController, int>((p) => p.limiares.ocorrencias7Dias);
    return Scaffold(
      appBar: AppBar(title: Text(Textos.registrarTitulo)),
      body: Form(
        key: _form,
        child: PaginaRolavel(
          children: [
            Text(Textos.registrarIntro, style: Theme.of(context).textTheme.bodyLarge),
            Secao(
              titulo: Textos.privacidadeFormTitulo,
              child: ListaMarcadores(itens: Textos.privacidadeFormItens),
            ),
            CampoDistrito(
              key: ValueKey('distrito-$_versaoForm'),
              territorio: territorio,
              valor: _distrito,
              onChanged: (v) => setState(() => _distrito = v),
            ),
            DropdownButtonFormField<Categoria>(
              key: ValueKey('categoria-$_versaoForm'),
              initialValue: _categoria,
              isExpanded: true,
              decoration: InputDecoration(labelText: Textos.campoCategoria),
              items: [
                for (final c in Categoria.values) DropdownMenuItem(value: c, child: Text(Textos.categoria(c))),
              ],
              validator: validarObrigatorio,
              onChanged: (c) => setState(() => _categoria = c),
            ),
            TextFormField(
              controller: _descricao,
              minLines: 3,
              maxLines: 6,
              maxLength: maxDescricao,
              decoration: InputDecoration(
                labelText: Textos.campoDescricao,
                helperText: Textos.campoDescricaoAjuda(minDescricao),
                alignLabelWithHint: true,
              ),
              validator: validarDescricao,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (_) => _atualizarAviso(),
            ),
            TextFormField(
              controller: _referencia,
              maxLength: maxReferencia,
              decoration: InputDecoration(
                labelText: Textos.campoReferencia,
                helperText: Textos.campoReferenciaAjuda,
              ),
              validator: validarReferencia,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (_) => _atualizarAviso(),
            ),
            if (_avisoPessoal != null)
              Semantics(
                liveRegion: true,
                child: Etiqueta(
                  texto: _avisoPessoal!,
                  cor: Theme.of(context).colorScheme.onSecondaryContainer,
                  fundo: Theme.of(context).colorScheme.secondaryContainer,
                  icone: Icons.privacy_tip_outlined,
                ),
              ),
            CampoConsentimento(
              key: ValueKey('consentimento-$_versaoForm'),
              valor: _consentimento,
              texto: Textos.registrarConsentimento,
              erro: Textos.registrarConsentimentoErro,
              onChanged: (v) => setState(() => _consentimento = v),
            ),
            Text(Textos.registrarGatilho(limiar), style: Theme.of(context).textTheme.bodySmall),
            FilledButton.icon(
              onPressed: _enviando ? null : _enviar,
              icon: _enviando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_outlined),
              label: Text(Textos.registrarBotao),
            ),
            Secao(
              titulo: Textos.minhasOcorrenciasTitulo,
              subtitulo: Textos.minhasOcorrenciasSubtitulo,
              child: ocorrencias.isEmpty
                  ? VazioView(titulo: Textos.minhasOcorrenciasVazioTitulo, mensagem: Textos.minhasOcorrenciasVazioTexto)
                  : Column(
                      children: [
                        for (final o in ocorrencias.take(10))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.place_outlined),
                            title: Text(
                              '${Textos.categoria(o.categoria)} · ${territorio.territorio?.distrito(o.distritoId)?.nome ?? o.distritoId}',
                            ),
                            subtitle: Text('${dataHora(o.criadaEm)} · ${o.descricao}'),
                            trailing: IconButton(
                              tooltip: Textos.apagarOcorrencia,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => context.read<OcorrenciasController>().remover(o.id),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
