import 'package:flutter_test/flutter_test.dart';
import 'package:zeladoria_sp/core/formato.dart';
import 'package:zeladoria_sp/core/textos.dart';
import 'package:zeladoria_sp/core/validadores.dart';
import 'package:zeladoria_sp/domain/anonimizacao.dart';

void main() {
  group('validação do formulário', () {
    test('descrição', () {
      expect(validarDescricao(''), Textos.erroDescricaoVazia);
      expect(validarDescricao('   '), Textos.erroDescricaoVazia);
      expect(validarDescricao('buraco'), Textos.erroDescricaoCurta(minDescricao, 6));
      expect(validarDescricao('1234567890 123456'), Textos.erroDescricaoSemPalavras);
      expect(validarDescricao('a' * (maxDescricao + 1)), Textos.erroDescricaoLonga(maxDescricao));
      expect(validarDescricao('Buraco grande perto do ponto de ônibus'), isNull);
    });

    test('obrigatório e referência', () {
      expect(validarObrigatorio(null), Textos.erroObrigatorio);
      expect(validarObrigatorio(' '), Textos.erroObrigatorio);
      expect(validarObrigatorio('grajau'), isNull);
      expect(validarReferencia(''), isNull);
      expect(validarReferencia('x' * (maxReferencia + 1)), Textos.erroReferenciaLonga(maxReferencia));
    });

    test('limiar numérico', () {
      expect(validarInteiroNaFaixa('', 1, 10), Textos.erroObrigatorio);
      expect(validarInteiroNaFaixa('abc', 1, 10), Textos.erroNumero);
      expect(validarInteiroNaFaixa('0', 1, 10), Textos.erroFaixa(1, 10));
      expect(validarInteiroNaFaixa('11', 1, 10), Textos.erroFaixa(1, 10));
      expect(validarInteiroNaFaixa('7', 1, 10), isNull);
    });
  });

  group('anonimização', () {
    test('remove e-mail, telefone, CPF, placa e número de casa', () {
      const m = '[x]';
      final s = anonimizar(
        'Falar com joao.silva@email.com ou (11) 98765-4321, CPF 123.456.789-09, carro ABC1D23, Rua das Flores, 120',
        marcador: m,
      );
      expect(s, isNot(contains('joao.silva')));
      expect(s, isNot(contains('98765')));
      expect(s, isNot(contains('123.456')));
      expect(s, isNot(contains('ABC1D23')));
      expect(s, isNot(contains('120')));
      expect(s, contains('Rua das Flores'));
      expect(s, contains(m));
    });

    test('texto sem dado pessoal fica igual', () {
      const t = 'Lâmpada queimada na praça perto da escola';
      expect(anonimizar(t, marcador: '[x]'), t);
      expect(contemDadoPessoal(t), isFalse);
      expect(contemDadoPessoal('meu zap 11 91234-5678'), isTrue);
    });

    test('id anônimo tem 12 dígitos hexadecimais e hora é arredondada', () {
      expect(gerarIdAnonimo(), matches(RegExp(r'^[0-9a-f]{12}$')));
      expect(arredondarParaHora(DateTime(2026, 11, 16, 14, 37, 12)), DateTime(2026, 11, 16, 14));
    });
  });

  group('formatação', () {
    test('números no padrão brasileiro', () {
      expect(inteiro(1234567), '1.234.567');
      expect(inteiro(-1500), '-1.500');
      expect(decimal(1234.56), '1.234,6');
      expect(decimal(-0.5), '-0,5');
      expect(percentual(0.067, 1), '6,7%');
      expect(comSinal(5, inteiro), '+5');
    });
  });
}
