import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

enum LoginStatus {
  berhasil,
  emailBelumTerdaftar,
  passwordSalah,
  emailBelumDikonfirmasi,
  errorJaringan,
}

/// Service untuk mengelola autentikasi pengguna (Registrasi & Login)
/// Menggunakan Supabase Auth (PostgreSQL Cloud) secara asynchronous.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Daftar akun default untuk demonstrasi aplikasi / fallback offline
  final List<UserModel> _users = [
    UserModel(
      idUser: 1,
      nama: 'Dewi Cantika',
      email: 'dewi@useby.app',
      password: 'password123',
      tanggalBergabung: DateTime(2024, 8, 15),
      token: 'demo_token_dewi',
    ),
  ];

  List<UserModel> get registeredUsers => List.unmodifiable(_users);

  void reset() {
    _users.clear();
    _users.add(
      UserModel(
        idUser: 1,
        nama: 'Dewi Cantika',
        email: 'dewi@useby.app',
        password: 'password123',
        tanggalBergabung: DateTime(2024, 8, 15),
        token: 'demo_token_dewi',
      ),
    );
  }

  bool isEmailRegistered(String email) {
    final cleanEmail = email.trim().toLowerCase();
    return _users.any((u) => u.email.trim().toLowerCase() == cleanEmail);
  }

  UserModel? getUserByEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    try {
      return _users.firstWhere(
        (u) => u.email.trim().toLowerCase() == cleanEmail,
      );
    } catch (_) {
      return null;
    }
  }

  /// Registrasi user baru via Supabase Auth (atau fallback local in-memory)
  /// Asynchronous function menggunakan signUp()
  Future<String?> registerUser({
    required String nama,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Jika Supabase sudah dikonfigurasi dan diinisialisasi, jalankan Supabase Auth signUp
    if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
      try {
        final res = await Supabase.instance.client.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'nama': nama.trim()},
        );

        final supaUser = res.user;
        if (supaUser == null) {
          return 'Registrasi gagal. Silakan coba kembali.';
        }

        // Supabase mengembalikan identities kosong jika email sudah terdaftar sebelumnya
        if (supaUser.identities != null && supaUser.identities!.isEmpty) {
          return 'Email "$email" sudah terdaftar di Supabase. Silakan langsung masuk!';
        }

        debugPrint('✅ [Supabase Register Success]');
        debugPrint('   User ID : ${supaUser.id}');
        debugPrint('   Email   : ${supaUser.email}');

        // Simpan ke cache lokal agar langsung bisa diakses di sesi berjalan
        final newUser = UserModel(
          idUser: supaUser.id.hashCode.abs() % 100000,
          nama: nama.trim(),
          email: cleanEmail,
          password: password,
          tanggalBergabung: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
          token: res.session?.accessToken,
        );

        _users.removeWhere((u) => u.email.trim().toLowerCase() == cleanEmail);
        _users.add(newUser);

        return null;
      } on AuthException catch (e) {
        debugPrint('❌ [Supabase Register AuthException]: ${e.message}');
        final msg = e.message.toLowerCase();
        if (msg.contains('already registered') ||
            msg.contains('user already exists') ||
            msg.contains('already been registered')) {
          return 'Email "$email" sudah terdaftar di Supabase. Silakan langsung masuk!';
        }
        return e.message;
      } catch (e) {
        debugPrint('⚠️ [Supabase Register Network Error]: $e');
        return 'Gagal terhubung ke Supabase: $e';
      }
    }

    // 2. Fallback Mode (Jika kredensial Supabase belum diisi)
    if (isEmailRegistered(cleanEmail)) {
      return 'Email "$email" sudah terdaftar. Silakan langsung masuk!';
    }

    final newUser = UserModel(
      idUser: DateTime.now().millisecondsSinceEpoch % 100000,
      nama: nama.trim(),
      email: email.trim(),
      password: password,
      tanggalBergabung: DateTime.now(),
      token: 'local_token_mock',
    );

    _users.add(newUser);
    return null;
  }

  /// Login secara Asynchronous via Supabase Auth (atau fallback local in-memory)
  /// Menggunakan signInWithPassword()
  Future<(UserModel?, LoginStatus)> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Jika Supabase aktif dan diinisialisasi, jalankan autentikasi Supabase
    if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );

        final supaUser = res.user;
        final session = res.session;

        if (supaUser != null) {
          final userNama = (supaUser.userMetadata?['nama'] as String?)?.trim();
          final loggedUser = UserModel(
            idUser: supaUser.id.hashCode.abs() % 100000,
            nama: (userNama != null && userNama.isNotEmpty)
                ? userNama
                : cleanEmail.split('@').first,
            email: supaUser.email ?? cleanEmail,
            password: password,
            tanggalBergabung: DateTime.tryParse(supaUser.createdAt) ?? DateTime.now(),
            token: session?.accessToken ?? 'supabase_session_active',
          );

          _users.removeWhere((u) => u.email.trim().toLowerCase() == cleanEmail);
          _users.add(loggedUser);

          debugPrint('✅ [Supabase Login Success]');
          debugPrint('   User ID : ${supaUser.id}');
          debugPrint('   Email   : ${supaUser.email}');
          final tokenPreview = session?.accessToken != null && session!.accessToken.length >= 15
              ? '${session.accessToken.substring(0, 15)}...'
              : (session?.accessToken ?? '-');
          debugPrint('   Token   : $tokenPreview');

          return (loggedUser, LoginStatus.berhasil);
        }
      } on AuthException catch (e) {
        debugPrint('❌ [Supabase Login AuthException]: ${e.message}');
        final msg = e.message.toLowerCase();

        // Dukungan untuk akun demonstrasi jika belum di-input ke Supabase
        if (cleanEmail == 'dewi@useby.app' && password == 'password123') {
          final demoUser = getUserByEmail(cleanEmail);
          if (demoUser != null) {
            return (demoUser.copyWith(token: 'demo_token_dewi'), LoginStatus.berhasil);
          }
        }

        if (msg.contains('invalid login credentials') ||
            msg.contains('invalid credentials')) {
          return (null, LoginStatus.passwordSalah);
        } else if (msg.contains('email not confirmed')) {
          debugPrint('⚠️ Email belum dikonfirmasi di Supabase.');
          return (null, LoginStatus.emailBelumDikonfirmasi);
        }
        return (null, LoginStatus.errorJaringan);
      } catch (e) {
        debugPrint('⚠️ [Supabase Login Error]: $e');
        // Fallback akun demo jika jaringan bermasalah
        if (cleanEmail == 'dewi@useby.app' && password == 'password123') {
          final demoUser = getUserByEmail(cleanEmail);
          if (demoUser != null) {
            return (demoUser.copyWith(token: 'offline_token_demo'), LoginStatus.berhasil);
          }
        }
        return (null, LoginStatus.errorJaringan);
      }
    }

    // 2. Fallback Mode (Jika kredensial Supabase belum diisi)
    final user = getUserByEmail(cleanEmail);
    if (user == null) {
      return (null, LoginStatus.emailBelumTerdaftar);
    }
    if (user.password != password) {
      return (null, LoginStatus.passwordSalah);
    }

    return (user.copyWith(token: 'local_token_mock'), LoginStatus.berhasil);
  }

  /// Sign out pengguna dari Supabase
  Future<void> signOut() async {
    if (SupabaseConfig.isConfigured && SupabaseConfig.isInitialized) {
      try {
        await Supabase.instance.client.auth.signOut();
        debugPrint('✅ [Supabase SignOut Success]');
      } catch (e) {
        debugPrint('⚠️ [Supabase SignOut Error]: $e');
      }
    }
  }
}
