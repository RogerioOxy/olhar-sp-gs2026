import '../domain/anonimizacao.dart';
import 'textos.dart';

const minDescricao = 15;
const maxDescricao = 280;
const maxReferencia = 80;

String? validarObrigatorio(Object? v) {
  if (v == null) return Textos.erroObrigatorio;
  if (v is String && v.trim().isEmpty) return Textos.erroObrigatorio;
  return null;
}

String? validarDescricao(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return Textos.erroDescricaoVazia;
  if (t.length < minDescricao) return Textos.erroDescricaoCurta(minDescricao, t.length);
  if (t.length > maxDescricao) return Textos.erroDescricaoLonga(maxDescricao);
  if (!RegExp(r'[A-Za-zÀ-ÿ]{3,}').hasMatch(t)) return Textos.erroDescricaoSemPalavras;
  return null;
}

String? validarReferencia(String? v) {
  final t = (v ?? '').trim();
  if (t.length > maxReferencia) return Textos.erroReferenciaLonga(maxReferencia);
  return null;
}

String? avisoDadoPessoal(String? v) => contemDadoPessoal(v ?? '') ? Textos.avisoDadoPessoal : null;

String? validarInteiroNaFaixa(String? v, int min, int max) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return Textos.erroObrigatorio;
  final n = int.tryParse(t);
  if (n == null) return Textos.erroNumero;
  if (n < min || n > max) return Textos.erroFaixa(min, max);
  return null;
}
