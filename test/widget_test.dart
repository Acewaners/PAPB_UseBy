import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proggress2/main.dart';
import 'package:proggress2/services/auth_service.dart';
import 'package:proggress2/theme/app_theme.dart';

void main() {
  setUp(() {
    AuthService().reset();
  });

  testWidgets('App loads Login Screen and successfully navigates',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verifikasi Layar Login terbuka
    expect(find.text('UseBy'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);

    // Coba masuk dengan akun yang sudah terdaftar secara asynchronous
    await tester.enterText(find.byType(TextFormField).at(0), 'dewi@useby.app');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Masuk'));

    // Tunggu simulasi asynchronous login selesai
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verifikasi Beranda terbuka dengan sambutan nama user
    expect(find.text('Halo, Dewi Cantika'), findsOneWidget);
    expect(find.text('Koleksi Produk'), findsOneWidget);

    // Direct flow: Klik kartu produk di Beranda langsung pindah ke Pantau
    await tester.tap(find.text('Moisturizer Ceramide Cream'));
    await tester.pumpAndSettle();
    expect(find.text('Pantau Produk'), findsOneWidget);
    expect(find.text('Produk Terpilih'), findsOneWidget);

    // Kembali ke Beranda
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Koleksi Produk'), findsOneWidget);

    // Navigasi ke Tab Pantau via Bottom Nav Bar
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Pantau Produk'), findsOneWidget);

    // Navigasi ke Tab Profil
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Profil Pengguna'), findsOneWidget);
    expect(find.text('Dewi Cantika'), findsOneWidget);

    // Scroll hingga Switch terlihat lalu toggle Mode Gelap
    final switchFinder = find.byType(Switch);
    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();

    expect(themeNotifier.value, ThemeMode.light);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(themeNotifier.value, ThemeMode.dark);

    // Toggle kembali ke Mode Terang
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    expect(themeNotifier.value, ThemeMode.light);
  });
}
