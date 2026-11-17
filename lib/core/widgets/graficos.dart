import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SerieGrafico {
  const SerieGrafico({
    required this.rotulo,
    required this.valores,
    required this.cor,
    this.tracejada = false,
    this.faixa,
  });

  final String rotulo;
  final List<double?> valores;
  final Color cor;
  final bool tracejada;
  final List<double?>? faixa;
}

class GraficoLinha extends StatelessWidget {
  const GraficoLinha({
    super.key,
    required this.series,
    required this.rotulosX,
    required this.descricao,
    this.altura = 180,
    this.formatarY,
    this.marcarIndice,
    this.zeroNoEixo = false,
  });

  final List<SerieGrafico> series;
  final List<String> rotulosX;
  final String descricao;
  final double altura;
  final String Function(double)? formatarY;
  final int? marcarIndice;
  final bool zeroNoEixo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final painel = CoresDoPainel.de(context);
    final estiloEixo = tema.textTheme.labelSmall!.copyWith(color: tema.colorScheme.onSurfaceVariant);
    return Semantics(
      container: true,
      label: descricao,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: altura,
            child: CustomPaint(
              painter: _PintorLinha(
                series: series,
                rotulosX: rotulosX,
                grade: painel.grade,
                estiloEixo: estiloEixo,
                escalaTexto: MediaQuery.textScalerOf(context),
                formatarY: formatarY ?? (v) => v.round().toString(),
                marcarIndice: marcarIndice,
                corMarca: tema.colorScheme.onSurfaceVariant,
                zeroNoEixo: zeroNoEixo,
              ),
            ),
          ),
          const SizedBox(height: AppEspaco.sm),
          Legenda(itens: [for (final s in series) (s.rotulo, s.cor, s.tracejada)]),
        ],
      ),
    );
  }
}

class Legenda extends StatelessWidget {
  const Legenda({super.key, required this.itens});

  final List<(String, Color, bool)> itens;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppEspaco.lg,
      runSpacing: AppEspaco.xs,
      children: [
        for (final (rotulo, cor, tracejada) in itens)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 10,
                child: CustomPaint(painter: _PintorAmostra(cor, tracejada)),
              ),
              const SizedBox(width: AppEspaco.xs),
              Flexible(child: Text(rotulo, style: Theme.of(context).textTheme.labelMedium)),
            ],
          ),
      ],
    );
  }
}

class _PintorAmostra extends CustomPainter {
  _PintorAmostra(this.cor, this.tracejada);

  final Color cor;
  final bool tracejada;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = cor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!tracejada) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      return;
    }
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, size.width), y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorAmostra old) => old.cor != cor || old.tracejada != tracejada;
}

class _PintorLinha extends CustomPainter {
  _PintorLinha({
    required this.series,
    required this.rotulosX,
    required this.grade,
    required this.estiloEixo,
    required this.escalaTexto,
    required this.formatarY,
    required this.marcarIndice,
    required this.corMarca,
    required this.zeroNoEixo,
  });

  final List<SerieGrafico> series;
  final List<String> rotulosX;
  final Color grade;
  final TextStyle estiloEixo;
  final TextScaler escalaTexto;
  final String Function(double) formatarY;
  final int? marcarIndice;
  final Color corMarca;
  final bool zeroNoEixo;

