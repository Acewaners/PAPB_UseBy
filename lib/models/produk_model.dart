import 'package:flutter/material.dart';

// Model data Produk untuk aplikasi UseBy
// Menyimpan informasi tanggal kedaluwarsa dan PAO (Period After Opening)

enum StatusProduk { kedaluwarsa, akanHabis, aman, belumLengkap }

class Produk {
  final String id;
  final String nama;
  final String kategori;
  final DateTime? tanggalKedaluwarsa;
  final DateTime? tanggalDibuka;
  final int? paoJumlah; // Satuan angka
  final String? paoSatuan; // "Hari", "Bulan", "Tahun"

  Produk({
    required this.id,
    required this.nama,
    required this.kategori,
    this.tanggalKedaluwarsa,
    this.tanggalDibuka,
    this.paoJumlah,
    this.paoSatuan,
  });

  DateTime? get tanggalKadaluarsa => tanggalKedaluwarsa;

  /// Batas pakai berdasarkan PAO (Tanggal dibuka + durasi PAO)
  DateTime? get batasBuka {
    if (tanggalDibuka == null || paoJumlah == null || paoSatuan == null) {
      return null;
    }
    switch (paoSatuan) {
      case 'Hari':
        return tanggalDibuka!.add(Duration(days: paoJumlah!));
      case 'Bulan':
        return DateTime(
          tanggalDibuka!.year,
          tanggalDibuka!.month + paoJumlah!,
          tanggalDibuka!.day,
        );
      case 'Tahun':
        return DateTime(
          tanggalDibuka!.year + paoJumlah!,
          tanggalDibuka!.month,
          tanggalDibuka!.day,
        );
      default:
        return null;
    }
  }

  /// Batas efektif = tanggal terdekat antara kedaluwarsa pabrik dan batas PAO
  DateTime? get batasEfektif {
    final bb = batasBuka;
    if (tanggalKedaluwarsa == null && bb == null) return null;
    if (tanggalKedaluwarsa == null) return bb;
    if (bb == null) return tanggalKedaluwarsa;
    return tanggalKedaluwarsa!.isBefore(bb) ? tanggalKedaluwarsa : bb;
  }

  /// Sisa hari dari hari ini sampai batas efektif
  int? get sisaHari {
    final batas = batasEfektif;
    if (batas == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final batasTanpaWaktu = DateTime(batas.year, batas.month, batas.day);
    return batasTanpaWaktu.difference(today).inDays;
  }

  StatusProduk get status {
    final adaKedaluwarsa = tanggalKedaluwarsa != null;
    final adaPao =
        tanggalDibuka != null && paoJumlah != null && paoSatuan != null;

    if (!adaKedaluwarsa && !adaPao) return StatusProduk.belumLengkap;

    final sisa = sisaHari;
    if (sisa == null) return StatusProduk.belumLengkap;
    if (sisa < 0) return StatusProduk.kedaluwarsa;
    if (sisa <= 7) return StatusProduk.akanHabis;
    return StatusProduk.aman;
  }

  /// Label ringkas sisa hari
  String get labelSisaHari {
    final sisa = sisaHari;
    if (sisa == null) return '-';
    if (sisa < 0) return '${sisa.abs()} hari lewat';
    if (sisa == 0) return 'Hari ini';
    return '$sisa hari lagi';
  }

  /// Icon sistem Material sesuai kategori produk
  IconData get kategoriIcon {
    final kat = kategori.toLowerCase();
    if (kat.contains('skin') || kat.contains('wajah') || kat.contains('pelembap')) {
      return Icons.spa_outlined;
    } else if (kat.contains('kosmetik') || kat.contains('makeup') || kat.contains('lip')) {
      return Icons.brush_outlined;
    } else if (kat.contains('makan') || kat.contains('minum') || kat.contains('susu')) {
      return Icons.local_dining_outlined;
    } else if (kat.contains('obat') || kat.contains('vitamin') || kat.contains('suplemen')) {
      return Icons.medication_outlined;
    }
    return Icons.inventory_2_outlined;
  }

  /// Icon sistem Material untuk status produk
  IconData get statusIcon {
    switch (status) {
      case StatusProduk.kedaluwarsa:
        return Icons.error_outline_rounded;
      case StatusProduk.akanHabis:
        return Icons.access_time_rounded;
      case StatusProduk.aman:
        return Icons.check_circle_outline_rounded;
      case StatusProduk.belumLengkap:
        return Icons.info_outline_rounded;
    }
  }

  String get kategoriEmoji => '';

  String get statusDeskripsi {
    switch (status) {
      case StatusProduk.kedaluwarsa:
        return 'Sudah kedaluwarsa';
      case StatusProduk.akanHabis:
        return 'Segera kedaluwarsa';
      case StatusProduk.aman:
        return 'Masih aman digunakan';
      case StatusProduk.belumLengkap:
        return 'Tanggal belum lengkap';
    }
  }

  /// Rasio sisa masa pakai (0.0 sampai 1.0)
  double get rasioMasaPakai {
    if (status == StatusProduk.kedaluwarsa) return 0.0;
    if (status == StatusProduk.belumLengkap) return 0.5;
    final batas = batasEfektif;
    if (batas == null) return 1.0;

    final awal = tanggalDibuka ?? batas.subtract(const Duration(days: 60));
    final totalDurasi = batas.difference(awal).inDays;
    final sisa = sisaHari ?? 0;

    if (totalDurasi <= 0) return 0.0;
    final rasio = sisa / totalDurasi;
    return rasio.clamp(0.0, 1.0);
  }
}

/// Helper format tanggal ke format Indonesia sederhana
String formatTanggal(DateTime? tanggal) {
  if (tanggal == null) return '-';
  const namaBulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${tanggal.day} ${namaBulan[tanggal.month]} ${tanggal.year}';
}
