import 'formato.dart';
import '../data/models/clima.dart';
import '../data/models/registro_local.dart';
import '../data/models/territorio.dart';
import '../data/services/clima_servico.dart';
import '../domain/alertas.dart';
import '../domain/previsao.dart';

class Textos {
  static const erroSalvar =
      'Não foi possível salvar no aparelho. Tente de novo.';
  static String climaPrevisaoParcial(int dias) =>
      'A previsão salva está incompleta: $dias ${dias == 1 ? 'dia disponível' : 'dias disponíveis'} de 3 necessários. Atualize com internet.';
  static const appNome = 'Olhar SP';
  static const appSlogan =
      'Previsões e registros para cuidar dos distritos de São Paulo.';

  static const carregando = 'Carregando...';
  static const carregandoTerritorio = 'Carregando os dados dos distritos...';
  static const carregandoClima = 'Buscando os dados do clima...';
  static const tentarDeNovo = 'Tentar de novo';
  static const erroTerritorioTitulo = 'Não foi possível ler os dados';
  static const erroTerritorioTexto =
      'Os dados dos distritos não puderam ser abertos. Tente de novo.';
  static const erroClimaTitulo = 'Clima indisponível';
  static String erroClima(FalhaClima? f) => switch (f) {
    FalhaClima.semConexao =>
      'Sem conexão. Confira sua internet e tente de novo.',
    FalhaClima.tempoEsgotado =>
      'A consulta demorou mais que o esperado. Tente de novo.',
    FalhaClima.servidor =>
      'O serviço de clima não respondeu como esperado. Tente mais tarde.',
    FalhaClima.formato =>
      'Não foi possível ler a resposta do clima. Tente atualizar.',
    null => 'Não foi possível carregar o clima. Tente de novo.',
  };
  static const semDado = 'sem dado';
  static const ok = 'OK';
  static const cancelar = 'Cancelar';
  static const hoje = 'hoje';
  static const naoEncontradaTitulo = 'Página não encontrada';
  static const naoEncontradaTexto =
      'Este endereço não corresponde a uma tela do app.';
  static const voltarAoInicio = 'Voltar ao início';
  static const verTodos = 'Ver todos';
  static const verPainel = 'Ver painel';
  static const verDetalhe = 'Ver detalhe';
  static const verAlerta = 'Ver alerta';
  static const verAlertas = 'Ver alertas';
  static const formularioComErros =
      'Corrija os campos marcados para continuar.';

  static const navInicio = 'Início';
  static const navInicioDica = 'Abrir o início';
  static const navPaineis = 'Painéis';
  static const navPaineisDica = 'Explorar os painéis';
  static const navAlertas = 'Alertas';
  static String navAlertasDica(int total, int novos) =>
      '${total == 1 ? 'Alerta' : 'Alertas'}: $total, ${novos == 1 ? 'novo' : 'novos'}: $novos';
  static const navRegistrar = 'Registrar';
  static const navRegistrarDica = 'Registrar uma ocorrência';
  static const navAjustes = 'Ajustes';
  static const navAjustesDica = 'Abrir os ajustes';

