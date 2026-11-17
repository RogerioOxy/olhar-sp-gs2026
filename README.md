# Olhar SP

<img src="assets/icone.png" width="120">

Previsões e registros para cuidar dos distritos de São Paulo.

Aplicativo Android desenvolvido para a Global Solution 2026.2 da FIAP, na disciplina Cross-Platform Application Development. A proposta responde ao desafio Territory Predictive Insights: usar dados do território para ajudar uma pessoa a perceber problemas e decidir onde olhar antes que a demanda aumente.

## 2. Problema e público

Buracos, iluminação com defeito, necessidade de poda, entulho e bocas de lobo costumam virar pedidos quando já incomodam. Contar apenas reclamações deixa uma dúvida: um distrito registra pouco porque tem poucos problemas ou porque seus moradores registram menos?

O Olhar SP foi pensado para gestores públicos de zeladoria e cidadãos. O gestor encontra uma visão geral, previsões por distrito e alertas justificados. O cidadão usa Meu distrito para acompanhar previsões, consultar alertas e registrar uma ocorrência. O perfil é escolhido no consentimento e pode ser trocado no topo do Início ou em Ajustes.

A ideia é apoiar uma zeladoria que não espera a reclamação. O impacto social esperado é ajudar a direcionar a atenção também para territórios com pouco registro. O app combina demanda simulada, clima real e estimativas de sub-registro. Ele não envia equipe, não avisa ninguém e não dispara ação. A decisão final é humana.

## 3. Integrantes

Turma 2CCPW, 2º ano de Ciência da Computação.

| Nome completo | RM |
| --- | --- |
| Rogério Deligi Ferreira Filho | RM561942 |
| Maria Fernanda Garavelli Dantas | RM562686 |

## 4. Demonstração visual (obrigatório)

Os prints foram tirados no emulador Android em dois tamanhos de tela: celular de 1080x2340 e tablet de 1600x2560.

As imagens mostram as telas, a continuação dos painéis, validações, diálogos e temas. Os recortes complementares permitem ler gráficos e explicações abaixo da primeira área visível.

**Celular**

| Tela | Tela | Tela |
| --- | --- | --- |
| <img src="assets/screenshots/celular/01-consentimento.png" width="250"><br>Consentimento explícito, perfil e distrito. | <img src="assets/screenshots/celular/02-meu-distrito-cidadao.png" width="250"><br>Meu distrito: previsão e atendimento no Grajaú. | <img src="assets/screenshots/celular/03-visao-geral-gestor.png" width="250"><br>Visão geral: indicadores e aviso de decisão humana. |
| <img src="assets/screenshots/celular/04-paineis.png" width="250"><br>Acesso aos três painéis. | <img src="assets/screenshots/celular/05-painel-demanda.png" width="250"><br>Pedidos e previsão: indicadores da cidade. | <img src="assets/screenshots/celular/05b-painel-demanda-grafico.png" width="250"><br>Histórico de 24 meses e filtros por zona. |
| <img src="assets/screenshots/celular/06-indicador-distrito.png" width="250"><br>Dados de Grajaú com identificação de dados sintéticos. | <img src="assets/screenshots/celular/06b-indicador-grafico-backtest.png" width="250"><br>Faixa da previsão e teste de seis meses. | <img src="assets/screenshots/celular/07-alerta-detalhe.png" width="250"><br>Pico no Grajaú: confiança, justificativa e decisão humana. |
| <img src="assets/screenshots/celular/07b-alerta-limitacoes-decisao.png" width="250"><br>Cálculo, limitações e registro da decisão do gestor. | <img src="assets/screenshots/celular/08-painel-clima.png" width="250"><br>Clima real e chuva prevista nos próximos três dias. | <img src="assets/screenshots/celular/08b-painel-clima-graficos.png" width="250"><br>Chuva observada e prevista, temperaturas máxima e mínima. |
| <img src="assets/screenshots/celular/09-painel-equidade.png" width="250"><br>Indicador social: diferença de atendimento de 9,0. | <img src="assets/screenshots/celular/09b-painel-equidade-grafico.png" width="250"><br>Histórico e sub-registro estimado por faixa de renda. | <img src="assets/screenshots/celular/10-alertas.png" width="250"><br>Alertas com filtros e aviso de decisão humana. |
| <img src="assets/screenshots/celular/11-registrar-validacao.png" width="250"><br>Formulário com mensagens de validação. | <img src="assets/screenshots/celular/12-ajustes.png" width="250"><br>Ajustes de perfil, distrito e tema. | <img src="assets/screenshots/celular/13-limiares-alerta-ao-vivo.png" width="250"><br>Limites salvos: Novos: 3 e selo na aba Alertas. |
| <img src="assets/screenshots/celular/14-ocorrencia-gera-alerta.png" width="250"><br>Ocorrência anonimizada com [removido] gera um alerta. | <img src="assets/screenshots/celular/15-alerta-ocorrencia-cidadao.png" width="250"><br>Novo alerta de ocorrência com justificativa. | <img src="assets/screenshots/celular/16-sobre-os-dados.png" width="250"><br>Fontes dos dados e métricas MAE e MAPE. |
| <img src="assets/screenshots/celular/17-tema-alto-contraste.png" width="250"><br>Visão geral no tema de alto contraste. | <img src="assets/screenshots/celular/18-tema-escuro.png" width="250"><br>Painel de pedidos no tema escuro. |  |

