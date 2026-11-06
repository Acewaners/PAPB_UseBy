import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pengontrol tema global (Light & Dark Mode)
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

/// Tema Aplikasi UseBy - Clean Material Design
class AppTheme {
  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  // Warna Utama
  static const Color primaryMint = Color(0xFF009688); // Teal Material
  static const Color primaryAccent = Color(0xFF00B4D8);

  // Mint varian adaptif
  static Color get mintDark =>
      isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B);
  static Color get mintLight =>
      isDark ? const Color(0xFF1B2E2B) : const Color(0xFFE0F2F1);
  static Color get mintBorder =>
      isDark ? const Color(0xFF2E4C47) : const Color(0xFFB2DFDB);

  // Latar Belakang & Permukaan
  static Color get scaffoldBg =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
  static Color get cardBg =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get surfaceMuted =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F5F4);

  // Warna Aksen & Status
  static const Color peachBlush = Color(0xFFE57373);
  static Color get peachLight =>
      isDark ? const Color(0xFF372224) : const Color(0xFFFFEBEE);
  static Color get peachBorder =>
      isDark ? const Color(0xFF5C3337) : const Color(0xFFFFCDD2);

  static const Color honeyYellow = Color(0xFFFFA000);
  static Color get honeyLight =>
      isDark ? const Color(0xFF382E16) : const Color(0xFFFFF8E1);
  static Color get honeyBorder =>
      isDark ? const Color(0xFF614E1F) : const Color(0xFFFFECB3);

  static const Color skyBlue = Color(0xFF0288D1);
  static Color get skyLight =>
      isDark ? const Color(0xFF162B36) : const Color(0xFFE1F5FE);
  static Color get skyBorder =>
      isDark ? const Color(0xFF274B5E) : const Color(0xFFB3E5FC);

  static const Color lavender = Color(0xFF7E57C2);
  static Color get lavenderLight =>
      isDark ? const Color(0xFF261D33) : const Color(0xFFEDE7F6);
  static Color get lavenderBorder =>
      isDark ? const Color(0xFF4A3866) : const Color(0xFFD1C4E9);

  // Tipografi adaptif
  static Color get textDark =>
      isDark ? const Color(0xFFECEFF1) : const Color(0xFF263238);
  static Color get textMedium =>
      isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A);
  static Color get textLight =>
      isDark ? const Color(0xFF78909C) : const Color(0xFF90A4AE);

  // Gradasi Bersih
  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF00ACC1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warmBannerGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF1E2827), Color(0xFF1E232B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFE0F2F1), Color(0xFFE1F5FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // Bayangan Halus Standar Material
  static List<BoxShadow> softShadow({Color? color, double spread = 0}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 8,
          spreadRadius: spread,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: 0.05),
        blurRadius: 10,
        spreadRadius: spread,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ThemeData Terang
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: const ColorScheme.light(
        primary: primaryMint,
        secondary: primaryAccent,
        surface: Color(0xFFFFFFFF),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF263238),
        displayColor: const Color(0xFF263238),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF263238)),
        titleTextStyle: TextStyle(
          color: Color(0xFF263238),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
    );
  }

  // ThemeData Gelap
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        secondary: primaryAccent,
        surface: Color(0xFF1E1E1E),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFFECEFF1),
        displayColor: const Color(0xFFECEFF1),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFECEFF1)),
        titleTextStyle: TextStyle(
          color: Color(0xFFECEFF1),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
    );
  }
}
