import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'qenat_colors.dart';

class AppTheme {
  static ThemeData light() {
    final c = QenatColors.standard();
    final scheme = ColorScheme.light(
      primary: c.green,
      onPrimary: const Color(0xFFFDF9EE),
      secondary: c.amber,
      onSecondary: c.ink,
      surface: c.surfaceCard,
      onSurface: c.ink,
      surfaceContainerHighest: c.stoneCell,
      outline: c.outlineWarm,
      error: c.danger,
      onError: const Color(0xFFFDF9EE),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.scaffold,
      extensions: [c],
      textTheme: _textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
            fontSize: 20, fontWeight: FontWeight.w600, color: c.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceCard,
        indicatorColor: c.green.withValues(alpha: 0.14),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? c.green
                  : c.inkFaded,
            )),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle:
            GoogleFonts.inter(color: const Color(0xFFF7F1E3), fontSize: 13.5),
        actionTextColor: const Color(0xFFF2C063),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceField,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        hintStyle: GoogleFonts.inter(color: c.inkFaded, fontSize: 14),
        border: _outline(c.outlineWarm),
        enabledBorder: _outline(c.outlineWarm),
        focusedBorder: _outline(c.green, width: 1.6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: GoogleFonts.fraunces(
            fontSize: 20, fontWeight: FontWeight.w600, color: c.ink),
      ),
      dividerTheme:
          DividerThemeData(color: c.outlineWarm.withValues(alpha: 0.7)),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
      timePickerTheme: TimePickerThemeData(backgroundColor: c.surfaceCard),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surfaceCard,
        headerForegroundColor: c.ink,
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  static TextTheme _textTheme() {
    TextStyle display(double size, [FontWeight w = FontWeight.w600]) =>
        GoogleFonts.fraunces(fontSize: size, fontWeight: w, height: 1.16);
    TextStyle body(double size, [FontWeight w = FontWeight.w400]) =>
        GoogleFonts.inter(fontSize: size, fontWeight: w, height: 1.35);

    return TextTheme(
      displayLarge: display(36),
      displayMedium: display(32),
      displaySmall: display(28),
      headlineMedium: display(24),
      headlineSmall: display(21),
      titleLarge: body(17, FontWeight.w600),
      titleMedium: body(15.5, FontWeight.w600),
      titleSmall: body(13.5, FontWeight.w600),
      bodyLarge: body(16),
      bodyMedium: body(14),
      bodySmall: body(12.5),
      labelLarge: body(13.5, FontWeight.w600),
      labelMedium: body(11.5, FontWeight.w600),
      labelSmall: body(10.5, FontWeight.w600),
    );
  }
}