**Tablet**

| Tela | Tela |
| --- | --- |
| <img src="assets/screenshots/tablet/t01-visao-geral-gestor.png" width="380"><br>Visão geral com indicadores em quatro colunas. | <img src="assets/screenshots/tablet/t02-paineis.png" width="380"><br>Três painéis lado a lado. |
| <img src="assets/screenshots/tablet/t03-painel-demanda.png" width="380"><br>Pedidos e previsão em tela larga. | <img src="assets/screenshots/tablet/t04-indicador-distrito.png" width="380"><br>Grajaú: gráfico e teste de seis meses. |
| <img src="assets/screenshots/tablet/t05-alerta-detalhe.png" width="380"><br>Detalhe do alerta no tablet. | <img src="assets/screenshots/tablet/t06-painel-clima.png" width="380"><br>Painel de clima no tablet. |
| <img src="assets/screenshots/tablet/t07-painel-equidade.png" width="380"><br>Atendimento e desigualdade no tablet. | <img src="assets/screenshots/tablet/t08-alertas.png" width="380"><br>Lista de alertas em tela larga. |
| <img src="assets/screenshots/tablet/t09-registrar.png" width="380"><br>Registro de ocorrência no tablet. |  |

## 5. Funcionalidades

- [x] Consentimento inicial com aceite e distrito obrigatório para cidadão.
- [x] Perfis cidadão e gestor, com Início adaptado à escolha.
- [x] Cinco abas inferiores e navegação com parâmetros entre painéis e alertas.
- [x] Pedidos e previsão: 24 meses registrados e previstos, próximo mês tracejado, indicadores e tendência mensal sem efeito da estação.
- [x] Ranking dos 16 distritos por desvio, com busca, filtro por zona e ordenação.
- [x] Dados do distrito com faixa de previsão e resultados do backtest.
- [x] Clima e zeladoria: chuva diária dos últimos 30 dias e previsão de sete dias em barras, temperaturas máxima e mínima em linhas.
- [x] Chuva dos próximos três dias e comparação com a semana anterior.
- [x] Atendimento e desigualdade: histórico de 24 meses, tendência e sub-registro por renda e distrito com margem.
- [x] Cinco tipos de alerta, filtros e detalhes com justificativa, confiança e limitações.
- [x] Registro local da decisão do gestor: Vistoriar, Monitorar ou Descartar. A decisão fica ligada à evidência do alerta; se os números mudarem, a decisão anterior não aparece como válida para o novo alerta.
- [x] Registro de ocorrência com validação, anonimização e abertura do alerta gerado.
- [x] Limites configuráveis com recálculo imediato e contagem de novos alertas.
- [x] Ajustes de distrito e tema, exclusão dos dados locais e tela Sobre os dados.
- [x] Estados de carregamento, erro com “Tentar de novo” e lista vazia.
- [x] Estado global compartilhado entre telas com provider.
- [x] Clima em cache para uso offline, com aviso de dado salvo e de previsão incompleta.
- [x] Persistência local de consentimento, perfil, distrito, tema, limites, ocorrências e decisões.
- [x] Descrições para leitor de tela com ação de toque nos cartões, fonte até 200%, alto contraste e tema escuro.
- [x] Layout em dois tamanhos de tela: celular e tablet.
- [x] Indicador de benefício social: diferença de atendimento entre alta e baixa renda, lida junto com o atendimento da baixa renda.

## 6. Dados e alertas

**Origem e recorte.** Os dados de zeladoria são sintéticos. O script `scripts/gerar_dados.py` usa a semente fixa `20261119`, produzindo o mesmo resultado a cada execução. São 24 meses, de novembro de 2024 a outubro de 2026. Cada mês contém pedidos registrados, atendidos e problemas encontrados numa vistoria amostral simulada de 10% das ruas.

