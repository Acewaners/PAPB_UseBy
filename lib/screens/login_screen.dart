import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dewi@useby.app');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi Asynchronous untuk memproses login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Set status loading untuk menampilkan CircularProgressIndicator
    setState(() => _isLoading = true);

    // Memanggil AuthService secara asynchronous (await Future)
    final (user, status) = await AuthService().login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (status == LoginStatus.emailBelumTerdaftar) {
      _tampilkanDialogBelumTerdaftar(email);
      return;
    }

    if (status == LoginStatus.passwordSalah) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.peachBlush,
          behavior: SnackBarBehavior.floating,
          content: Text('Email atau kata sandi salah. Silakan periksa kembali.'),
        ),
      );
      return;
    }

    if (status == LoginStatus.emailBelumDikonfirmasi) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.peachBlush,
          behavior: SnackBarBehavior.floating,
          content: Text('Email belum dikonfirmasi. Silakan buka email Anda atau matikan "Confirm email" di dashboard Supabase.'),
        ),
      );
      return;
    }

    if (status == LoginStatus.errorJaringan) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.peachBlush,
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal terhubung ke server autentikasi (Supabase). Silakan periksa koneksi internet Anda.'),
        ),
      );
      return;
    }

    debugPrint('✅ Login berhasil terverifikasi via Supabase Auth: Token=${user?.token}');

    // Routing: Mengganti halaman Login dengan MainNavigationScreen (pushReplacement)
    // Pengguna tidak dapat kembali ke login dengan tombol back HP
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationScreen(currentUser: user),
      ),
    );
  }

  void _tampilkanDialogBelumTerdaftar(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Akun Belum Terdaftar'),
        content: Text('Email "$email" belum terdaftar. Silakan buat akun terlebih dahulu.'),
        actions: [
          TextButton(
            // Routing Pop untuk menutup dialog
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Coba Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bukaHalamanRegister(prefillEmail: email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryMint,
              foregroundColor: Colors.white,
            ),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );
  }

  /// Routing: Menggunakan Navigator.push untuk membuka halaman registrasi
  Future<void> _bukaHalamanRegister({String? prefillEmail}) async {
    // Menunggu hasil kembalian dari halaman register (hasil pop)
    final registeredEmail = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(prefillEmail: prefillEmail),
      ),
    );

    if (registeredEmail != null && registeredEmail.isNotEmpty) {
      setState(() {
        _emailController.text = registeredEmail;
        _passwordController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.primaryMint,
            behavior: SnackBarBehavior.floating,
            content: Text('Pendaftaran berhasil! Silakan masuk dengan kata sandi Anda.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.mintLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.mintBorder, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.inventory_2_outlined, size: 36, color: AppTheme.primaryMint),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header Aplikasi
                  Text(
                    'UseBy',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pengingat Masa Pakai & Kedaluwarsa Produk',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Card Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.mintBorder.withValues(alpha: 0.6)),
                      boxShadow: AppTheme.softShadow(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk ke Akun',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Input Email
                        Text(
                          'Alamat Email',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'nama@email.com',
                            hintStyle: GoogleFonts.inter(color: AppTheme.textLight),
                            filled: true,
                            fillColor: AppTheme.surfaceMuted,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!val.contains('@')) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Input Password
                        Text(
                          'Kata Sandi',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Masukkan kata sandi',
                            hintStyle: GoogleFonts.inter(color: AppTheme.textLight),
                            filled: true,
                            fillColor: AppTheme.surfaceMuted,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Kata sandi wajib diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Tombol Submit dengan Asynchronous Loading
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryMint,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Informasi Akun Demo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.mintLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.mintBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryMint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Demo: dewi@useby.app / password123',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mintDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link ke Registrasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13),
                      ),
                      GestureDetector(
                        // Navigasi Push ke Registrasi
                        onTap: () => _bukaHalamanRegister(),
                        child: Text(
                          'Daftar di sini',
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryMint,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