  TextPainter _texto(String s) => TextPainter(
    text: TextSpan(text: s, style: estiloEixo),
    textDirection: TextDirection.ltr,
    textScaler: escalaTexto.clamp(maxScaleFactor: 1.6),
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final valores = <double>[];
    for (final s in series) {
      for (var i = 0; i < s.valores.length; i++) {
        final v = s.valores[i];
        if (v == null) continue;
        final f = s.faixa?[i] ?? 0;
        valores
          ..add(v + f)
          ..add(v - f);
      }
    }
    if (valores.isEmpty) return;
    var minY = valores.reduce(math.min);
    var maxY = valores.reduce(math.max);
    if (zeroNoEixo) minY = math.min(0, minY);
    if (maxY == minY) {
      maxY += 1;
      minY -= 1;
    }
    final folga = (maxY - minY) * 0.08;
    maxY += folga;
    if (!zeroNoEixo) minY -= folga;

    final rotMax = _texto(formatarY(maxY));
    final rotMin = _texto(formatarY(minY));
    final esquerda = math.max(rotMax.width, rotMin.width) + 6;
    final rotX = rotulosX.isEmpty ? null : _texto(rotulosX.first);
    final baixo = (rotX?.height ?? 0) + 6;
    final area = Rect.fromLTRB(esquerda, rotMax.height / 2, size.width - 4, size.height - baixo);
    final n = series.map((s) => s.valores.length).fold<int>(0, math.max);
    if (n == 0) return;
    double xDe(int i) => n == 1 ? area.center.dx : area.left + area.width * i / (n - 1);
    double yDe(double v) => area.bottom - (v - minY) / (maxY - minY) * area.height;

    final pGrade = Paint()
      ..color = grade
      ..strokeWidth = 1;
    for (var k = 0; k <= 3; k++) {
      final y = area.top + area.height * k / 3;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), pGrade);
    }
    rotMax.paint(canvas, Offset(0, area.top - rotMax.height / 2));
    rotMin.paint(canvas, Offset(0, area.bottom - rotMin.height / 2));

    if (rotulosX.isNotEmpty) {
      final indices = <int>{0, n ~/ 2, n - 1};
      for (final i in indices) {
        if (i >= rotulosX.length) continue;
        final t = _texto(rotulosX[i]);
        final x = (xDe(i) - t.width / 2).clamp(area.left, size.width - t.width);
        t.paint(canvas, Offset(x, area.bottom + 4));
      }
    }

    final m = marcarIndice;
    if (m != null && m >= 0 && m < n) {
      final x = xDe(m);
      final pm = Paint()
        ..color = corMarca
        ..strokeWidth = 1;
      for (var y = area.top; y < area.bottom; y += 6) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 3, area.bottom)), pm);
      }
    }

    for (final s in series) {
      final faixa = s.faixa;
      if (faixa != null) {
        final cima = <Offset>[];
        final baixoPts = <Offset>[];
        for (var i = 0; i < s.valores.length; i++) {
          final v = s.valores[i];
          final f = faixa[i];
          if (v == null || f == null) continue;
          cima.add(Offset(xDe(i), yDe(v + f)));
          baixoPts.add(Offset(xDe(i), yDe(v - f)));
        }
        if (cima.length == 1) {
          final pf = Paint()
            ..color = s.cor
            ..strokeWidth = 2;
          final a = cima.first;
          final b = baixoPts.first;
          canvas.drawLine(a, b, pf);
          canvas.drawLine(a.translate(-6, 0), a.translate(6, 0), pf);
          canvas.drawLine(b.translate(-6, 0), b.translate(6, 0), pf);
        }
        if (cima.length > 1) {
          final path = Path()..moveTo(cima.first.dx, cima.first.dy);
          for (final p in cima.skip(1)) {
            path.lineTo(p.dx, p.dy);
          }
          for (final p in baixoPts.reversed) {
            path.lineTo(p.dx, p.dy);
          }
          path.close();
          canvas.drawPath(path, Paint()..color = s.cor.withValues(alpha: 0.18));
        }
      }
      final p = Paint()
        ..color = s.cor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      Offset? anterior;
      for (var i = 0; i < s.valores.length; i++) {
        final v = s.valores[i];
        if (v == null) {
          anterior = null;
          continue;
        }
        final atual = Offset(xDe(i), yDe(v));
        if (anterior != null) {
          if (s.tracejada) {
            _tracejar(canvas, anterior, atual, p);
          } else {
            canvas.drawLine(anterior, atual, p);
          }
        }
        anterior = atual;
      }
      final ultimo = s.valores.lastIndexWhere((v) => v != null);
      if (ultimo >= 0) {
        canvas.drawCircle(Offset(xDe(ultimo), yDe(s.valores[ultimo]!)), 4, Paint()..color = s.cor);
      }
    }
  }

  void _tracejar(Canvas canvas, Offset a, Offset b, Paint p) {
    final d = (b - a).distance;
    if (d == 0) return;
    final dir = (b - a) / d;
    for (var t = 0.0; t < d; t += 9) {
      canvas.drawLine(a + dir * t, a + dir * math.min(t + 5, d), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorLinha old) => true;
}

class BarraItem {
  const BarraItem({required this.rotulo, required this.valor, required this.textoValor, required this.cor});

  final String rotulo;
  final double valor;
  final String textoValor;
  final Color cor;
}

class GraficoBarras extends StatelessWidget {
  const GraficoBarras({super.key, required this.itens, required this.descricao, this.maximo});

  final List<BarraItem> itens;
  final String descricao;
  final double? maximo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maior = maximo ?? itens.map((i) => i.valor).fold<double>(0, math.max);
    return Semantics(
      container: true,
      label: descricao,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: AppEspaco.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.rotulo, style: tema.textTheme.bodyMedium)),
                      const SizedBox(width: AppEspaco.sm),
                      Text(item.textoValor, style: tema.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: AppEspaco.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRaio.sm),
                    child: Stack(
                      children: [
                        Container(height: 10, color: tema.colorScheme.surfaceContainerHigh),
                        FractionallySizedBox(
                          widthFactor: maior <= 0 ? 0 : (item.valor / maior).clamp(0.0, 1.0),
                          child: Container(height: 10, color: item.cor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GraficoColunas extends StatelessWidget {
  const GraficoColunas({
    super.key,
    required this.valores,
    required this.destacarAPartirDe,
    required this.marcas,
    required this.descricao,
    required this.cor,
    required this.corDestaque,
    this.altura = 140,
  });

  final List<double> valores;
  final int destacarAPartirDe;
  final List<(int, String)> marcas;
  final String descricao;
  final Color cor;
  final Color corDestaque;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maior = valores.fold<double>(0, math.max);
    return Semantics(
      container: true,
      label: descricao,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: altura,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < valores.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: FractionallySizedBox(
                        heightFactor: maior <= 0 ? 0.01 : math.max(0.01, valores[i] / maior),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: i >= destacarAPartirDe ? corDestaque : cor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppEspaco.xs),
          SizedBox(
            height: 18 * MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6).scale(1),
            child: Stack(
              children: [
                for (final (i, r) in marcas)
                  Align(
                    alignment: Alignment(valores.length <= 1 ? 0 : -1 + 2 * i / (valores.length - 1), 0),
                    child: Text(
                      r,
                      style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
