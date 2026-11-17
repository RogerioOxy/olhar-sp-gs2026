import 'package:flutter/material.dart';

class AppEspaco {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const larguraMaxima = 960.0;
  static const quebraTablet = 600.0;
}

class AppRaio {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
}

class AppCores {
  static const verdeZeladoria = Color(0xFF0B5D52);
  static const verdeEscuro = Color(0xFF063D36);
  static const verdeClaro = Color(0xFFD5EDE7);
  static const ambar = Color(0xFFB45F06);
  static const ambarClaro = Color(0xFFFCE8CC);
  static const vermelho = Color(0xFFB3261E);
  static const vermelhoClaro = Color(0xFFF9DEDC);
  static const azulDado = Color(0xFF1F5FAD);
  static const azulClaro = Color(0xFFDCE7F7);
  static const papel = Color(0xFFF6F4EE);
  static const tinta = Color(0xFF16201D);
  static const tintaSuave = Color(0xFF45524D);
  static const linha = Color(0xFFD3D8D2);
  static const noite = Color(0xFF0F1513);
  static const noiteCartao = Color(0xFF18211E);
}

@immutable
class CoresDoPainel extends ThemeExtension<CoresDoPainel> {
  const CoresDoPainel({
    required this.serieReal,
    required this.seriePrevista,
    required this.serieAuxiliar,
    required this.faixaPrevisao,
    required this.alertaAlta,
    required this.alertaAlerta,
    required this.alertaFundo,
    required this.altaFundo,
    required this.sintetico,
    required this.sinteticoFundo,
    required this.grade,
  });

  final Color serieReal;
  final Color seriePrevista;
  final Color serieAuxiliar;
  final Color faixaPrevisao;
  final Color alertaAlta;
  final Color alertaAlerta;
  final Color alertaFundo;
  final Color altaFundo;
  final Color sintetico;
  final Color sinteticoFundo;
  final Color grade;

  static CoresDoPainel de(BuildContext context) => Theme.of(context).extension<CoresDoPainel>()!;

  @override
  CoresDoPainel copyWith() => this;

  @override
  CoresDoPainel lerp(CoresDoPainel? other, double t) => t < 0.5 || other == null ? this : other;
}

const _painelClaro = CoresDoPainel(
  serieReal: AppCores.verdeZeladoria,
  seriePrevista: AppCores.ambar,
  serieAuxiliar: AppCores.azulDado,
  faixaPrevisao: Color(0x33B45F06),
  alertaAlta: AppCores.vermelho,
  alertaAlerta: AppCores.ambar,
  alertaFundo: AppCores.ambarClaro,
  altaFundo: AppCores.vermelhoClaro,
  sintetico: Color(0xFF5B3A8C),
  sinteticoFundo: Color(0xFFEDE4F7),
  grade: AppCores.linha,
);

const _painelEscuro = CoresDoPainel(
  serieReal: Color(0xFF7FD8C6),
  seriePrevista: Color(0xFFFFC27A),
  serieAuxiliar: Color(0xFF9CC2FF),
  faixaPrevisao: Color(0x40FFC27A),
  alertaAlta: Color(0xFFFFB4AB),
  alertaAlerta: Color(0xFFFFC27A),
  alertaFundo: Color(0xFF3A2A12),
  altaFundo: Color(0xFF4A1F1B),
  sintetico: Color(0xFFD7BCFF),
  sinteticoFundo: Color(0xFF2E2240),
  grade: Color(0xFF3A4541),
);

const _painelContraste = CoresDoPainel(
  serieReal: Colors.black,
  seriePrevista: Color(0xFF8A3B00),
  serieAuxiliar: Color(0xFF0033AA),
  faixaPrevisao: Color(0x408A3B00),
  alertaAlta: Color(0xFF8C0000),
  alertaAlerta: Color(0xFF6B3000),
  alertaFundo: Colors.white,
  altaFundo: Colors.white,
  sintetico: Color(0xFF3B0A78),
  sinteticoFundo: Colors.white,
  grade: Colors.black54,
);