Os nomes dos 16 distritos são reais: Jardim Ângela, Grajaú, Cidade Tiradentes, Brasilândia, Itaim Paulista, Parelheiros, Sapopemba, Penha, Santana, Butantã, Ipiranga, Moema, Pinheiros, Jardim Paulista, Perdizes e Vila Mariana. População, renda e séries são simuladas. A distribuição tem seis distritos de baixa renda, cinco de média e cinco de alta.

O gerador supõe mais problemas por habitante, menos registros e menos atendimento nos distritos de baixa renda. Também inclui sazonalidade de verão. Essas hipóteses ajudam a demonstrar o problema, mas não comprovam a situação real desses bairros. O painel de desigualdade exibe “Estimativa, dados sintéticos”.

O clima é real, consultado na API pública Open-Meteo, sem chave. A consulta usa um ponto no centro de São Paulo, latitude -23,55 e longitude -46,63. Isso não representa a chuva de cada distrito. Combinar as fontes não transforma a série sintética de zeladoria em dado observado.

**Previsão e avaliação.** Em `lib/domain/previsao.dart`, a previsão é o nível médio dos três meses anteriores, sem efeito sazonal, multiplicado pelo índice sazonal do mês previsto. O índice usa o total da cidade e somente meses anteriores à previsão. Há teste automatizado contra vazamento de futuro. O cálculo exige pelo menos 12 meses de histórico.

O backtest cobre seis meses, de abril a setembro de 2026. Cada previsão usa apenas o passado. O MAE médio é de 28,9 pedidos por mês por distrito. Ele expressa o tamanho médio do erro em pedidos. O MAPE geral é de 7,2%: a média dos erros percentuais de cada mês e distrito. Em cada ponto, dividimos o erro absoluto pelos pedidos registrados e multiplicamos por 100. Grajaú tem o menor MAPE, 4,0%, e Jardim Paulista o maior, 11,1%.

A faixa do próximo mês usa mais ou menos 1,28 x RMSE do teste de seis meses. O RMSE dá mais peso a erros grandes. A faixa é uma heurística, uma aproximação que supõe erros parecidos com os do teste e mais ou menos simétricos. Foi pensada para cobrir perto de 80% nessas condições, mas a cobertura real não foi medida e não há garantia do resultado futuro. Outubro de 2026 é o mês avaliado pelos alertas e fica fora do backtest.

**Regras dos alertas.** O arquivo `lib/domain/alertas.dart` recalcula os alertas quando mudam dados, limites ou ocorrências. Os padrões são:

| Tipo | Gatilho e interpretação |
| --- | --- |
| Pedidos acima do previsto | Desvio de pelo menos 20%. Confiança alta com MAPE até 8%, média até 15% e baixa acima disso. Cai um nível se o desvio for menor que 2 vezes o RMSE. Prioridade alta a partir de 40%. |
| Registros abaixo do previsto | Desvio de -25% ou menor. Pode significar menos problemas ou pessoas deixando de registrar. |
| Chuva forte prevista | Soma dos próximos três dias de pelo menos 40 mm. Destinada aos três distritos com maior proporção de pedidos de boca de lobo, desde que essa proporção seja de pelo menos 20%. Confiança média se a probabilidade máxima for pelo menos 70%; caso contrário, baixa. |
| Ocorrências no distrito | Pelo menos três ocorrências locais no mesmo distrito em sete dias. Confiança média com cinco ou mais; caso contrário, baixa. |
| Possível sub-registro | Estimativa de pelo menos 60%, sempre com confiança baixa. Usa a vistoria simulada para estimar problemas que não viraram registros. |

O sub-registro é `1 - registrados / (achados na vistoria / 0,10)`. A margem dessa estimativa é `1,96 x raiz(p(1-p)/achados)`, em que `p` é o sub-registro estimado. Ela só aproxima a incerteza da amostra, sem cobertura comprovada, porque registros e achados vêm de processos separados. A extrapolação depende da amostra simulada e não permite afirmar quantos problemas existem de verdade.

Com os limites padrão, em 16/11/2026 havia oito alertas: picos de Grajaú, +54%, e Penha, +47%, ambos com confiança alta; queda de Cidade Tiradentes, -34%; e cinco distritos de baixa renda com sub-registro entre 61% e 69%. Essa contagem é um retrato daquela data e configuração.

Cada detalhe apresenta resumo, justificativa numérica e gráfico, confiança explicada, limitações, cálculo e sugestões para avaliação. O aviso “A decisão é de uma pessoa” acompanha essa leitura. O gestor pode registrar sua decisão, mas ela fica apenas no aparelho e não aciona atendimento.

