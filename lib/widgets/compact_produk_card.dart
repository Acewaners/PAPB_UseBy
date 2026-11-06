import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/produk_model.dart';
import '../theme/app_theme.dart';

/// Kartu produk ringkas untuk ditampilkan di halaman Beranda
class CompactProdukCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback? onTap;

  const CompactProdukCard({
    super.key,
    required this.produk,
    this.onTap,
  });

  Color _getStatusColor(StatusProduk status) {
    switch (status) {
      case StatusProduk.kedaluwarsa:
        return AppTheme.peachBlush;
      case StatusProduk.akanHabis:
        return AppTheme.honeyYellow;
      case StatusProduk.aman:
        return AppTheme.primaryMint;
      case StatusProduk.belumLengkap:
        return AppTheme.lavender;
    }
  }

  Color _getStatusBg(StatusProduk status) {
    switch (status) {
      case StatusProduk.kedaluwarsa:
        return AppTheme.peachLight;
      case StatusProduk.akanHabis:
        return AppTheme.honeyLight;
      case StatusProduk.aman:
        return AppTheme.mintLight;
      case StatusProduk.belumLengkap:
        return AppTheme.lavenderLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(produk.status);
    final statusBg = _getStatusBg(produk.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: AppTheme.softShadow(color: statusColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar Kategori
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.mintBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      produk.kategoriIcon,
                      size: 22,
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
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.mintLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                produk.kategori,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mintDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (produk.paoJumlah != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '• PAO ${produk.paoJumlah} ${produk.paoSatuan}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge Status & Indikator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            produk.status == StatusProduk.belumLengkap
                                ? 'Belum Lengkap'
                                : produk.labelSisaHari,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detail',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
