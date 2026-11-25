import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Kartu ringkasan statistik status produk.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int jumlah;
  final Color warna;
  final String? subtext;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.jumlah,
    required this.warna,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    // Responsivitas berbasis MediaQuery
    final isSmall = MediaQuery.of(context).size.width < 360;
    final padH = isSmall ? 8.0 : 12.0;
    final padV = isSmall ? 6.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warna.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTight = constraints.maxHeight < 90;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: isTight ? 28 : 34,
                    height: isTight ? 28 : 34,
                    decoration: BoxDecoration(
                      color: warna.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: warna,
                        size: isTight ? 15 : 18,
                      ),
                    ),
                  ),
                  if (subtext != null)
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: warna.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subtext!,
                          style: GoogleFonts.inter(
                            color: warna,
                            fontSize: isTight ? 9.0 : 10.0,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$jumlah',
                      style: GoogleFonts.inter(
                        color: AppTheme.textDark,
                        fontSize: isTight ? 18 : 22,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: AppTheme.textMedium,
                      fontSize: isTight ? 10.5 : 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