O recálculo também aparece durante o uso. Os alertas de ocorrências são recalculados sozinhos quando uma ocorrência completa sete dias com o app aberto e ao voltar para o app. No teste com pico em 10% e ocorrências em 1, salvar os limites gerou três novos alertas, totalizando 11, indicados por “Novos: 3” e pelo selo na aba Alertas. Quando uma ocorrência atinge o limite do distrito, o diálogo oferece “Ver alerta”. Isso demonstra uma atualização da análise, sem comunicação com equipes.

**Benefício social e limites.** O indicador social é a diferença de atendimentos por 10 mil habitantes entre alta e baixa renda. Na média dos últimos três meses, os valores exibidos são 24,8 e 15,9, com diferença de 9,0 por mês e queda de 3,4% ao mês nos últimos 12 meses. São resultados sintéticos; os valores apresentados estão arredondados.

Se a previsão e o alerta de sub-registro ajudarem a orientar vistorias para quem registra pouco, essa diferença pode cair. A queda só é boa notícia se acontecer porque o atendimento da baixa renda subiu. Cair porque a alta renda perdeu atendimento não é melhora. Por isso, é preciso olhar a diferença junto com o valor da baixa renda. Essa é a métrica para acompanhar um possível benefício, não uma promessa. Um MAPE menor melhora a referência de demanda, mas sozinho não demonstra atendimento mais justo.

As previsões não são confiáveis sem o histórico mínimo, diante de mudanças que o passado não representa ou quando o erro do distrito é alto. Também não se deve confiar em previsão de chuva vencida ou incompleta. Poucos registros podem distorcer a leitura da demanda. Ocorrências locais refletem somente quem usou aquele aparelho. O clima de um ponto pode divergir de outros bairros, e dados salvos podem estar desatualizados. Sem internet, os “últimos 7 dias” de um dado salvo antigo são os sete dias antes da data em que ele foi baixado; a faixa no topo do painel mostra a data desse dado. As hipóteses de renda e da amostra também introduzem vieses. Por isso, os alertas precisam ser confrontados com avaliação humana do território.

## 7. Privacidade e inclusão

O app não pede nome, telefone nem e-mail. Antes de salvar uma ocorrência, a anonimização troca os trechos identificados de e-mail, telefone, CPF, placa e número de casa por `[removido]`. Também identifica nome depois de “meu nome é”, “me chamo” ou “sou” e número depois de nome de rua: “Rua Alfa 123” vira “Rua Alfa [removido]”. Números seguidos de “de”, “da” ou “do” no nome da rua ficam iguais, como em “Rua 25 de Março”, e “Sou morador”, “Sou vizinho” e “Sou estudante” não são tratados como nome; a remoção pode falhar com nome todo em minúsculas, como “sou joao da silva”, ou endereço escrito de outro jeito. Por isso, não escreva nome, contato nem endereço completo. O registro recebe um código aleatório de 12 dígitos hexadecimais e horário arredondado para a hora cheia. O formulário avisa quando o texto parece conter dado pessoal. Depois de salvar, o diálogo mostra o texto exatamente como ficou guardado, e a pessoa pode apagar a ocorrência na lista.

Distrito e tipo são obrigatórios. A descrição precisa ter palavras e entre 15 e 280 caracteres. A referência aceita até 80 caracteres, e o aceite é obrigatório. Erros aparecem em vermelho. Limites dos alertas têm cinco campos numéricos com faixa validada.

Consentimento com data, perfil, distrito, tema, limites, ocorrências, decisões e cache do clima ficam no aparelho, em `shared_preferences`. Ajustes oferece “Apagar todos os dados”. A única chamada de rede é a consulta pública à Open-Meteo, sem dados do usuário. Os registros não são enviados a servidor.

Cada gráfico e cartão de alerta tem descrição textual com `Semantics`. Cartões tocáveis de alertas, painéis e indicadores e linhas de distrito também expõem a ação de toque ao leitor de tela. Os botões têm área mínima de 48 dp. Há temas claro, escuro e alto contraste. Em telas largas, o layout usa grades de duas a quatro colunas.

Os testes de widget verificam `meetsGuideline(androidTapTargetGuideline)`, `labeledTapTargetGuideline` e `textContrastGuideline` em celular 360x780 e tablet 800x1280. O teste com fonte em 200% agora abre os três painéis, o detalhe do distrito e o detalhe do alerta, sem quebra de layout. Um teste de semântica confirma que o cartão de alerta é exposto como botão com ação de toque. O emulador não tem TalkBack instalado. A checagem de leitor de tela foi feita pelos testes de semântica, sem validação manual com TalkBack.

## 8. Tecnologias e decisões técnicas

