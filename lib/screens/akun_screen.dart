import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produk_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class AkunScreen extends StatefulWidget {
  final UserModel? user;
  final List<Produk>? daftarProduk;

  const AkunScreen({super.key, this.user, this.daftarProduk});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  bool _isDeleting = false;
  bool get _isDark => themeNotifier.value == ThemeMode.dark;

  String _formatTanggalGabung(DateTime? date) {
    final d = date ?? DateTime(2024, 8, 15);
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: Text('Apakah Anda yakin ingin keluar dari akun "${widget.user?.nama ?? 'UseBy'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().signOut();
              // Routing: Kembali ke halaman login dan hapus seluruh stack riwayat navigasi
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.peachBlush,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapusAkun(BuildContext context) {
    final emailTarget = widget.user?.email ?? 'dewi@useby.app';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun Permanen'),
        content: Text(
          'Tindakan ini akan menghapus akun "$emailTarget" beserta seluruh data produk Anda secara permanen dan tidak dapat dibatalkan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _prosesHapusAkun(emailTarget);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesHapusAkun(String email) async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    final (success, errorMessage) = await AuthService().deleteAccount(email: email);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (!success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.peachBlush,
          behavior: SnackBarBehavior.floating,
          content: Text(errorMessage ?? 'Gagal menghapus akun. Silakan coba lagi.'),
        ),
      );
      return;
    }

    widget.daftarProduk?.clear();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryMint,
        behavior: SnackBarBehavior.floating,
        content: Text('Akun dan seluruh data Anda telah dihapus.'),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Penggunaan MediaQuery untuk responsivitas layout
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth >= 600;
    final isSmall = mediaQuery.size.width < 360;
    final horizontalPad = isSmall ? 14.0 : (isTablet ? 28.0 : 20.0);

    final namaUser = widget.user?.nama ?? 'Dewi Cantika';
    final emailUser = widget.user?.email ?? 'dewi@useby.app';
    final totalProduk = widget.daftarProduk?.length ?? 5;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 110),
              children: [
            // Header Akun
            Text(
              'Profil Pengguna',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Informasi akun dan pengaturan aplikasi',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textMedium,
              ),
            ),

            const SizedBox(height: 20),

            // Kartu Profil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.mintBorder.withValues(alpha: 0.5)),
                boxShadow: AppTheme.softShadow(),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.mintLight,
                      border: Border.all(color: AppTheme.primaryMint, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 36, color: AppTheme.primaryMint),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    namaUser,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emailUser,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryMint),
                        const SizedBox(width: 6),
                        Text(
                          'Bergabung sejak ${_formatTanggalGabung(widget.user?.tanggalBergabung)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ringkasan Cepat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.mintBorder.withValues(alpha: 0.5)),
                boxShadow: AppTheme.softShadow(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$totalProduk',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryMint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Produk',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                  Container(height: 28, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                  Column(
                    children: [
                      Text(
                        'Aktif',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryMint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status Akun',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Pengaturan & Menu
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.mintBorder.withValues(alpha: 0.5)),
                boxShadow: AppTheme.softShadow(),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        _isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        color: AppTheme.primaryMint,
                      ),
                      title: const Text('Mode Tampilan'),
                      subtitle: Text(_isDark ? 'Mode Gelap' : 'Mode Terang'),
                      trailing: Switch(
                        value: _isDark,
                        activeThumbColor: AppTheme.primaryMint,
                        onChanged: (val) {
                          themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                          setState(() {});
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    const ListTile(
                      leading: Icon(Icons.info_outline, color: AppTheme.primaryMint),
                      title: Text('Tentang UseBy'),
                      subtitle: Text('v1.0.0 • Pemrograman Aplikasi Perangkat Bergerak'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : () => _konfirmasiLogout(context),
                icon: const Icon(Icons.logout, color: AppTheme.peachBlush, size: 18),
                label: Text(
                  'Keluar dari Akun',
                  style: GoogleFonts.inter(
                    color: AppTheme.peachBlush,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.peachBlush),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Opsi Hapus Akun (subtil di bawah Logout, standar aplikasi mobile)
            Center(
              child: TextButton(
                onPressed: _isDeleting ? null : () => _konfirmasiHapusAkun(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMedium,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Hapus Akun',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMedium,
                        ),
                      ),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
