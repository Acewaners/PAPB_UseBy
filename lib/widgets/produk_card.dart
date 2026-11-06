import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produk_model.dart';
import '../theme/app_theme.dart';

/// Gaya warna, ikon, dan tema untuk tiap status produk.
class _CuteStatusConfig {
  final Color primaryColor;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final String title;

  const _CuteStatusConfig({
    required this.primaryColor,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.title,
  });
}

_CuteStatusConfig _getStatusConfig(StatusProduk status) {
  switch (status) {
    case StatusProduk.kedaluwarsa:
      return _CuteStatusConfig(
        primaryColor: const Color(0xFFFF5271),
        bgColor: AppTheme.peachLight,
        borderColor: AppTheme.peachBorder,
        icon: Icons.error_outline_rounded,
        title: 'Kedaluwarsa',
      );
    case StatusProduk.akanHabis:
      return _CuteStatusConfig(
        primaryColor: const Color(0xFFFF9F1C),
        bgColor: AppTheme.honeyLight,
        borderColor: AppTheme.honeyBorder,
        icon: Icons.access_time_rounded,
        title: 'Akan Habis',
      );
    case StatusProduk.aman:
      return _CuteStatusConfig(
        primaryColor: const Color(0xFF00C49F),
        bgColor: AppTheme.mintLight,
        borderColor: AppTheme.mintBorder,
        icon: Icons.check_circle_outline_rounded,
        title: 'Masih Aman',
      );
    case StatusProduk.belumLengkap:
      return _CuteStatusConfig(
        primaryColor: const Color(0xFF8B5CF6),
        bgColor: AppTheme.lavenderLight,
        borderColor: AppTheme.lavenderBorder,
        icon: Icons.info_outline_rounded,
        title: 'Belum Lengkap',
      );
  }
}

class ProdukCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback? onEdit;
  final VoidCallback? onHapus;
  final bool isHighlighted;

  const ProdukCard({
    super.key,
    required this.produk,
    this.onEdit,
    this.onHapus,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(produk.status);
    final progress = produk.rasioMasaPakai;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted
              ? AppTheme.primaryMint
              : statusConfig.borderColor.withValues(alpha: 0.9),
          width: isHighlighted ? 2.5 : 1.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppTheme.primaryMint.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.softShadow(color: statusConfig.primaryColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHighlighted)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C49F), Color(0xFF00B4D8)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Produk Terpilih',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            // Bagian Header Kartu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Kategori
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.mintBorder, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(
                        produk.kategoriIcon,
                        size: 24,
                        color: AppTheme.primaryMint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nama Produk & Kategori
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produk.nama,
                          style: GoogleFonts.nunito(
                            color: AppTheme.textDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.mintLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            produk.kategori,
                            style: GoogleFonts.nunito(
                              color: AppTheme.mintDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pill Badge Status Imut
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusConfig.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusConfig.icon,
                          size: 13,
                          color: statusConfig.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          produk.status == StatusProduk.belumLengkap
                              ? statusConfig.title
                              : produk.labelSisaHari,
                          style: GoogleFonts.nunito(
                            color: statusConfig.primaryColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Indikator Progress Masa Pakai
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sisa Masa Pakai',
                        style: GoogleFonts.nunito(
                          color: AppTheme.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        produk.status == StatusProduk.kedaluwarsa
                            ? 'Habis!'
                            : '${(progress * 100).toInt()}%',
                        style: GoogleFonts.nunito(
                          color: statusConfig.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 7,
                      color: AppTheme.surfaceMuted,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusConfig.primaryColor.withValues(alpha: 0.7),
                                statusConfig.primaryColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Grid Detail Info Masa Pakai (4 Kotak Mini Pastel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.mintBorder.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CuteInfoCell(
                            icon: Icons.calendar_today_outlined,
                            label: 'Kedaluwarsa',
                            value: formatTanggal(produk.tanggalKedaluwarsa),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppTheme.mintBorder.withValues(alpha: 0.7),
                        ),
                        Expanded(
                          child: _CuteInfoCell(
                            icon: Icons.event_available_outlined,
                            label: 'Tgl Dibuka',
                            value: formatTanggal(produk.tanggalDibuka),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        color: AppTheme.mintBorder.withValues(alpha: 0.7),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _CuteInfoCell(
                            icon: Icons.timelapse_outlined,
                            label: 'Durasi PAO',
                            value: produk.paoJumlah != null
                                ? '${produk.paoJumlah} ${produk.paoSatuan}'
                                : '-',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppTheme.mintBorder.withValues(alpha: 0.7),
                        ),
                        Expanded(
                          child: _CuteInfoCell(
                            icon: Icons.verified_outlined,
                            label: 'Batas Efektif',
                            value: formatTanggal(produk.batasEfektif),
                            isHighlight: true,
                            highlightColor: statusConfig.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Baris Tombol Aksi (Edit & Hapus)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  // Pesan status
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          statusConfig.icon,
                          size: 14,
                          color: statusConfig.primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            produk.statusDeskripsi,
                            style: GoogleFonts.nunito(
                              color: AppTheme.textMedium,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Edit
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.mintLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primaryMint.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 13,
                            color: AppTheme.mintDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: GoogleFonts.nunito(
                              color: AppTheme.mintDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tombol Hapus
                  InkWell(
                    onTap: onHapus,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.peachLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.peachBlush.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 13,
                            color: AppTheme.peachBlush,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hapus',
                            style: GoogleFonts.nunito(
                              color: AppTheme.peachBlush,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuteInfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;
  final Color? highlightColor;

  const _CuteInfoCell({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: AppTheme.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: AppTheme.textLight,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: isHighlight
                  ? (highlightColor ?? AppTheme.mintDark)
                  : AppTheme.textDark,
              fontSize: 12.5,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}