| Tecnologia | Escolha e motivo |
| --- | --- |
| Flutter 3.47.2 stable e Dart 3.13.2 | Interface mobile e regras de cálculo na mesma base. O app tem como alvo apenas Android e foi testado no emulador Android 14, API 34. |
| go_router 18.1.4 | Organiza rotas nomeadas, parâmetros e redirecionamento para consentimento. |
| provider 6.1.5+1 | Compartilha preferências e dados entre telas com cinco `ChangeNotifier` globais. |
| http 1.6.0 | Faz a consulta à Open-Meteo com tempo limite de 10 segundos. |
| shared_preferences 2.5.6 | Mantém escolhas, registros e cache localmente para continuidade do uso. |
| flutter_lints 6.0.0 | Ajuda a manter consistência e detectar problemas na análise estática. |
| CustomPaint e Container | Desenham gráficos sem biblioteca, como na aula 19. Evitam outra dependência e permitem controlar a descrição para leitor de tela. |
| Python | Gera dados reproduzíveis e o ícone por scripts. |

As versões das bibliotecas estão fixas no `pubspec.yaml`. A estrutura separa interface, acesso a dados e regras:

```text
lib/
  core/           tema, componentes, gráficos, validadores e formatação
  data/models/    modelos dos dados
  data/services/  JSON, Open-Meteo e armazenamento local
  domain/         previsão, backtest, equidade, alertas e anonimização
  state/          controladores do provider
  features/       telas por funcionalidade
  router/         rotas
test/             testes de unidade e widget
scripts/          geradores dos dados e do ícone
```

`core/textos.dart` reúne os textos da interface. Cores e espaçamentos padronizados ajudam a manter as telas consistentes. As regras em `domain/` são puras e testáveis, separadas dos widgets e dos serviços.

Os cinco controladores globais cuidam de preferências e limiares, território e previsões, clima, ocorrências e alertas. Trocar o perfil em Ajustes muda o Início. Novos alertas atualizam a lista e a barra. Busca, filtros, ordenação e campos de formulário usam estado local com `setState`.

Todas as rotas têm `name:` e a navegação usa `goNamed`. O `StatefulShellRoute` organiza cinco abas. O fluxo Visão geral → Dados do distrito → Detalhe do alerta usa `/paineis/demanda/:distritoId` e `/paineis/demanda/:distritoId/alerta/:alertaId`. Também existem `/alertas/:alertaId` e `/registrar?distrito=grajau`. Sem consentimento, ocorre redirecionamento para a primeira tela.

A resposta do clima fica salva no aparelho. Sem internet, o app mostra o último dado com aviso. No primeiro uso offline, usa `assets/dados/clima_snapshot.json`, uma cópia real baixada em 16/11/2026. Uma previsão vencida não vira chuva observada: o histórico só vai até o dia em que o dado foi baixado. Se faltarem dias para completar os três de previsão, o indicador mostra “sem dado” com aviso e não gera alerta de chuva. Se nenhuma fonte estiver disponível, mostra erro amigável. As demais funções continuam com dados locais.

## 9. Como executar

É necessário ter Flutter 3.47.2, Dart 3.13.2, Android SDK e um emulador ou celular Android disponível.

1. Clone o repositório, substituindo o marcador pelo endereço do projeto:

   ```bash
   git clone [LINK DO GITHUB]
   ```

2. Entre na pasta criada pelo clone. Ela tem o nome do repositório; ajuste o comando se o repositório tiver outro nome:

   ```bash
   cd olhar-sp
   ```

3. Instale as dependências:

   ```bash
   flutter pub get
   ```

4. Não há variáveis de ambiente para configurar. A Open-Meteo não usa chave e o projeto não precisa de arquivo `.env`.

5. Abra o emulador ou conecte o celular Android e execute:

   ```bash
   flutter run
   ```

6. Rode os testes e a análise estática:

   ```bash
   flutter test
   flutter analyze
   ```

A referência de qualidade do projeto é de 47 testes de unidade e widget passando e `flutter analyze` sem avisos. Esses testes cobrem regras e widgets; a limitação da checagem com leitor de tela está descrita na seção de inclusão.

Opcionalmente, com Python disponível, regenere o JSON com a mesma semente:

```bash
python scripts/gerar_dados.py
```

Para instalar diretamente, o APK `olhar-sp-v1.0.0.apk` está na aba Releases do repositório.

## 10. Vídeo

[LINK DO VÍDEO]

## 11. Licença

Projeto acadêmico, FIAP, Global Solution 2026.2. Disciplina Cross-Platform Application Development, desafio Territory Predictive Insights.
