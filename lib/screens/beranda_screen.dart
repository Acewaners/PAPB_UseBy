import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produk_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/compact_produk_card.dart';

class BerandaScreen extends StatefulWidget {
  final UserModel? user;
  final List<Produk> daftarProduk;
  final Function(Produk) onTambahProduk;
  final VoidCallback onBukaPantau;
  final Function(Produk)? onBukaDetailProduk;

  const BerandaScreen({
    super.key,
    this.user,
    required this.daftarProduk,
    required this.onTambahProduk,
    required this.onBukaPantau,
    this.onBukaDetailProduk,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _kategoriList = [
    'Semua',
    'Skincare',
    'Kosmetik',
    'Makanan & Minuman',
    'Obat & Suplemen',
  ];

  List<Produk> get _filteredProduk {
    return widget.daftarProduk.where((p) {
      final cocokSearch =
          p.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.kategori.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!cocokSearch) return false;

      if (_selectedCategory == 'Semua') return true;
      final rawKat = _selectedCategory.replaceAll(RegExp(r'^[^\s]+\s'), '');
      return p.kategori.toLowerCase().contains(rawKat.toLowerCase());
    }).toList();
  }

  /// Dialog BottomSheet Tambah Produk dengan seluruh informasi lengkap sesuai kebutuhan
  void _showTambahDialog() {
    final namaController = TextEditingController();
    final paoJumlahController = TextEditingController(text: '6');
    String selectedSatuan = 'Bulan';
    String selectedKat = 'Skincare';
    DateTime? expDate;
    DateTime? openDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.mintBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tambah Produk Baru',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Input Nama Produk
                    Text(
                      'Nama Produk',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Moisturizer Ceramide',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Pilih Kategori
                    Text(
                      'Kategori',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedKat,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Skincare', child: Text('Skincare')),
                        DropdownMenuItem(value: 'Kosmetik', child: Text('Kosmetik')),
                        DropdownMenuItem(value: 'Makanan & Minuman', child: Text('Makanan & Minuman')),
                        DropdownMenuItem(value: 'Obat & Suplemen', child: Text('Obat & Suplemen')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedKat = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Tanggal Dibuka & Tanggal Kedaluwarsa (2 Kolom)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tgl Dibuka',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final pick = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                  );
                                  if (pick != null) {
                                    setModalState(() => openDate = pick);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        openDate == null ? 'Pilih Tgl' : formatTanggal(openDate),
                                        style: GoogleFonts.inter(
                                          color: openDate == null ? AppTheme.textLight : AppTheme.textDark,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Icon(Icons.event, size: 16, color: AppTheme.primaryMint),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tgl Kedaluwarsa',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final pick = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(const Duration(days: 180)),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                  );
                                  if (pick != null) {
                                    setModalState(() => expDate = pick);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        expDate == null ? 'Pilih Tgl' : formatTanggal(expDate),
                                        style: GoogleFonts.inter(
                                          color: expDate == null ? AppTheme.textLight : AppTheme.textDark,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryMint),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 4. Durasi PAO (Angka) & Satuan PAO (2 Kolom)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi PAO (Angka)',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: paoJumlahController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Misal: 6 atau 14',
                                  hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13),
                                  filled: true,
                                  fillColor: AppTheme.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Satuan PAO',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedSatuan,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppTheme.surfaceMuted,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Bulan', child: Text('Bulan')),
                                  DropdownMenuItem(value: 'Hari', child: Text('Hari')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedSatuan = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // 5. Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.trim().isEmpty) return;
                          final int? paoVal = int.tryParse(paoJumlahController.text.trim());

                          final produkBaru = Produk(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            nama: namaController.text.trim(),
                            kategori: selectedKat,
                            tanggalKedaluwarsa: expDate,
                            tanggalDibuka: openDate,
                            paoJumlah: paoVal,
                            paoSatuan: paoVal != null ? selectedSatuan : null,
                          );

                          // Memanggil setState di parent via callback
                          widget.onTambahProduk(produkBaru);

                          // Routing: Menutup modal bottom sheet
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryMint,
                              behavior: SnackBarBehavior.floating,
                              content: Text('Produk "${produkBaru.nama}" berhasil ditambahkan'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Simpan Produk',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jumlahAkanHabis = widget.daftarProduk
        .where((p) => p.status == StatusProduk.akanHabis)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      // Fitur Asynchronous pull-to-refresh
      body: RefreshIndicator(
        color: AppTheme.primaryMint,
        onRefresh: () async {
          // Simulasi proses async refresh data
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) setState(() {});
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            children: [
              // Header Profil Pengguna
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.user?.nama ?? 'Dewi'}',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pantau masa kedaluwarsa produk Anda',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.mintBorder),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: AppTheme.primaryMint),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Banner Ringkasan & Tombol Tambah Produk
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.mintGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow(color: AppTheme.primaryMint),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.daftarProduk.length} Produk Tercatat',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (jumlahAkanHabis > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.honeyYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$jumlahAkanHabis Segera Kedaluwarsa',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Punya produk yang baru dibuka?\nCatat masa simpannya sekarang.',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _showTambahDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Produk Baru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryMint,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== SEKSI PENCARIAN & FILTER ====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk atau kategori...',
                      hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.mintBorder.withValues(alpha: 0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.mintBorder.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter Kategori Horizontal
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _kategoriList.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final kat = _kategoriList[index];
                        final isSelected = _selectedCategory == kat;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = kat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryMint : AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryMint : AppTheme.mintBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                kat,
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.white : AppTheme.textDark,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================== SEKSI KOLEKSI PRODUK ====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Daftar Produk: Rata kiri dan kanan presisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Koleksi Produk',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.mintLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_filteredProduk.length}',
                              style: GoogleFonts.inter(
                                color: AppTheme.mintDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // TextButton tanpa padding/margin bawaan agar huruf terakhir 'a' sejajar border kotak
                      TextButton(
                        onPressed: widget.onBukaPantau,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryMint,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Daftar Produk Compact
                  if (_filteredProduk.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.mintBorder),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            'Tidak ada produk ditemukan',
                            style: GoogleFonts.inter(
                              color: AppTheme.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tekan tombol Tambah Produk Baru untuk mulai mencatat.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredProduk.map(
                      (produk) => CompactProdukCard(
                        produk: produk,
                        // Alur aplikasi: Klik produk di Beranda -> Langsung pindah ke halaman Pantau dan sorot produk ini!
                        onTap: () {
                          if (widget.onBukaDetailProduk != null) {
                            widget.onBukaDetailProduk!(produk);
                          } else {
                            widget.onBukaPantau();
                          }
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Tips Penggunaan PAO
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.mintBorder.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppTheme.honeyYellow, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tentang PAO (Period After Opening)',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PAO adalah masa simpan produk setelah kemasan dibuka untuk pertama kali.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMedium),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
