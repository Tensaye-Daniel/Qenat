import 'package:flutter/material.dart';

import '../models/category.dart';

class QenatColors extends ThemeExtension<QenatColors> {
  const QenatColors({
    required this.scaffold,
    required this.surfaceCard,
    required this.surfaceField,
    required this.stoneCell,
    required this.outlineWarm,
    required this.ink,
    required this.inkFaded,
    required this.clay,
    required this.amber,
    required this.green,
    required this.danger,
  });

  factory QenatColors.standard() => const QenatColors(
        scaffold: Color(0xFFF6F0E3),
        surfaceCard: Color(0xFFFCF8EF),
        surfaceField: Color(0xFFFFFEF9),
        stoneCell: Color(0xFFE8DFC9),
        outlineWarm: Color(0xFFDDD2B8),
        ink: Color(0xFF2C261D),
        inkFaded: Color(0xFF7A7060),
        clay: _clayValue,
        amber: _amberValue,
        green: _greenValue,
        danger: Color(0xFF8E3B2E),
      );

  static const Color _clayValue = Color(0xFFA6503F);
  static const Color _amberValue = Color(0xFFD9992B);
  static const Color _greenValue = Color(0xFF2F6B4E);

  final Color scaffold;
  final Color surfaceCard;
  final Color surfaceField;
  final Color stoneCell;
  final Color outlineWarm;
  final Color ink;
  final Color inkFaded;
  final Color clay;
  final Color amber;
  final Color green;
  final Color danger;

  static const double streakThreshold = 0.8;

  static Color anchorForRate(double rate) {
    final t = rate.clamp(0.0, 1.0).toDouble();
    if (t <= 0.5) return Color.lerp(_clayValue, _amberValue, t * 2)!;
    return Color.lerp(_amberValue, _greenValue, (t - 0.5) * 2)!;
  }

  static Color fillForRate(double rate, {Color base = _cardFallback}) =>
      Color.lerp(base, anchorForRate(rate), 0.52)!;

  static const Color _cardFallback = Color(0xFFFCF8EF);

  Color colorForCategory(QenatCategory category) => switch (category) {
        QenatCategory.work => const Color(0xFF56708A),
        QenatCategory.health => const Color(0xFFBC6A50),
        QenatCategory.personal => const Color(0xFF9A7B4F),
        QenatCategory.learning => const Color(0xFF5E7D57),
      };

  @override
  QenatColors copyWith({
    Color? scaffold,
    Color? surfaceCard,
    Color? surfaceField,
    Color? stoneCell,
    Color? outlineWarm,
    Color? ink,
    Color? inkFaded,
    Color? clay,
    Color? amber,
    Color? green,
    Color? danger,
  }) {
    return QenatColors(
      scaffold: scaffold ?? this.scaffold,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceField: surfaceField ?? this.surfaceField,
      stoneCell: stoneCell ?? this.stoneCell,
      outlineWarm: outlineWarm ?? this.outlineWarm,
      ink: ink ?? this.ink,
      inkFaded: inkFaded ?? this.inkFaded,
      clay: clay ?? this.clay,
      amber: amber ?? this.amber,
      green: green ?? this.green,
      danger: danger ?? this.danger,
    );
  }

  @override
  QenatColors lerp(ThemeExtension<QenatColors>? other, double t) {
    if (other is! QenatColors) return this;
    return QenatColors(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceField: Color.lerp(surfaceField, other.surfaceField, t)!,
      stoneCell: Color.lerp(stoneCell, other.stoneCell, t)!,
      outlineWarm: Color.lerp(outlineWarm, other.outlineWarm, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkFaded: Color.lerp(inkFaded, other.inkFaded, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      green: Color.lerp(green, other.green, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is QenatColors &&
      other.scaffold == scaffold &&
      other.surfaceCard == surfaceCard &&
      other.surfaceField == surfaceField &&
      other.stoneCell == stoneCell &&
      other.outlineWarm == outlineWarm &&
      other.ink == ink &&
      other.inkFaded == inkFaded &&
      other.clay == clay &&
      other.amber == amber &&
      other.green == green &&
      other.danger == danger;

  @override
  int get hashCode => Object.hash(scaffold, surfaceCard, surfaceField,
      stoneCell, outlineWarm, Object.hash(ink, inkFaded, clay, amber, green, danger));
}
