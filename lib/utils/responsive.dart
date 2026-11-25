import 'package:flutter/material.dart';

/// Utilitas Responsif untuk Aplikasi UseBy
/// Menggunakan MediaQuery untuk mendeteksi dimensi layar, orientasi,
/// dan safe area secara dinamis di berbagai tipe perangkat (HP kecil, normal, besar, tablet).
class Responsive {
  /// Mengambil ukuran layar penuh (width & height)
  static Size size(BuildContext context) => MediaQuery.of(context).size;

  /// Lebar layar saat ini
  static double width(BuildContext context) => MediaQuery.of(context).size.width;

  /// Tinggi layar saat ini
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  /// Safe area padding atas (status bar / notch)
  static double paddingTop(BuildContext context) => MediaQuery.of(context).padding.top;

  /// Safe area padding bawah (gesture home bar)
  static double paddingBottom(BuildContext context) => MediaQuery.of(context).padding.bottom;

  /// View insets bawah (misalnya saat keyboard muncul)
  static double bottomInsets(BuildContext context) => MediaQuery.of(context).viewInsets.bottom;

  /// Deteksi orientasi layar apakah mendatar (landscape)
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Deteksi apakah HP berlayar kecil / ramping (lebar < 360px, misal: Galaxy Fold cover, iPhone SE 1st gen)
  static bool isSmallScreen(BuildContext context) => width(context) < 360;

  /// Deteksi apakah perangkat adalah HP standar (lebar < 600px)
  static bool isMobile(BuildContext context) => width(context) < 600;

  /// Deteksi apakah perangkat adalah tablet atau layar lebar (lebar >= 600px)
  static bool isTablet(BuildContext context) => width(context) >= 600;

  /// Deteksi apakah layar pendek secara vertikal (tinggi < 680px atau mode landscape)
  static bool isShortScreen(BuildContext context) =>
      height(context) < 680 || isLandscape(context);

  /// Padding horizontal dinamis berdasarkan lebar layar:
  /// - Layar kecil (< 360px) : 14px
  /// - HP standar (360 - 599px): 20px
  /// - Tablet (>= 600px)     : 28px
  static double horizontalPadding(BuildContext context) {
    final w = width(context);
    if (w < 360) return 14.0;
    if (w >= 600) return 28.0;
    return 20.0;
  }

  /// Jarak vertikal dinamis (SizedBox height) yang menyesuaikan tinggi layar
  static double spacing(
    BuildContext context, {
    double small = 8,
    double normal = 16,
    double large = 24,
  }) {
    if (isShortScreen(context)) return small;
    if (isTablet(context)) return large;
    return normal;
  }

  /// Jumlah kolom grid ringkasan statistik status:
  /// - Tablet / Layar lebar: 4 kolom
  /// - HP (portrait): 2 kolom
  static int statGridColumns(BuildContext context) {
    if (isTablet(context)) return 4;
    return 2;
  }

  /// Rasio aspek kartu statistik (childAspectRatio):
  /// - Tablet: 1.45 (lebih proporsional, tidak terlalu jangkung)
  /// - Layar kecil: 1.15 (memberi ruang tinggi lebih agar angka & teks tidak overflow)
  /// - HP standar: 1.25
  static double statCardAspectRatio(BuildContext context) {
    final w = width(context);
    if (w >= 600) return 1.45;
    if (w < 360) return 1.15;
    return 1.25;
  }
}

/// Widget pembungkus untuk membatasi lebar maksimal di layar lebar/tablet/landscape
/// Menjaga agar card dan formulir tetap berada di tengah (centered) dan nyaman dibaca.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 650,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
