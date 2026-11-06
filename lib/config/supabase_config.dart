/// Konfigurasi Supabase untuk autentikasi dan database aplikasi UseBy
class SupabaseConfig {
  // Project URL dari Supabase
  static const String url = 'https://apckyvwinxtayhcdveut.supabase.co';

  // Publishable / Anon Key dari Supabase
  static const String anonKey = 'sb_publishable_P8vovyxthHCRYqpeDd_e7w_BoolrCeq';

  /// Status apakah Supabase.initialize() sudah selesai dijalankan
  static bool isInitialized = false;

  /// Memeriksa apakah konfigurasi kredensial Supabase sudah terisi
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_PROJECT_REF') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY');
}