  static String mesCurto(DateTime m) =>
      '${const ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'][m.month - 1]}/${(m.year % 100).toString().padLeft(2, '0')}';
  static String mesLongo(DateTime m) =>
      '${const ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'][m.month - 1]} de ${m.year}';
  static String diaSemana(DateTime d) =>
      '${const ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'][d.weekday - 1]}, ${dataCurta(d)}';
  static String zona(String zona) => switch (zona) {
    'sul' => 'Zona Sul',
    'leste' => 'Zona Leste',
    'norte' => 'Zona Norte',
    'oeste' => 'Zona Oeste',
    _ => 'Zona não informada',
  };
  static String faixa(FaixaRenda f) => switch (f) {
    FaixaRenda.baixa => 'Baixa renda',
    FaixaRenda.media => 'Renda média',
    FaixaRenda.alta => 'Alta renda',
  };
  static String categoria(Categoria c) => switch (c) {
    Categoria.buraco => 'Buraco',
    Categoria.iluminacao => 'Iluminação',
    Categoria.poda => 'Poda',
    Categoria.entulho => 'Entulho',
    Categoria.bocaDeLobo => 'Boca de lobo',
  };
  static String populacao(int p) =>
      p >= 1000 ? '${inteiro(p / 1000)} mil hab.' : '${inteiro(p)} hab.';
  static String perfilNome(Perfil p) =>
      p == Perfil.cidadao ? 'Cidadão' : 'Gestor';
  static String temaNome(TemaEscolhido t) => switch (t) {
    TemaEscolhido.sistema => 'Do aparelho',
    TemaEscolhido.claro => 'Claro',
    TemaEscolhido.escuro => 'Escuro',
    TemaEscolhido.altoContraste => 'Alto contraste',
  };
  static String confianca(Confianca c) => switch (c) {
    Confianca.baixa => 'Confiança baixa',
    Confianca.media => 'Confiança média',
    Confianca.alta => 'Confiança alta',
  };
  static String prioridade(Prioridade p) =>
      p == Prioridade.alta ? 'Prioridade alta' : 'Atenção';
  static String tendencia(Tendencia t, double porMes) => switch (t) {
    Tendencia.alta => 'Alta de ${percentual(porMes.abs(), 1)} ao mês',
    Tendencia.queda => 'Queda de ${percentual(porMes.abs(), 1)} ao mês',
    Tendencia.estavel => 'Estável',
  };
  static String tendenciaDiferenca(Tendencia t, double porMes) => switch (t) {
    Tendencia.alta => 'Diferença sobe ${percentual(porMes.abs(), 1)}/mês',
    Tendencia.queda => 'Diferença cai ${percentual(porMes.abs(), 1)}/mês',
    Tendencia.estavel => 'Diferença estável',
  };
  static String tendenciaTemperatura(double porDia) => porDia > 0.01
      ? 'Esquentando'
      : porDia < -0.01
      ? 'Esfriando'
      : 'Estável';
  static const rotuloSintetico = 'Estimativa, dados sintéticos';

  static const avisoDecisaoTitulo = 'A decisão é de uma pessoa';
  static const avisoDecisaoTexto =
      'Os alertas ajudam a analisar os dados, mas não substituem a decisão de uma pessoa. O app não envia equipes nem toma ações sozinho.';
  static const avisoDecisaoCurto =
      'O app apoia sua análise; a decisão e qualquer ação dependem de uma pessoa.';

  static const consentimentoTitulo = 'Antes de começar';
  static const List<String> consentimentoItens = [
    'O app guarda ocorrências, decisões, preferências, clima e a data do consentimento só neste aparelho.',
    'Não pedimos nome, telefone nem e-mail.',
    'E-mail, telefone, CPF, placa, nome após "meu nome é", "me chamo" ou "sou" e número após nome de rua, quando identificados, são trocados por [removido].',
    'A remoção automática pode falhar com nome ou endereço escrito de outro jeito. Não escreva nome, contato nem endereço completo.',
    'Você pode apagar todos os dados em Ajustes.',
    'Os dados de zeladoria são simulados. Os dados de clima são reais, da Open-Meteo.',
  ];
  static const consentimentoPerfilTitulo = 'Como você vai usar o app?';
  static const consentimentoDistritoTitulo = 'Escolha seu distrito';
  static const consentimentoDistritoObrigatorio =
      'Escolha um distrito para ver os dados perto de você.';
  static const consentimentoDistritoOpcional =
      'Para o gestor, escolher um distrito é opcional.';
  static const consentimentoAceite =
      'Concordo com o uso local dos dados descrito acima.';
  static const consentimentoErro = 'Marque o aceite para continuar.';
  static const consentimentoBotao = 'Começar';
  static const consentimentoDadoEm = 'Consentimento dado em';

  static const campoDistrito = 'Distrito';
  static const distritosIndisponiveis =
      'Não foi possível carregar a lista de distritos.';
  static const erroObrigatorio = 'Preencha este campo.';
  static const erroNumero = 'Digite um número inteiro.';
  static String erroFaixa(int min, int max) =>
      'Use um valor entre $min e $max.';

  static const inicioGestorTitulo = 'Visão geral';
  static const inicioCidadaoTitulo = 'Meu distrito';
  static String trocarPerfilDica(Perfil atual) =>
      'Mudar para ${atual == Perfil.cidadao ? 'gestor' : 'cidadão'}';
  static const inicioGestorIntro =
      'Veja onde os pedidos fogem do esperado, acompanhe a chuva e compare o atendimento. Use os alertas para avaliar onde vale olhar de perto.';
  static const kpiAlertas = 'Alertas ativos';
  static String kpiAlertasDetalhe(int altas) =>
      '${inteiro(altas)} com prioridade alta';
  static const kpiAcerto = 'Erro percentual';
  static String kpiAcertoDetalhe(double mae, int meses) =>
      'Erro médio de ${decimal(mae)} ${decimal(mae) == '1,0' ? 'pedido' : 'pedidos'} por mês e distrito no teste de $meses ${meses == 1 ? 'mês' : 'meses'}.';
  static const kpiSocial = 'Diferença de atendimento';
  static String kpiSocialDetalhe(double baixa, double alta) =>
      'Por 10 mil hab./mês: baixa renda ${decimal(baixa)}; alta renda ${decimal(alta)}.';
  static const kpiChuva = 'Chuva prevista em 3 dias';
  static String kpiChuvaDetalhe(int probMax) =>
      'Maior chance diária de chuva: $probMax%.';
  static const climaIndisponivelCurto = 'Sem dados de clima disponíveis';
  static const inicioDemandaTitulo = 'Pedidos na cidade';
  static const inicioDemandaSubtitulo =
      'Últimos 12 meses: pedidos registrados e previstos.';
  static String graficoCidadeDescricao(
    double registradosUltimo,
    double previstoUltimo,
  ) =>
      'Pedidos na cidade nos últimos 12 meses. No último mês: ${inteiro(registradosUltimo)} ${inteiro(registradosUltimo) == '1' ? 'registrado' : 'registrados'} e ${inteiro(previstoUltimo)} ${inteiro(previstoUltimo) == '1' ? 'previsto' : 'previstos'}.';
  static const serieRegistrados = 'Registrados';
  static const seriePrevistos = 'Previstos';
  static const inicioDesviosTitulo = 'Maiores desvios por distrito';
  static const inicioDesviosSubtitulo =
      'Diferença entre registrados e previstos no último mês.';
  static String desvioLinha(int real, double previsto, double desvio) =>
      '${inteiro(real)} ${inteiro(real) == '1' ? 'registrado' : 'registrados'}, ${inteiro(previsto)} ${inteiro(previsto) == '1' ? 'previsto' : 'previstos'} (${comSinal(desvio, percentual)})';
  static const inicioAlertasTitulo = 'Alertas para analisar';

  static const meuDistritoVazioTitulo = 'Escolha seu distrito';
  static const meuDistritoVazioTexto =
      'Você ainda não escolheu um distrito. Selecione um para acompanhar os pedidos e alertas.';
  static String meuDistritoTitulo(String nome) => nome;
  static const trocarDistrito = 'Trocar distrito';
  static const meuDistritoIntro =
      'Acompanhe os pedidos, a previsão e os alertas do seu distrito. Os dados de zeladoria são simulados.';
  static const kpiPrevistoProximo = 'Previsão do próximo mês';
  static String kpiPrevistoProximoDetalhe(double faixa) =>
      'Faixa aproximada de ${inteiro(faixa)} ${inteiro(faixa) == '1' ? 'pedido' : 'pedidos'} para mais ou para menos: 1,28 x RMSE do teste de 6 meses. É uma heurística, supondo erros parecidos com os do teste e mais ou menos simétricos. A cobertura real não foi medida; não é garantia.';
  static const kpiAtendimentoDistrito = 'Atendidos por 10 mil hab.';
  static String kpiAtendimentoDistritoDetalhe(double baixa, double alta) =>
      'Médias por 10 mil hab./mês: baixa renda ${decimal(baixa)}; alta renda ${decimal(alta)}.';
  static const meuDistritoGraficoTitulo = 'Pedidos do distrito';
  static String graficoDistritoDescricao(
    String nome,
    int real,
    double previsto,
  ) =>
      'Pedidos em $nome. No último mês: ${inteiro(real)} ${inteiro(real) == '1' ? 'registrado' : 'registrados'} e ${inteiro(previsto)} ${inteiro(previsto) == '1' ? 'previsto' : 'previstos'}.';
  static const meuDistritoAlertasTitulo = 'Alertas do distrito';
  static const meuDistritoSemAlertasTitulo = 'Sem alertas ativos';
  static const meuDistritoSemAlertasTexto =
      'Nenhum alerta atingiu os limites atuais. Isso não significa que não haja problemas.';
  static const meuDistritoSubRegistroTitulo = 'O que pode ficar sem registro';
  static String meuDistritoSubRegistroTexto(double estimativa, double margem) =>
      'Estima-se que ${percentual(estimativa)} dos problemas fiquem sem registro, com margem de ${decimal(margem * 100, 1)} ${decimal(margem * 100, 1) == '1,0' ? 'ponto percentual' : 'pontos percentuais'} para mais ou para menos. A margem aproxima a incerteza da amostra, sem cobertura comprovada. Registros e achados vêm de processos separados. Os dados são sintéticos.';
  static const minhasOcorrenciasTitulo = 'Minhas ocorrências';
  static const minhasOcorrenciasSubtitulo =
      'Estes registros ficam só neste aparelho.';
  static const minhasOcorrenciasVazioTitulo = 'Nenhuma ocorrência salva';
  static const minhasOcorrenciasVazioTexto =
      'Você pode registrar um problema de zeladoria para acompanhar aqui.';
  static const registrarCurto = 'Registrar';

  static const paineisTitulo = 'Painéis';
  static const paineisIntro =
      'Explore os pedidos, o clima e as diferenças de atendimento entre distritos.';
  static const painelDemandaTitulo = 'Pedidos e previsão';
  static const painelDemandaResumo =
      'Compare os pedidos registrados com a previsão de cada distrito.';
  static const painelClimaTitulo = 'Clima e zeladoria';
  static const painelClimaResumo =
      'Acompanhe chuva e temperatura para apoiar a análise dos alertas.';
  static const painelEquidadeTitulo = 'Atendimento e desigualdade';
  static const painelEquidadeResumo =
      'Compare o atendimento por faixa de renda e o sub-registro estimado.';

  static const painelDemandaIntro =
      'A previsão usa a média dos 3 meses anteriores sem o efeito da estação e aplica o padrão sazonal da cidade. O cálculo usa só o passado e precisa de 12 meses de histórico.';
  static String kpiRegistradosMes(String mes) => 'Registros: $mes';
  static String kpiRegistradosMesDetalhe(double previsto) =>
      'Previsão: ${inteiro(previsto)} ${inteiro(previsto) == '1' ? 'pedido' : 'pedidos'}.';
  static const kpiPrevistoCidade = 'Previsão para a cidade';
  static String kpiPrevistoCidadeDetalhe(String mes) =>
      'Pedidos previstos para $mes.';
  static const kpiErroModelo = 'Erro médio em pedidos';
  static String kpiErroModeloDetalhe(double mape, int meses) =>
      'Erro percentual de ${percentual(mape, 1)} no teste de $meses ${meses == 1 ? 'mês' : 'meses'}.';
  static const demandaGraficoTitulo = 'Histórico e próximo mês';
  static const demandaGraficoSubtitulo =
      '24 meses de registros. O trecho tracejado mostra a previsão do próximo mês.';
  static const demandaDistritosTitulo = 'Comparar distritos';
  static const demandaDistritosSubtitulo =
      'Veja o desvio do último mês e a tendência de cada distrito.';
  static const buscarDistrito = 'Buscar distrito';
  static const todasZonas = 'Todas as zonas';
  static const ordenarPor = 'Ordenar por';
  static const ordemDesvio = 'Maior desvio';
  static const ordemTendencia = 'Tendência';
  static const ordemNome = 'Nome';
  static const buscaVaziaTitulo = 'Nenhum distrito encontrado';
  static String buscaVaziaTexto(String busca) =>
      'Nenhum resultado para "$busca". Tente outro nome ou zona.';
  static String linhaDistritoSemantica(
    String nome,
    int real,
    double previsto,
    double desvio,
    Tendencia t,
  ) =>
      '$nome: ${desvioLinha(real, previsto, desvio)}. Tendência: ${switch (t) {
        Tendencia.alta => 'alta',
        Tendencia.queda => 'queda',
        Tendencia.estavel => 'estável',
      }}.';

  static const indicadorTitulo = 'Dados do distrito';
  static String indicadorTituloDe(String nome) => 'Dados de $nome';
  static const distritoNaoEncontradoTitulo = 'Distrito não encontrado';
  static const distritoNaoEncontradoTexto =
      'Este distrito não está nos dados do app. Volte e escolha outro.';
  static String kpiUltimoMes(String mes) => 'Pedidos: $mes';
  static const kpiErroDistrito = 'Erro médio em pedidos';
  static const indicadorGraficoTitulo = 'Registros e previsão';
  static const indicadorGraficoSubtitulo =
      'A faixa sombreada é aproximada: 1,28 x RMSE do teste de 6 meses. É uma heurística que supõe erros parecidos com os do teste e mais ou menos simétricos. A cobertura real não foi medida; não é garantia.';
  static const backtestTitulo = 'Teste com meses anteriores';
  static const backtestSubtitulo =
      'De abril a setembro de 2026: cada previsão usou só os dados anteriores ao mês previsto.';
  static const colunaMes = 'Mês';
  static const colunaPrevisto = 'Previsto';
  static const colunaReal = 'Registrado';
  static const colunaErro = 'Erro';
  static String linhaBacktestSemantica(String mes, double previsto, int real) =>
      '$mes: ${inteiro(previsto)} ${inteiro(previsto) == '1' ? 'previsto' : 'previstos'}, ${inteiro(real)} ${inteiro(real) == '1' ? 'registrado' : 'registrados'}. Erro: ${comSinal(real - previsto, inteiro)} ${(real - previsto).abs().round() == 1 ? 'pedido' : 'pedidos'}.';
  static const categoriasTitulo = 'Tipos de pedido';
  static String categoriasDescricao(
    String distrito,
    List<(String, double)> itens,
  ) =>
      'Tipos de pedido em $distrito: ${itens.map((item) => '${item.$1}: ${percentual(item.$2)}').join('; ')}.';
  static const atendimentoTitulo = 'Atendidos por 10 mil habitantes';
  static const atendimentoDistrito = 'Neste distrito';
  static String atendimentoFaixa(FaixaRenda f) => switch (f) {
    FaixaRenda.baixa => 'Média da baixa renda',
    FaixaRenda.media => 'Média da renda média',
    FaixaRenda.alta => 'Média da alta renda',
  };
  static const subRegistroEstimado = 'Sub-registro estimado';
  static const indicadorAlertasTitulo = 'Alertas deste distrito';
  static const indicadorSemAlertasTexto =
      'Nenhum alerta ativo com os dados e limites atuais.';
  static const registrarNesteDistrito = 'Registrar neste distrito';

  static const painelClimaIntro =
      'Dados reais da Open-Meteo para um ponto no centro de São Paulo: últimos 30 dias e previsão de 7 dias. A chuva pode ser diferente no seu bairro.';
  static const atualizarClima = 'Atualizar clima';
  static String origemClima(
    OrigemClima o,
    DateTime quando,
    FalhaClima? falha,
  ) => switch (o) {
    OrigemClima.rede => 'Atualizado pela Open-Meteo em ${dataHora(quando)}.',
    OrigemClima.cache =>
      '${falha == null ? 'Dados salvos no aparelho.' : erroClima(falha)} Mostrando o último dado salvo em ${dataHora(quando)}.',
    OrigemClima.pacote =>
      '${falha == null ? 'Dados que vêm com o app.' : erroClima(falha)} Mostrando a cópia real de 16/11/2026 que vem com o app.',
  };
  static String kpiChuvaLimiar(int limiar, int probMax) =>
      'Limite: $limiar mm. Maior chance diária: $probMax%.';
  static const kpiChuva7Dias = 'Chuva nos últimos 7 dias';
  static const semComparacao = 'Sem base para comparar as semanas.';
  static String variacaoSemana(double variacao) => variacao == 0
      ? 'Sem variação frente aos 7 dias anteriores.'
      : '${comSinal(variacao, percentual)} frente aos 7 dias anteriores.';
  static const kpiTemperatura = 'Máxima de hoje';
  static String temperaturaDetalhe(double tmin) =>
      'Mínima de hoje: ${decimal(tmin)} °C.';
  static const climaChuvaTitulo = 'Chuva observada e prevista';
  static const climaChuvaSubtitulo =
      'Barras dos últimos 30 dias e dos próximos 7 dias. A previsão aparece em outra cor.';
  static String climaChuvaDescricao(
    double ultimos7,
    double proximos3,
    int diasHistorico,
    int diasPrevisao,
  ) =>
      'Chuva em $diasHistorico ${diasHistorico == 1 ? 'dia observado' : 'dias observados'} e $diasPrevisao ${diasPrevisao == 1 ? 'previsto' : 'previstos'}. Últimos 7 dias: ${decimal(ultimos7)} mm. Próximos 3 dias: ${decimal(proximos3)} mm.';
  static String chuvaPrevistaDescricao(double soma3Dias, int dias) =>
      'Previsão de ${decimal(soma3Dias)} mm somados em $dias ${dias == 1 ? 'dia' : 'dias'}.';
  static const legendaChuvaObservada = 'Observada';
  static const legendaChuvaPrevista = 'Prevista';
  static const climaTempTitulo = 'Temperatura';
  static String climaTempDescricao(double max, double min) =>
      'Temperaturas no período: maior máxima de ${decimal(max)} °C e menor mínima de ${decimal(min)} °C.';
  static const serieTempMax = 'Máxima';
  static const serieTempMin = 'Mínima';
  static const climaProximosTitulo = 'Previsão dos próximos dias';
  static String linhaPrevisaoDia(
    double chuva,
    int? prob,
    double tmin,
    double tmax,
  ) =>
      '${decimal(chuva)} mm; ${prob == null ? 'chance de chuva sem dado' : 'chance de chuva de $prob%'}; de ${decimal(tmin)} a ${decimal(tmax)} °C.';
  static const climaLimitacoesTitulo = 'Limites dos dados de clima';
  static const List<String> climaLimitacoes = [
    'Os dados representam um único ponto no centro de São Paulo, nas coordenadas -23,55 e -46,63.',
    'A chuva pode variar bastante entre bairros.',
    'A previsão fica menos confiável depois de 3 dias.',
    'Este painel não mede alagamentos.',
  ];

  static const painelEquidadeIntro =
      'Compare atendimentos por habitante e estimativas de problemas sem registro. Os dados são sintéticos e servem para explorar diferenças, sem descrever a situação real dos distritos.';
  static const socialTitulo = 'Diferença de atendimento';
  static const socialSubtitulo =
      'Alta renda menos baixa renda, por 10 mil habitantes por mês. Média dos últimos 3 meses.';
  static const socialDiferencaDetalhe =
      'Atendimentos por 10 mil habitantes por mês';
  static String socialGraficoDescricao(
    double baixa,
    double alta,
    double diferenca,
  ) =>
      'Atendimentos por 10 mil habitantes por mês: baixa renda ${decimal(baixa)}, alta renda ${decimal(alta)}. Diferença: ${decimal(diferenca)}. Média dos últimos 3 meses, com dados sintéticos.';
  static const socialComoLer =
      'A diferença cair só é boa notícia se o atendimento da baixa renda subir. Se cair porque a alta renda perdeu atendimento, não é melhora. Olhe a diferença junto com o valor da baixa renda. Os alertas podem ajudar a orientar vistorias onde há pouco registro; é uma hipótese a acompanhar.';
  static const subRegistroTitulo = 'Problemas sem registro';
  static String subRegistroSubtitulo(int amostraPct) =>
      'Estimativa com vistoria simulada em $amostraPct% das ruas.';
  static String subRegistroFaixasDescricao(
    double baixa,
    double media,
    double alta,
  ) =>
      'Sub-registro estimado: baixa renda ${percentual(baixa)}, renda média ${percentual(media)} e alta renda ${percentual(alta)}. Dados sintéticos.';
  static const subRegistroHistoricoDescricao =
      'Histórico da estimativa de sub-registro por faixa de renda. Dados sintéticos; valores maiores indicam uma parcela estimada maior de problemas sem registro.';
  static const subRegistroDistritosTitulo = 'Estimativa por distrito';
  static const subRegistroDistritosSubtitulo =
      'Últimos 3 meses. A margem aproxima a incerteza da amostra simulada, sem cobertura comprovada. Registros e achados vêm de processos separados.';
  static String subRegistroLinha(
    double estimativa,
    double margem,
    int achados,
    FaixaRenda f,
  ) =>
      '${percentual(estimativa)} estimados sem registro; margem de ${decimal(margem * 100)} ${decimal(margem * 100) == '1,0' ? 'ponto percentual' : 'pontos percentuais'}. ${inteiro(achados)} ${inteiro(achados) == '1' ? 'achado' : 'achados'} na amostra. ${faixa(f)}. Dados sintéticos.';
  static const equidadeLimitacoesTitulo = 'Limites desta comparação';
  static const List<String> equidadeLimitacoes = [
    'População, renda, pedidos e vistorias são sintéticos; só os nomes dos distritos são reais.',
    'A vistoria simulada cobre 10% das ruas. Uma amostra pequena aumenta a incerteza.',
    'A renda média do distrito esconde diferenças dentro dele.',
    'Quantidade de atendimentos não mede a qualidade do serviço.',
  ];

  static const alertasTitulo = 'Alertas';
  static const ajustarLimiares = 'Ajustar os limites dos alertas';
  static String alertasNovosAviso(int n) => n == 1
      ? 'Há 1 alerta novo para analisar.'
      : 'Há ${inteiro(n)} alertas novos para analisar.';
  static const alertasSemClima =
      'Sem dados de clima, o alerta de chuva fica desligado.';
  static String filtroTodos(int qtd) => '${qtd == 1 ? 'Todo' : 'Todos'} ($qtd)';
  static String filtroTipo(TipoAlerta t, int qtd) =>
      '${switch (t) {
        TipoAlerta.picoDemanda => 'Pico',
        TipoAlerta.quedaRegistro => 'Queda',
        TipoAlerta.chuvaForte => 'Chuva',
        TipoAlerta.ocorrenciasCidadao => qtd == 1 ? 'Ocorrência' : 'Ocorrências',
        TipoAlerta.subRegistro => 'Sub-registro',
      }} ($qtd)';
  static const soMeuDistrito = 'Só meu distrito';
  static const alertasVazioTitulo = 'Nenhum alerta ativo';
  static const alertasVazioTexto =
      'Os dados não atingiram os limites atuais. Isso não garante ausência de problemas.';
  static const alertasFiltroVazio = 'Nenhum alerta corresponde a este filtro.';
  static const alertaNovo = 'Novo';
  static const alertaComDecisao = 'Decisão registrada';

  static String alertaTitulo(TipoAlerta t) => switch (t) {
    TipoAlerta.picoDemanda => 'Pedidos acima do previsto',
    TipoAlerta.quedaRegistro => 'Registros abaixo do previsto',
    TipoAlerta.chuvaForte => 'Chuva forte prevista',
    TipoAlerta.ocorrenciasCidadao => 'Ocorrências no distrito',
    TipoAlerta.subRegistro => 'Possível sub-registro',
  };
  static String alertaResumo(Alerta a) => switch (a.tipo) {
    TipoAlerta.picoDemanda =>
      '${a.distrito.nome}: ${inteiro(a.valores['real']!)} ${inteiro(a.valores['real']!) == '1' ? 'registrado' : 'registrados'} e ${inteiro(a.valores['previsto']!)} ${inteiro(a.valores['previsto']!) == '1' ? 'previsto' : 'previstos'} (${comSinal(a.valores['desvioPct']!, inteiro)}%) em outubro. Dados sintéticos.',
    TipoAlerta.quedaRegistro =>
      '${a.distrito.nome}: ${inteiro(a.valores['real']!)} ${inteiro(a.valores['real']!) == '1' ? 'registrado' : 'registrados'} ante ${inteiro(a.valores['previsto']!)} ${inteiro(a.valores['previsto']!) == '1' ? 'previsto' : 'previstos'} (${inteiro(a.valores['desvioPct']!)}%). Pode haver menos problemas ou menos registros; dados sintéticos.',
    TipoAlerta.chuvaForte =>
      'Previsão de ${decimal(a.valores['chuva3DiasMm']!)} mm em 3 dias. Em ${a.distrito.nome}, ${inteiro(a.valores['bocaDeLoboPct']!)}% dos pedidos simulados são de boca de lobo.',
    TipoAlerta.ocorrenciasCidadao =>
      '${a.distrito.nome}: ${inteiro(a.valores['quantidade']!)} ${a.valores['quantidade'] == 1 ? 'ocorrência local' : 'ocorrências locais'} em 7 dias, sendo ${inteiro(a.valores['qtdCategoriaPrincipal']!)} de ${categoria(Categoria.values[a.valores['categoriaPrincipal']!.toInt()]).toLowerCase()}. Relatos não verificados.',
    TipoAlerta.subRegistro =>
      '${a.distrito.nome}: sub-registro estimado de ${inteiro(a.valores['estimativaPct']!)}%, com margem de ${inteiro(a.valores['margemPct']!)} ${inteiro(a.valores['margemPct']!) == '1' ? 'ponto percentual' : 'pontos percentuais'}. Dados sintéticos; vale avaliar uma vistoria.',
  };
  static List<String> alertaJustificativa(Alerta a) => switch (a.tipo) {
    TipoAlerta.picoDemanda || TipoAlerta.quedaRegistro => [
      'Último mês: ${inteiro(a.valores['real']!)} ${inteiro(a.valores['real']!) == '1' ? 'pedido registrado' : 'pedidos registrados'} e ${inteiro(a.valores['previsto']!)} ${inteiro(a.valores['previsto']!) == '1' ? 'previsto' : 'previstos'}.',
      'Desvio: ${comSinal(a.valores['desvioPct']!, inteiro)}%. Limite de ${a.tipo == TipoAlerta.picoDemanda ? 'alta' : 'queda'}: ${inteiro(a.valores['limiarPct']!)}%.',
      'Teste de ${inteiro(a.valores['mesesBacktest']!)} ${inteiro(a.valores['mesesBacktest']!) == '1' ? 'mês' : 'meses'}: erro médio de ${inteiro(a.valores['mae']!)} ${inteiro(a.valores['mae']!) == '1' ? 'pedido' : 'pedidos'} e erro percentual de ${inteiro(a.valores['mapePct']!)}%. Dados sintéticos.',
    ],
    TipoAlerta.chuvaForte => [
      'Chuva somada nos próximos 3 dias: ${decimal(a.valores['chuva3DiasMm']!)} mm. Limite: ${inteiro(a.valores['limiarMm']!)} mm.',
      'Maior probabilidade diária de chuva: ${inteiro(a.valores['probMaxPct']!)}%.',
      'Bocas de lobo representam ${inteiro(a.valores['bocaDeLoboPct']!)}% dos pedidos simulados. Seleção de até 3 distritos com maior proporção, a partir de 20%.',
    ],
    TipoAlerta.ocorrenciasCidadao => [
      '${inteiro(a.valores['quantidade']!)} ${a.valores['quantidade'] == 1 ? 'ocorrência' : 'ocorrências'} neste distrito nos últimos 7 dias. Limite: ${inteiro(a.valores['limiar']!)}.',
      'Tipo mais frequente: ${categoria(Categoria.values[a.valores['categoriaPrincipal']!.toInt()])}, com ${inteiro(a.valores['qtdCategoriaPrincipal']!)} ${inteiro(a.valores['qtdCategoriaPrincipal']!) == '1' ? 'registro' : 'registros'}.',
      'A contagem usa só os registros deste aparelho, sem verificação.',
    ],
    TipoAlerta.subRegistro => [
      'Sub-registro estimado: ${inteiro(a.valores['estimativaPct']!)}%, com margem de ${inteiro(a.valores['margemPct']!)} ${inteiro(a.valores['margemPct']!) == '1' ? 'ponto percentual' : 'pontos percentuais'} para mais ou para menos. Limite: ${inteiro(a.valores['limiarPct']!)}%.',
      '${inteiro(a.valores['achados']!)} ${inteiro(a.valores['achados']!) == '1' ? 'achado' : 'achados'} em vistoria simulada de ${inteiro(a.valores['amostraPct']!)}% das ruas.',
      '${inteiro(a.valores['registrados']!)} ${inteiro(a.valores['registrados']!) == '1' ? 'pedido registrado' : 'pedidos registrados'} nos últimos 3 meses. Todos estes dados são sintéticos.',
    ],
  };
  static String alertaConfiancaExplicacao(Alerta a) => switch (a.tipo) {
    TipoAlerta.picoDemanda || TipoAlerta.quedaRegistro =>
      '${confianca(a.confianca)}. MAPE: ${inteiro(a.valores['mapePct']!)}% (arredondado), média dos erros percentuais de cada mês no teste. Até 8%: alta; até 15%: média; acima: baixa. Os limites usam o valor sem arredondar. Cai um nível se o desvio for menor que 2 vezes o RMSE, que dá mais peso aos erros grandes.',
    TipoAlerta.chuvaForte =>
      '${confianca(a.confianca)}. A maior chance diária de chuva é ${inteiro(a.valores['probMaxPct']!)}%. A confiança é média a partir de 70% e baixa abaixo disso. Não indica certeza de chuva no distrito.',
    TipoAlerta.ocorrenciasCidadao =>
      '${confianca(a.confianca)}. ${a.valores['quantidade'] == 1 ? 'É' : 'São'} ${inteiro(a.valores['quantidade']!)} ${a.valores['quantidade'] == 1 ? 'ocorrência' : 'ocorrências'} em 7 dias. A confiança é média com 5 ou mais e baixa com menos. Os relatos não são verificados.',
    TipoAlerta.subRegistro =>
      'Confiança baixa: estimativa de ${inteiro(a.valores['estimativaPct']!)}% baseada em vistoria amostral simulada. Dados sintéticos não confirmam problemas reais no distrito.',
  };
  static List<String> alertaLimitacoes(TipoAlerta t) => switch (t) {
    TipoAlerta.picoDemanda => [
      'Os registros e a previsão usam dados sintéticos; não confirmam aumento real de problemas.',
      'Mais registros também podem refletir maior uso do canal de atendimento.',
      'Eventos fora do padrão e mudanças no canal podem reduzir a confiança na previsão.',
    ],
    TipoAlerta.quedaRegistro => [
      'Menos registros podem significar menos problemas ou dificuldade para registrar.',
      'Canal fora do ar ou desconfiança podem diminuir a procura, sem reduzir os problemas.',
      'Os dados são sintéticos. A queda não comprova melhora do serviço.',
    ],
    TipoAlerta.chuvaForte => [
      'O clima representa um único ponto da cidade; a chuva pode variar entre bairros.',
      'A previsão pode mudar e fica menos confiável depois de 3 dias.',
      'O app não mede alagamento. A proporção de pedidos de boca de lobo é sintética.',
    ],
    TipoAlerta.ocorrenciasCidadao => [
      'Os relatos não são verificados e podem ter spam ou duplicidade.',
      'Só entram os registros deste aparelho; eles não representam todos os moradores.',
      'Poucos registros não garantem que haja poucos problemas.',
    ],
    TipoAlerta.subRegistro => [
      'A estimativa usa dados sintéticos e não descreve a situação real do distrito.',
      'Uma vistoria amostral pequena pode não representar todas as ruas.',
      'A margem expressa incerteza da amostra, mas não cobre todos os vieses.',
    ],
  };
  static String alertaComoCalculado(TipoAlerta t) => switch (t) {
    TipoAlerta.picoDemanda => 'Comparamos os registros do último mês com a previsão: (registrados / previstos - 1) vezes 100. O alerta aparece ao atingir o limite de alta. A previsão usa só dados anteriores ao mês previsto.',
    TipoAlerta.quedaRegistro => 'Comparamos os registros do último mês com a previsão: (registrados / previstos - 1) vezes 100. O alerta aparece quando a queda atinge o limite. A previsão usa só o passado.',
    TipoAlerta.chuvaForte => 'Somamos a chuva prevista em 3 dias e comparamos com o limite. Selecionamos até 3 distritos com maior proporção de pedidos de boca de lobo, desde que ela seja de pelo menos 20%.',
    TipoAlerta.ocorrenciasCidadao => 'Contamos as ocorrências salvas neste aparelho no mesmo distrito nos últimos 7 dias. Ao atingir o limite, o app mostra um alerta para análise. Os relatos não são verificados.',
    TipoAlerta.subRegistro => 'Estimados = achados / 0,10. Sub-registro p = 1 - registrados / estimados. Margem = 1,96 x raiz(p(1-p)/achados). A margem aproxima a incerteza da amostra, sem cobertura comprovada: registros e achados vêm de processos separados. São estimativas com vistoria simulada, comparadas ao limite escolhido.',
  };
  static List<String> alertaSugestoes(TipoAlerta t) => switch (t) {
    TipoAlerta.picoDemanda => [
      'Pode valer conferir os tipos de pedido e possíveis mudanças no canal de registro.',
      'Uma pessoa pode considerar uma vistoria para entender o aumento antes de decidir.',
    ],
    TipoAlerta.quedaRegistro => [
      'Pode valer verificar se o canal de registro está acessível e funcionando.',
      'Uma vistoria pode ajudar a distinguir menos problemas de menos registros.',
    ],
    TipoAlerta.chuvaForte => [
      'O gestor pode considerar verificar bocas de lobo e avaliar limpeza preventiva antes da chuva.',
      'Pode valer consultar uma previsão atualizada antes de planejar qualquer ação.',
    ],
    TipoAlerta.ocorrenciasCidadao => [
      'Pode valer conferir se os relatos descrevem o mesmo problema ou registros repetidos.',
      'O gestor pode considerar uma vistoria para verificar os relatos.',
    ],
    TipoAlerta.subRegistro => [
      'Pode valer considerar uma vistoria onde há pouco registro, sem concluir que existam mais problemas.',
      'O gestor pode avaliar se há barreiras para os moradores registrarem pedidos.',
    ],
  };
  static const alertaTituloTela = 'Detalhe do alerta';
  static const alertaInativoTitulo = 'Este alerta não está mais ativo';
  static const alertaInativoTexto =
      'Os limites ou os dados mudaram e este alerta deixou de atender à regra.';
  static const justificativaTitulo = 'O que levou a este alerta';
  static const justificativaSubtitulo =
      'Confira os dados usados na comparação.';
  static const confiancaTitulo = 'Confiança no alerta';
  static const limitacoesTitulo = 'Limitações';
  static const comoCalculadoTitulo = 'Como foi calculado';
  static const sugestoesTitulo = 'O que considerar';
  static const sugestoesSubtitulo =
      'Sugestões para uma pessoa avaliar antes de agir.';
  static const verIndicadorDistrito = 'Ver dados do distrito';
  static const decisaoTitulo = 'Registrar minha decisão';
  static const decisaoSubtitulo =
      'Sua escolha fica só neste aparelho, para seu acompanhamento.';
  static String decisaoAtual(DecisaoHumana d, String quando) =>
      '${decisaoOpcao(d)}, registrada em $quando.';
  static String decisaoOpcao(DecisaoHumana d) => switch (d) {
    DecisaoHumana.vistoriar => 'Vistoriar',
    DecisaoHumana.monitorar => 'Monitorar',
    DecisaoHumana.descartar => 'Descartar',
  };
  static String decisaoSalva(DecisaoHumana d) =>
      'Decisão salva: ${decisaoOpcao(d).toLowerCase()}.';
  static const decisaoNota =
      'Registrar a decisão não envia equipe nem avisa pessoas ou órgãos.';

  static const registrarTitulo = 'Registrar ocorrência';
  static const registrarIntro =
      'Descreva um problema de zeladoria no distrito. O registro fica neste aparelho e pode compor um alerta local; não é enviado a um órgão público.';
  static const privacidadeFormTitulo = 'Cuide dos seus dados';
  static const List<String> privacidadeFormItens = [
    'Não escreva nome, contato nem endereço completo. A remoção automática pode falhar com nome ou endereço escrito de outro jeito.',
    'E-mail, telefone, CPF, placa, nome após "meu nome é", "me chamo" ou "sou" e número após nome de rua, quando identificados na descrição e na referência, são trocados por [removido].',
    'O registro fica só neste aparelho. Você pode apagá-lo.',
  ];
  static const campoCategoria = 'Tipo de problema';
  static const campoDescricao = 'Descrição';
  static String campoDescricaoAjuda(int min) =>
      'Conte o que aconteceu, com pelo menos $min ${min == 1 ? 'caractere' : 'caracteres'} e sem dados pessoais.';
  static const campoReferencia = 'Referência (opcional)';
  static const campoReferenciaAjuda =
      'Use um lugar conhecido, sem número de casa ou dados pessoais.';
  static const avisoDadoPessoal =
      'O texto parece conter dado pessoal. A remoção automática inclui nome após "meu nome é", "me chamo" ou "sou" e número após nome de rua, mas pode falhar com outra escrita. Só o trecho identificado vira [removido]. Não escreva nome, contato nem endereço completo.';
  static const registrarConsentimento =
      'Concordo em registrar esta ocorrência sem identificação pessoal.';
  static const registrarConsentimentoErro =
      'Marque o aceite para salvar a ocorrência.';
  static String registrarGatilho(int limiar) =>
      'Com $limiar ${limiar == 1 ? 'ocorrência' : 'ocorrências'} no distrito em 7 dias, o app gera um alerta local para análise do gestor.';
  static const registrarBotao = 'Salvar ocorrência';
  static const marcadorRemovido = '[removido]';
  static const ocorrenciaSalvaTitulo = 'Ocorrência salva no aparelho';
  static String ocorrenciaSalvaTexto(String id, String descricao) =>
      'Código anônimo: $id. Descrição salva: $descricao';
  static String ocorrenciaGerouAlerta(int n) => n == 1
      ? 'Este registro gerou 1 alerta local.'
      : 'Este registro gerou ${inteiro(n)} alertas locais.';
  static const apagarOcorrencia = 'Apagar ocorrência';
  static const erroDescricaoVazia = 'Descreva o problema.';
  static String erroDescricaoCurta(int min, int atual) =>
      'Use pelo menos $min ${min == 1 ? 'caractere' : 'caracteres'}. Você escreveu $atual.';
  static String erroDescricaoLonga(int max) =>
      'Use no máximo $max ${max == 1 ? 'caractere' : 'caracteres'} na descrição.';
  static const erroDescricaoSemPalavras =
      'Use palavras para descrever o problema.';
  static String erroReferenciaLonga(int max) =>
      'Use no máximo $max ${max == 1 ? 'caractere' : 'caracteres'} na referência.';

  static const ajustesTitulo = 'Ajustes';
  static const ajustesPerfilTitulo = 'Perfil de uso';
  static const ajustesPerfilSubtitulo = 'Escolha entre cidadão e gestor.';
  static const ajustesDistritoTitulo = 'Meu distrito';
  static const ajustesTemaTitulo = 'Aparência';
  static String ajustesLimiaresResumo(Limiares l) =>
      'Pico ${l.picoPercentual}%; queda ${l.quedaPercentual}%; chuva ${l.chuvaMm3Dias} mm/3 dias; ${l.ocorrencias7Dias} ${l.ocorrencias7Dias == 1 ? 'ocorrência' : 'ocorrências'}/7 dias; sub-registro ${l.subRegistroPercentual}%.';
  static const sobreDadosTitulo = 'Sobre os dados';
  static const sobreDadosResumo =
      'Fontes, cálculo das previsões e limites da análise.';
  static const privacidadeTitulo = 'Privacidade no aparelho';
  static const List<String> privacidadeItens = [
    'Ocorrências, decisões e preferências ficam só neste aparelho, sem envio a órgãos públicos.',
    'Não pedimos nome ou contato. O código é aleatório e o horário é arredondado para a hora cheia.',
    'E-mail, telefone, CPF, placa, nome após "meu nome é", "me chamo" ou "sou" e número após nome de rua, quando identificados na descrição e na referência, são trocados por [removido].',
    'A remoção automática pode falhar com nome ou endereço escrito de outro jeito. Não escreva nome, contato nem endereço completo.',
    'O consentimento fica salvo com data. Você pode apagar todos os dados a qualquer momento.',
  ];
  static const apagarDadosBotao = 'Apagar todos os dados';
  static const apagarDadosTitulo = 'Apagar os dados deste app?';
  static const apagarDadosTexto =
      'Serão apagados os registros, decisões, preferências, clima salvo e consentimento deste aparelho. Não dá para desfazer. O app volta à tela de consentimento.';
  static const apagarDadosConfirmar = 'Apagar tudo';

  static const limiaresTitulo = 'Limites dos alertas';
  static const limiaresIntro =
      'Ajuste quando cada alerta deve aparecer. Ao salvar, os alertas são recalculados na hora. Um limite menor gera mais alertas.';
  static const limiarPicoRotulo = 'Pico de pedidos (%)';
  static const limiarPicoAjuda =
      'De 5 a 100% acima do previsto. Quanto menor o valor, mais alertas de pico.';
  static const limiarQuedaRotulo = 'Queda de registros (%)';
  static const limiarQuedaAjuda =
      'De 5 a 90% abaixo do previsto. Quanto menor o valor, mais alertas de queda.';
  static const limiarChuvaRotulo = 'Chuva em 3 dias (mm)';
  static const limiarChuvaAjuda =
      'De 5 a 300 mm somados em 3 dias. Quanto menor o valor, mais alertas de chuva.';
  static const limiarOcorrenciasRotulo = 'Ocorrências em 7 dias';
  static const limiarOcorrenciasAjuda =
      'De 1 a 20 registros no distrito em 7 dias. Quanto menor o valor, mais alertas.';
  static const limiarSubRegistroRotulo = 'Sub-registro (%)';
  static const limiarSubRegistroAjuda =
      'De 20 a 95% estimados sem registro. Quanto menor o valor, mais alertas.';
  static const limiaresSalvar = 'Salvar limites';
  static const limiaresPadrao = 'Voltar ao padrão';
  static String limiaresSalvos(int novos, int sairam, int total) =>
      'Limites salvos. ${novos == 1 ? 'Novo' : 'Novos'}: $novos; ${sairam == 1 ? 'saiu' : 'saíram'}: $sairam; ${total == 1 ? 'ativo' : 'ativos'}: $total.';

  static const fontesTitulo = 'De onde vêm os dados';
  static List<String> fontes(int semente, int distritos, int meses) => [
    'Zeladoria sintética, gerada com semente $semente: $distritos ${distritos == 1 ? 'distrito' : 'distritos'} e $meses ${meses == 1 ? 'mês' : 'meses'}, de nov/2024 a out/2026. Só os nomes são reais; população, renda e séries são simuladas.',
    'Clima real da API Open-Meteo, sem chave: 30 dias anteriores e 7 previstos. Sem rede, usa dados salvos ou a cópia real de 16/11/2026 incluída no app.',
    'Ocorrências registradas neste aparelho por quem usa o app. Não são verificadas nem enviadas a órgãos públicos.',
  ];
  static const metricasTitulo = 'Como a previsão se saiu';
  static String metricasSubtitulo(int meses) =>
      'Teste de $meses ${meses == 1 ? 'mês' : 'meses'}, de abril a setembro de 2026, usando apenas o passado de cada mês.';
  static const metricaMae = 'Erro médio em pedidos (MAE)';
  static const metricaMape = 'Erro percentual (MAPE)';
  static String metricaMelhor(String nome) => 'Menor erro: $nome';
  static String metricaPior(String nome) => 'Maior erro: $nome';
  static const metricasComoLer =
      'MAE é o erro médio em pedidos por mês e distrito. MAPE é a média dos erros percentuais de cada mês: o erro absoluto dividido pelos pedidos registrados, vezes 100. O MAPE geral reúne os meses e distritos do teste. Quanto menores, melhor. No teste: 28,9 pedidos e 7,2%, sem garantia para meses futuros.';
  static const comoAlertasTitulo = 'Como surgem os alertas';
  static const List<String> comoAlertas = [
    'Pico: registros do último mês pelo menos 20% acima do previsto, no padrão.',
    'Queda: registros pelo menos 25% abaixo do previsto, no padrão. Pode haver menos problemas ou menos registros.',
    'Nos alertas de pico e queda, a confiança usa o MAPE, média dos erros percentuais de cada mês no teste: alta até 8%, média até 15% e baixa acima disso. Cai um nível se o desvio for menor que 2 vezes o RMSE.',
    'Chuva: pelo menos 40 mm em 3 dias, no padrão. Considera até 3 distritos com maior parcela de pedidos de boca de lobo, desde que ela seja de pelo menos 20%.',
    'Ocorrências: pelo menos 3 registros locais no mesmo distrito em 7 dias, no padrão. Não são verificados.',
    'Sub-registro: estimativa de pelo menos 60% sem registro, no padrão. Usa vistorias simuladas e tem confiança baixa. Os limites podem ser alterados em Ajustes.',
  ];
  static const viesesTitulo = 'O que pode distorcer a análise';
  static const List<String> vieses = [
    'Quem registra mais tende a aparecer mais nos dados.',
    'O modelo aprende o padrão de registro, não a quantidade real de problemas.',
    'Os dados sintéticos refletem as hipóteses que usamos para gerá-los.',
    'Ocorrências do app podem conter spam ou duplicidades.',
    'A renda média esconde diferenças entre pessoas e áreas do mesmo distrito.',
  ];
  static const naoConfiavelTitulo = 'Quando a previsão pode falhar';
  static const List<String> naoConfiavel = [
    'Com menos de 12 meses de histórico, não há base suficiente para a previsão.',
    'Enchentes grandes, greves e outros eventos fora do padrão podem mudar os pedidos.',
    'Mudanças ou falhas no canal de registro podem alterar os números.',
    'Distritos com poucos pedidos podem ter variações percentuais grandes.',
    'Previsões de chuva além de 3 dias têm mais incerteza.',
  ];
  static const acessibilidadeTitulo = 'Acessibilidade';
  static const List<String> acessibilidadeItens = [
    'Os gráficos têm descrições em texto para leitores de tela, como o TalkBack.',
    'Os botões têm área de toque de pelo menos 48 dp.',
    'O app oferece tema escuro e tema de alto contraste, com contraste testado.',
    'As telas permitem ampliar a fonte até 200%.',
  ];
}
