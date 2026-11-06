import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'akun_screen.dart';
import 'beranda_screen.dart';
import 'pantau_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel? currentUser;

  const MainNavigationScreen({super.key, this.currentUser});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  String? _fokusProdukId;
  int _fokusToken = 0;

  // State Management menggunakan setState (Teknik Lifting State Up)
  // Data master produk disimpan di parent widget agar Beranda dan Pantau selalu sinkron
  late final List<Produk> _daftarProduk;

  @override
  void initState() {
    super.initState();
    // Akun demo bawaan (Dewi Cantika) memiliki 5 produk contoh agar dosen langsung melihat visual UI & status kedaluwarsa.
    // Jika akun baru hasil registrasi, list produk dimulai dari 0 (kosong).
    final isDemoAccount = widget.currentUser == null ||
        widget.currentUser?.email.trim().toLowerCase() == 'dewi@useby.app';

    if (isDemoAccount) {
      _daftarProduk = [
        Produk(
          id: '1',
          nama: 'Moisturizer Ceramide Cream',
          kategori: 'Skincare',
          tanggalKedaluwarsa: DateTime.now().add(const Duration(days: 120)),
          tanggalDibuka: DateTime.now().subtract(const Duration(days: 30)),
          paoJumlah: 6,
          paoSatuan: 'Bulan',
        ),
        Produk(
          id: '2',
          nama: 'Sunscreen Watery Gel SPF 50',
          kategori: 'Skincare',
          tanggalKedaluwarsa: DateTime.now().add(const Duration(days: 5)),
          tanggalDibuka: DateTime.now().subtract(const Duration(days: 175)),
          paoJumlah: 6,
          paoSatuan: 'Bulan',
        ),
        Produk(
          id: '3',
          nama: 'Matte Tint Lip Cream',
          kategori: 'Kosmetik',
          tanggalKedaluwarsa: DateTime.now().subtract(const Duration(days: 14)),
          tanggalDibuka: DateTime.now().subtract(const Duration(days: 400)),
          paoJumlah: 12,
          paoSatuan: 'Bulan',
        ),
        Produk(
          id: '4',
          nama: 'Susu Pasteurisasi Cokelat',
          kategori: 'Makanan & Minuman',
          tanggalKedaluwarsa: DateTime.now().add(const Duration(days: 3)),
          tanggalDibuka: DateTime.now().subtract(const Duration(days: 2)),
          paoJumlah: 4,
          paoSatuan: 'Hari',
        ),
        Produk(
          id: '5',
          nama: 'Vitamin C + Zinc Effervescent',
          kategori: 'Obat & Suplemen',
          tanggalKedaluwarsa: DateTime.now().add(const Duration(days: 240)),
          tanggalDibuka: null,
          paoJumlah: null,
          paoSatuan: null,
        ),
      ];
    } else {
      _daftarProduk = [];
    }
  }

  void _tambahProduk(Produk baru) {
    setState(() {
      _daftarProduk.insert(0, baru);
    });
  }

  void _hapusProduk(Produk p) {
    setState(() {
      _daftarProduk.remove(p);
    });
  }

  void _editProduk(int index, Produk p) {
    setState(() {
      _daftarProduk[index] = p;
    });
  }

  void _bukaPantauBiasa() {
    setState(() {
      _fokusProdukId = null;
      _selectedIndex = 1;
    });
  }

  // Alur aplikasi: Ketika produk diklik di Beranda, direct ke tab Pantau dan highlight produk tersebut
  void _bukaPantauDenganProduk(Produk produk) {
    setState(() {
      _fokusProdukId = produk.id;
      _fokusToken++;
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BerandaScreen(
        user: widget.currentUser,
        daftarProduk: _daftarProduk,
        onTambahProduk: _tambahProduk,
        onBukaPantau: _bukaPantauBiasa,
        onBukaDetailProduk: _bukaPantauDenganProduk,
      ),
      PantauScreen(
        daftarProduk: _daftarProduk,
        onHapusProduk: _hapusProduk,
        onEditProduk: _editProduk,
        fokusProdukId: _fokusProdukId,
        fokusToken: _fokusToken,
      ),
      AkunScreen(
        user: widget.currentUser,
        daftarProduk: _daftarProduk,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: UseByBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
