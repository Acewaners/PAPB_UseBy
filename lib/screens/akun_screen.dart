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
  String _waktuPagi = '07:00';
  String _waktuMalam = '21:00';

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

  void _dialogUbahWaktu() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Pengingat Rutinitas'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atur jadwal pengingat penggunaan produk:',
                  style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: AppTheme.surfaceMuted,
                  leading: const Icon(Icons.wb_sunny_outlined, color: AppTheme.honeyYellow),
                  title: Text(
                    'Rutinitas Pagi',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  trailing: Text(
                    _waktuPagi,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.mintDark,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 7, minute: 0),
                    );
                    if (picked != null) {
                      final formatted =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      setState(() => _waktuPagi = formatted);
                      setDialogState(() {});
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: AppTheme.surfaceMuted,
                  leading: const Icon(Icons.nightlight_round_outlined, color: AppTheme.skyBlue),
                  title: Text(
                    'Rutinitas Malam',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  trailing: Text(
                    _waktuMalam,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.mintDark,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 21, minute: 0),
                    );
                    if (picked != null) {
                      final formatted =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      setState(() => _waktuMalam = formatted);
                      setDialogState(() {});
                    }
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final namaUser = widget.user?.nama ?? 'Dewi Cantika';
    final emailUser = widget.user?.email ?? 'dewi@useby.app';
    final totalProduk = widget.daftarProduk?.length ?? 5;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
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
                  if (widget.user?.token != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.mintLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.mintBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 14, color: AppTheme.primaryMint),
                          const SizedBox(width: 6),
                          Text(
                            'Sesi Terverifikasi Cloud REST API',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mintDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      leading: const Icon(Icons.alarm, color: AppTheme.primaryMint),
                      title: const Text('Pengingat Rutinitas'),
                      subtitle: Text('Pagi: $_waktuPagi • Malam: $_waktuMalam'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _dialogUbahWaktu,
                    ),
                    const Divider(height: 1, indent: 56),
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
                onPressed: () => _konfirmasiLogout(context),
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
          ],
        ),
      ),
    );
  }
}