class AppTheme {
  static ThemeData _base(ColorScheme esquema, CoresDoPainel painel, {bool contraste = false}) {
    final texto = Typography.material2021(platform: TargetPlatform.android).black.apply(
      bodyColor: esquema.onSurface,
      displayColor: esquema.onSurface,
    );
    final borda = contraste ? BorderSide(color: esquema.onSurface, width: 2) : BorderSide.none;
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      textTheme: texto.copyWith(
        headlineSmall: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: texto.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      extensions: [painel],
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: esquema.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRaio.md),
          side: contraste ? borda : BorderSide(color: esquema.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppEspaco.lg, vertical: AppEspaco.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRaio.sm)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: BorderSide(color: esquema.outline, width: contraste ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRaio.sm)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRaio.sm)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRaio.sm),
          borderSide: BorderSide(color: esquema.outline, width: contraste ? 2 : 1),
        ),
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRaio.lg)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surfaceContainer,
        indicatorColor: esquema.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerTheme: DividerThemeData(color: esquema.outlineVariant, space: AppEspaco.lg),
    );
  }

  static ThemeData claro() => _base(
    const ColorScheme(
      brightness: Brightness.light,
      primary: AppCores.verdeZeladoria,
      onPrimary: Colors.white,
      primaryContainer: AppCores.verdeClaro,
      onPrimaryContainer: AppCores.verdeEscuro,
      secondary: AppCores.ambar,
      onSecondary: Colors.white,
      secondaryContainer: AppCores.ambarClaro,
      onSecondaryContainer: Color(0xFF4A2600),
      tertiary: AppCores.azulDado,
      onTertiary: Colors.white,
      tertiaryContainer: AppCores.azulClaro,
      onTertiaryContainer: Color(0xFF0B2A52),
      error: AppCores.vermelho,
      onError: Colors.white,
      errorContainer: AppCores.vermelhoClaro,
      onErrorContainer: Color(0xFF410E0B),
      surface: AppCores.papel,
      onSurface: AppCores.tinta,
      onSurfaceVariant: AppCores.tintaSuave,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF1EFE8),
      surfaceContainer: Color(0xFFEBE9E2),
      surfaceContainerHigh: Color(0xFFE4E2DB),
      outline: Color(0xFF6F7A75),
      outlineVariant: AppCores.linha,
    ),
    _painelClaro,
  );

  static ThemeData escuro() => _base(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FD8C6),
      onPrimary: Color(0xFF00382F),
      primaryContainer: Color(0xFF0B5D52),
      onPrimaryContainer: Color(0xFFD5EDE7),
      secondary: Color(0xFFFFC27A),
      onSecondary: Color(0xFF4A2600),
      secondaryContainer: Color(0xFF6A3C00),
      onSecondaryContainer: Color(0xFFFCE8CC),
      tertiary: Color(0xFF9CC2FF),
      onTertiary: Color(0xFF0B2A52),
      tertiaryContainer: Color(0xFF1F4778),
      onTertiaryContainer: Color(0xFFDCE7F7),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppCores.noite,
      onSurface: Color(0xFFE3E8E5),
      onSurfaceVariant: Color(0xFFBFC9C4),
      surfaceContainerLowest: AppCores.noiteCartao,
      surfaceContainerLow: Color(0xFF151D1A),
      surfaceContainer: Color(0xFF1C2522),
      surfaceContainerHigh: Color(0xFF242E2B),
      outline: Color(0xFF89938F),
      outlineVariant: Color(0xFF3A4541),
    ),
    _painelEscuro,
  );

  static ThemeData altoContraste() => _base(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Colors.black,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFE600),
      onPrimaryContainer: Colors.black,
      secondary: Color(0xFF6B3000),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE600),
      onSecondaryContainer: Colors.black,
      tertiary: Color(0xFF0033AA),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE600),
      onTertiaryContainer: Colors.black,
      error: Color(0xFF8C0000),
      onError: Colors.white,
      errorContainer: Colors.white,
      onErrorContainer: Color(0xFF8C0000),
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.black,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Color(0xFFF0F0F0),
      outline: Colors.black,
      outlineVariant: Colors.black,
    ),
    _painelContraste,
    contraste: true,
  );
}
