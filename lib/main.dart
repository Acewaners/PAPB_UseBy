import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase jika konfigurasi URL dan Anon Key sudah diisi
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      SupabaseConfig.isInitialized = true;
      debugPrint('✅ [Supabase] Berhasil terhubung ke Supabase Cloud!');
    } catch (e) {
      debugPrint('⚠️ [Supabase] Gagal inisialisasi Supabase: $e');
    }
  } else {
    debugPrint(
      'ℹ️ [Supabase] URL & Anon Key belum diisi di lib/config/supabase_config.dart. '
      'Menggunakan fallback demo lokal.',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'UseBy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          // Routing Awal: Halaman Login
          home: const LoginScreen(),
        );
      },
    );
  }
}
