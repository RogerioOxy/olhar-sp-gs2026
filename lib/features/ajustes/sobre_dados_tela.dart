import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/textos.dart';
import '../../core/widgets/blocos.dart';
import '../../core/widgets/com_territorio.dart';

class SobreDadosTela extends StatelessWidget {
  const SobreDadosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Textos.sobreDadosTitulo)),
      body: ComTerritorio(
        builder: (context, t, c) {
          final r = c.resumo!;
          final ps = [...c.previsoes]..sort((a, b) => a.backtest.mape.compareTo(b.backtest.mape));
          return PaginaRolavel(
            children: [
              Secao(
                titulo: Textos.fontesTitulo,
                child: ListaMarcadores(itens: Textos.fontes(t.semente, t.distritos.length, t.meses.length)),
              ),
              Secao(
                titulo: Textos.metricasTitulo,
                subtitulo: Textos.metricasSubtitulo(r.meses),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinhaInfo(rotulo: Textos.metricaMae, valor: decimal(r.maeMedio)),
                    LinhaInfo(rotulo: Textos.metricaMape, valor: percentual(r.mapeGeral, 1)),
                    LinhaInfo(rotulo: Textos.metricaMelhor(ps.first.distrito.nome), valor: percentual(ps.first.backtest.mape, 1)),
                    LinhaInfo(rotulo: Textos.metricaPior(ps.last.distrito.nome), valor: percentual(ps.last.backtest.mape, 1)),
                    const SizedBox(height: 8),
                    Text(Textos.metricasComoLer),
                  ],
                ),
              ),
              Secao(titulo: Textos.comoAlertasTitulo, child: ListaMarcadores(itens: Textos.comoAlertas)),
              Secao(titulo: Textos.viesesTitulo, child: ListaMarcadores(itens: Textos.vieses)),
              Secao(titulo: Textos.naoConfiavelTitulo, child: ListaMarcadores(itens: Textos.naoConfiavel)),
              Secao(titulo: Textos.acessibilidadeTitulo, child: ListaMarcadores(itens: Textos.acessibilidadeItens)),
              const AvisoDecisaoHumana(),
            ],
          );
        },
      ),
    );
  }
}
