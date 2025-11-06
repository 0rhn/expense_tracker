import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6750A4),
      secondary: Color(0xFF625B71),
      tertiary: Color(0xFF7D5260),
      background: Color(0xFFFFFBFE),
      surface: Color(0xFFFFFBFE),
      error: Color(0xFFB3261E),
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFD0BCFF),
      secondary: Color(0xFFCCC2DC),
      tertiary: Color(0xFFEFB8C8),
      background: Color(0xFF1C1B1F),
      surface: Color(0xFF1C1B1F),
      error: Color(0xFFF2B8B5),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}