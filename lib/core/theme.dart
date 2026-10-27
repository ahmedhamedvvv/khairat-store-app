import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Tokens shared by all three portfolio apps; only the palette differs per app.
abstract final class Tokens {
  static const cardRadius = 20.0;
  static const controlRadius = 14.0;
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const font = 'IBMPlexSansArabic';
}

/// Khairat palette: oud brown and gold on cream.
abstract final class Palette {
  static const oud = Color(0xFF4A2C21);
  static const oudDeep = Color(0xFF2E1A13);
  static const gold = Color(0xFFC9A35B);
  static const goldSoft = Color(0xFFF1E3C6);
  static const cream = Color(0xFFFBF6EE);
  static const sand = Color(0xFFF3EADC);
  static const ink = Color(0xFF2A1C16);
  static const muted = Color(0xFF8A7A70);
  static const success = Color(0xFF2F7D5B);
  static const danger = Color(0xFFB3412E);
  static const night = Color(0xFF15100D);
  static const nightSurface = Color(0xFF211915);
  static const nightCard = Color(0xFF2A211C);
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: dark ? Palette.gold : Palette.oud,
    onPrimary: dark ? Palette.oudDeep : Colors.white,
    primaryContainer: dark ? const Color(0xFF3A2A20) : Palette.goldSoft,
    onPrimaryContainer: dark ? Palette.goldSoft : Palette.oud,
    secondary: Palette.gold,
    onSecondary: Palette.oudDeep,
    tertiary: Palette.success,
    onTertiary: Colors.white,
    error: Palette.danger,
    onError: Colors.white,
    surface: dark ? Palette.night : Palette.cream,
    onSurface: dark ? const Color(0xFFF3ECE3) : Palette.ink,
    onSurfaceVariant: dark ? const Color(0xFFB7A99E) : Palette.muted,
    surfaceContainerLowest: dark ? Palette.nightSurface : Colors.white,
    surfaceContainerLow: dark ? Palette.nightCard : Colors.white,
    surfaceContainer: dark ? Palette.nightCard : Palette.sand,
    surfaceContainerHigh: dark ? const Color(0xFF332822) : const Color(0xFFEDE2D1),
    outline: dark ? const Color(0xFF4A3D35) : const Color(0xFFE2D6C4),
    outlineVariant: dark ? const Color(0xFF3A2F29) : const Color(0xFFEDE4D6),
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: Tokens.font, brightness: b);
  final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.controlRadius));

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: text.bodyMedium?.copyWith(height: 1.5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: Tokens.font, fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.cardRadius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: controlShape,
        textStyle: const TextStyle(fontFamily: Tokens.font, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: controlShape,
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(fontFamily: Tokens.font, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontFamily: Tokens.font, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.controlRadius),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: BorderSide(color: scheme.outline),
      labelStyle: TextStyle(fontFamily: Tokens.font, color: scheme.onSurface, fontWeight: FontWeight.w500),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: Tokens.font,
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? Palette.goldSoft : Palette.oudDeep,
      contentTextStyle: TextStyle(fontFamily: Tokens.font, color: dark ? Palette.oudDeep : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.controlRadius)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
