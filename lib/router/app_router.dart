import 'package:go_router/go_router.dart';

import '../features/ajustes/ajustes_tela.dart';
import '../features/ajustes/limiares_tela.dart';
import '../features/ajustes/sobre_dados_tela.dart';
import '../features/alertas/alerta_detalhe_tela.dart';
import '../features/alertas/alertas_tela.dart';
import '../features/consentimento/consentimento_tela.dart';
import '../features/inicio/inicio_tela.dart';
import '../features/ocorrencia/registrar_tela.dart';
import '../features/paineis/indicador_detalhe_tela.dart';
import '../features/paineis/painel_clima_tela.dart';
import '../features/paineis/painel_demanda_tela.dart';
import '../features/paineis/painel_equidade_tela.dart';
import '../features/paineis/paineis_tela.dart';
import '../features/shell/casca.dart';
import '../state/controladores.dart';

/// Centraliza nomes para que as telas naveguem sem repetir caminhos.
class Rotas {
  static const consentimento = 'consentimento';
  static const inicio = 'inicio';
  static const paineis = 'paineis';
  static const painelDemanda = 'painelDemanda';
  static const indicador = 'indicador';
  static const alertaDoIndicador = 'alertaDoIndicador';
  static const painelClima = 'painelClima';
  static const painelEquidade = 'painelEquidade';
  static const alertas = 'alertas';
  static const alerta = 'alerta';
  static const registrar = 'registrar';
  static const ajustes = 'ajustes';
  static const limiares = 'limiares';
  static const sobreDados = 'sobreDados';
}

/// Reavalia o consentimento ao mudar preferências e preserva as pilhas das abas.
GoRouter criarRouter(PreferenciasController preferencias) {
  return GoRouter(
    initialLocation: '/inicio',
    refreshListenable: preferencias,
    redirect: (context, state) {
      final naTelaDeConsentimento = state.matchedLocation == '/consentimento';
      if (!preferencias.consentiu && !naTelaDeConsentimento) return '/consentimento';
      if (preferencias.consentiu && naTelaDeConsentimento) return '/inicio';
      return null;
    },
    routes: [
      GoRoute(
        path: '/consentimento',
        name: Rotas.consentimento,
        builder: (context, state) => const ConsentimentoTela(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacao) => Casca(navegacao: navegacao),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inicio',
                name: Rotas.inicio,
                builder: (context, state) => const InicioTela(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/paineis',
                name: Rotas.paineis,
                builder: (context, state) => const PaineisTela(),
                routes: [
                  GoRoute(
                    path: 'demanda',
                    name: Rotas.painelDemanda,
                    builder: (context, state) => PainelDemandaTela(zonaInicial: state.uri.queryParameters['zona']),
                    routes: [
                      GoRoute(
                        path: ':distritoId',
                        name: Rotas.indicador,
                        builder: (context, state) =>
                            IndicadorDetalheTela(distritoId: state.pathParameters['distritoId']!),
                        routes: [
                          GoRoute(
                            path: 'alerta/:alertaId',
                            name: Rotas.alertaDoIndicador,
                            builder: (context, state) =>
                                AlertaDetalheTela(alertaId: state.pathParameters['alertaId']!),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'clima',
                    name: Rotas.painelClima,
                    builder: (context, state) => const PainelClimaTela(),
                  ),
                  GoRoute(
                    path: 'equidade',
                    name: Rotas.painelEquidade,
                    builder: (context, state) => const PainelEquidadeTela(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alertas',
                name: Rotas.alertas,
                builder: (context, state) => const AlertasTela(),
                routes: [
                  GoRoute(
                    path: ':alertaId',
                    name: Rotas.alerta,
                    builder: (context, state) => AlertaDetalheTela(alertaId: state.pathParameters['alertaId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/registrar',
                name: Rotas.registrar,
                builder: (context, state) => RegistrarTela(distritoInicial: state.uri.queryParameters['distrito']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ajustes',
                name: Rotas.ajustes,
                builder: (context, state) => const AjustesTela(),
                routes: [
                  GoRoute(
                    path: 'limiares',
                    name: Rotas.limiares,
                    builder: (context, state) => const LimiaresTela(),
                  ),
                  GoRoute(
                    path: 'dados',
                    name: Rotas.sobreDados,
                    builder: (context, state) => const SobreDadosTela(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NaoEncontradaTela(),
  );
}
