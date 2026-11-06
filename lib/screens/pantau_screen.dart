import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produk_model.dart';
import '../theme/app_theme.dart';
import '../widgets/produk_card.dart';
import '../widgets/stat_card.dart';

class PantauScreen extends StatefulWidget {
  final List<Produk> daftarProduk;
  final Function(Produk) onHapusProduk;
  final Function(int, Produk) onEditProduk;
  final String? fokusProdukId;
  final int fokusToken;

  const PantauScreen({
    super.key,
    required this.daftarProduk,
    required this.onHapusProduk,
    required this.onEditProduk,
    this.fokusProdukId,
    this.fokusToken = 0,
  });

  @override
  State<PantauScreen> createState() => _PantauScreenState();
}

class _PantauScreenState extends State<PantauScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};
  String? _highlightedProdukId;
  int _lastHandledToken = -1;
  Timer? _highlightTimer;

  String _selectedCategory = 'Semua';

  final List<String> _kategoriList = [
    'Semua',
    'Skincare',
    'Kosmetik',
    'Makanan & Minuman',
    'Obat & Suplemen',
  ];

  GlobalKey _getKeyForProduk(String id) {
    return _cardKeys.putIfAbsent(id, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    if (widget.fokusProdukId != null && widget.fokusToken != _lastHandledToken) {
      _tanganiFokusProduk();
    }
  }

  @override
  void didUpdateWidget(covariant PantauScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fokusProdukId != null && widget.fokusToken != _lastHandledToken) {
      _tanganiFokusProduk();
    }
  }

  void _tanganiFokusProduk() {
    final targetId = widget.fokusProdukId;
    if (targetId == null) return;
    _lastHandledToken = widget.fokusToken;

    setState(() {
      _selectedCategory = 'Semua';
      _highlightedProdukId = targetId;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        _scrollToProduk(targetId);
      });
    });

    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _highlightedProdukId == targetId) {
        setState(() => _highlightedProdukId = null);
      }
    });
  }

  void _scrollToProduk(String targetId) {
    if (!_scrollController.hasClients) return;
    final cardContext = _cardKeys[targetId]?.currentContext;
    if (cardContext == null) return;

    final cardBox = cardContext.findRenderObject() as RenderBox?;
    final scrollableBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;

    if (cardBox != null && scrollableBox != null) {
      final cardOffsetInScrollable =
          cardBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
      final targetScrollOffset = (
        _scrollController.offset + cardOffsetInScrollable.dy - 16
      ).clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        targetScrollOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      Scrollable.ensureVisible(
        cardContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<Produk> get _filteredProduk {
    if (_selectedCategory == 'Semua') return widget.daftarProduk;
    final rawKat = _selectedCategory.replaceAll(RegExp(r'^[^\s]+\s'), '');
    return widget.daftarProduk
        .where((p) => p.kategori.toLowerCase().contains(rawKat.toLowerCase()))
        .toList();
  }

  void _konfirmasiHapus(Produk produk) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${produk.nama}" dari daftar pantauan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onHapusProduk(produk);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.peachBlush,
                  content: Text('${produk.nama} berhasil dihapus'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.peachBlush,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Produk produk) {
    final namaController = TextEditingController(text: produk.nama);
    final paoJumlahController = TextEditingController(
        text: produk.paoJumlah != null ? '${produk.paoJumlah}' : '');
    String selectedSatuan = produk.paoSatuan ?? 'Bulan';
    DateTime? openDate = produk.tanggalDibuka;
    DateTime? expDate = produk.tanggalKedaluwarsa;

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
                      'Edit Produk',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Produk
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

                    // Tanggal Dibuka & Kedaluwarsa
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tgl Dibuka',
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final pick = await showDatePicker(
                                    context: context,
                                    initialDate: openDate ?? DateTime.now(),
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
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
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
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final pick = await showDatePicker(
                                    context: context,
                                    initialDate: expDate ?? DateTime.now().add(const Duration(days: 180)),
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
                                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
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

                    // PAO
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi PAO (Angka)',
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: paoJumlahController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Misal: 6 atau 12',
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
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
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

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.trim().isEmpty) return;
                          final int? paoVal = int.tryParse(paoJumlahController.text.trim());

                          final index = widget.daftarProduk.indexOf(produk);
                          if (index != -1) {
                            final updated = Produk(
                              id: produk.id,
                              nama: namaController.text.trim(),
                              kategori: produk.kategori,
                              tanggalKedaluwarsa: expDate,
                              tanggalDibuka: openDate,
                              paoJumlah: paoVal,
                              paoSatuan: paoVal != null ? selectedSatuan : null,
                            );
                            widget.onEditProduk(index, updated);
                          }

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppTheme.primaryMint,
                              behavior: SnackBarBehavior.floating,
                              content: Text('Perubahan produk berhasil disimpan'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Simpan Perubahan'),
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
    final jumlahKedaluwarsa = widget.daftarProduk
        .where((p) => p.status == StatusProduk.kedaluwarsa)
        .length;
    final jumlahAkanHabis = widget.daftarProduk
        .where((p) => p.status == StatusProduk.akanHabis)
        .length;
    final jumlahAman =
        widget.daftarProduk.where((p) => p.status == StatusProduk.aman).length;
    final jumlahBelumLengkap = widget.daftarProduk
        .where((p) => p.status == StatusProduk.belumLengkap)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          key: _viewportKey,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pantau Produk',
                style: GoogleFonts.inter(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Detail status masa pakai dan kedaluwarsa produk',
                style: GoogleFonts.inter(
                  color: AppTheme.textMedium,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              // Grid Ringkasan Status
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Masih Aman',
                    jumlah: jumlahAman,
                    warna: AppTheme.primaryMint,
                    subtext: 'Aman',
                  ),
                  StatCard(
                    icon: Icons.access_time,
                    label: 'Segera Habis',
                    jumlah: jumlahAkanHabis,
                    warna: AppTheme.honeyYellow,
                    subtext: '< 7 Hari',
                  ),
                  StatCard(
                    icon: Icons.highlight_off,
                    label: 'Kedaluwarsa',
                    jumlah: jumlahKedaluwarsa,
                    warna: AppTheme.peachBlush,
                    subtext: 'Lewat',
                  ),
                  StatCard(
                    icon: Icons.pending_outlined,
                    label: 'Belum Lengkap',
                    jumlah: jumlahBelumLengkap,
                    warna: AppTheme.lavender,
                    subtext: 'Perlu Input',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Filter Kategori
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

              const SizedBox(height: 20),

              // Judul Daftar
              Row(
                children: [
                  Text(
                    'Daftar Produk',
                    style: GoogleFonts.inter(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

              const SizedBox(height: 12),

              // Daftar Kartu Produk
              if (_filteredProduk.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  margin: const EdgeInsets.only(top: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.mintBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 40, color: Colors.grey),
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
                        'Silakan pilih kategori lain atau tambah produk baru di Beranda.',
                        style: GoogleFonts.inter(color: AppTheme.textMedium, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ..._filteredProduk.map(
                  (produk) => Container(
                    key: _getKeyForProduk(produk.id),
                    child: ProdukCard(
                      produk: produk,
                      isHighlighted: _highlightedProdukId == produk.id,
                      onEdit: () => _showEditDialog(produk),
                      onHapus: () => _konfirmasiHapus(produk),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
