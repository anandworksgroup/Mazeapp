import 'package:flutter/material.dart';

/// Menu colours. The game worlds bring their own palettes; this covers the
/// cards, buttons and text around them.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.card,
    required this.cardAlt,
    required this.outline,
    required this.ink,
    required this.subInk,
    required this.play,
    required this.playEdge,
    required this.orange,
    required this.pink,
    required this.blue,
    required this.purple,
    required this.yellow,
    required this.locked,
    required this.outlineWidth,
  });

  final Color card;
  final Color cardAlt;
  final Color outline;
  final Color ink;
  final Color subInk;
  final Color play;
  final Color playEdge;
  final Color orange;
  final Color pink;
  final Color blue;
  final Color purple;
  final Color yellow;
  final Color locked;
  final double outlineWidth;

  static const light = Palette(
    card: Color(0xFFFFF6E5),
    cardAlt: Color(0xFFFCE7C4),
    outline: Color(0xFF4A2E1F),
    ink: Color(0xFF4A2E1F),
    subInk: Color(0xFF8A6A55),
    play: Color(0xFF6BCB4B),
    playEdge: Color(0xFF3E8E2C),
    orange: Color(0xFFFF9F43),
    pink: Color(0xFFFF7AA2),
    blue: Color(0xFF4DB6F0),
    purple: Color(0xFFA880F0),
    yellow: Color(0xFFFFCB2F),
    locked: Color(0xFFBDB4AB),
    outlineWidth: 3,
  );

  static const dark = Palette(
    card: Color(0xFF2F2A3D),
    cardAlt: Color(0xFF3B3550),
    outline: Color(0xFF110D1A),
    ink: Color(0xFFFFF1DC),
    subInk: Color(0xFFC8B8D8),
    play: Color(0xFF5DBB3F),
    playEdge: Color(0xFF2F6E20),
    orange: Color(0xFFF08A2C),
    pink: Color(0xFFE9668F),
    blue: Color(0xFF3A9ED8),
    purple: Color(0xFF9570DB),
    yellow: Color(0xFFF2B917),
    locked: Color(0xFF6B6478),
    outlineWidth: 3,
  );

  static const highContrast = Palette(
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFFF3C4),
    outline: Color(0xFF000000),
    ink: Color(0xFF000000),
    subInk: Color(0xFF222222),
    play: Color(0xFF1E9E00),
    playEdge: Color(0xFF000000),
    orange: Color(0xFFFF8800),
    pink: Color(0xFFE0115F),
    blue: Color(0xFF0066DD),
    purple: Color(0xFF6A1BD6),
    yellow: Color(0xFFFFCC00),
    locked: Color(0xFF888888),
    outlineWidth: 4,
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}

ThemeData buildTheme({required bool dark, required bool highContrast}) {
  final p = highContrast
      ? Palette.highContrast
      : (dark ? Palette.dark : Palette.light);
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark && !highContrast ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.play,
      brightness: dark && !highContrast ? Brightness.dark : Brightness.light,
      surface: p.card,
    ),
  );
  return base.copyWith(
    extensions: [p],
    scaffoldBackgroundColor: p.card,
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink).copyWith(
          headlineLarge: base.textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w900, color: p.ink),
          titleLarge: base.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, color: p.ink),
          titleMedium: base.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: p.ink),
          bodyLarge: base.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600, color: p.ink),
          bodyMedium: base.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600, color: p.ink),
        ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: p.outline, width: p.outlineWidth),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.outline,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(
          color: p.card, fontWeight: FontWeight.w700, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
