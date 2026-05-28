import 'dart:convert';
import 'package:http/http.dart' as http;

// Model Data disesuaikan dengan key dari Laravel (PascalCase untuk Nama_Barang, Harga, dll)
class PostTransaksipemasukanbarang {
  final int? id;
  final String Nama_Barang;
  final String Harga;
  final String Jumlah;
  final String jenis_barang;
  final String jenis_transaksi;
  final DateTime? Tanggal;

  PostTransaksipemasukanbarang({
    this.id,
    required this.Nama_Barang,
    required this.Harga,
    required this.Jumlah,
    required this.jenis_barang,
    required this.jenis_transaksi,
    this.Tanggal,
  });

  factory PostTransaksipemasukanbarang.fromJson(Map<String, dynamic> json) {
    return PostTransaksipemasukanbarang(
      id: json['id'],
      // Mengambil data dari key yang dikirim Laravel
      Nama_Barang: json['nama_barang'] ?? json['Nama_Barang'] ?? '',
      Harga: json['harga']?.toString() ?? json['Harga']?.toString() ?? '0',
      Jumlah: json['jumlah']?.toString() ?? json['Jumlah']?.toString() ?? '0',
      jenis_barang: json['jenis_barang'] ?? '',
      jenis_transaksi: json['jenis_transaksi'] ?? '',
      Tanggal: json['tanggal'] != null ? DateTime.parse(json['tanggal']) : null,
    );
  }
}

class Apitransaksi {
  final String baseUrl = "http://192.168.1.9:8000/api";

  // Ambil Data Transaksi
  Future<Map<String, dynamic>> fetchTransaksi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transaksi'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<PostTransaksipemasukanbarang> list = (data['data'] as List)
            .map((json) => PostTransaksipemasukanbarang.fromJson(json))
            .toList();
        return {'transaksi': list};
      }
      throw Exception("Gagal load data");
    } catch (e) {
      rethrow;
    }
  }

  // Simpan Transaksi Baru
  // Tambahkan parameter deskripsi dan nama_supplier agar lengkap sesuai Controller
  Future<bool> insertTransaksi(
    String nama, 
    String harga, 
    String jumlah, 
    String tanggal, 
    String jenisbarang, 
    String jenistransaksi, 
    String supplier, 
    String deskripsi
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaksi'), // Pastikan endpoint sesuai routes/api.php
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          // KEY HARUS SAMA DENGAN VALIDASI DI LARAVEL (Kapital)
          'Nama_Barang': nama,
          'Harga': harga,
          'Jumlah': jumlah,
          'Tanggal': tanggal,
          'jenis_barang': jenisbarang,
          'jenis_transaksi': jenistransaksi,
          'nama_supplier': supplier,
          'deskripsi': deskripsi,
        }),
      );

      print("STATUS UTAMA: ${response.statusCode}");
      print("BODY UTAMA: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error insert: $e");
      return false;
    }
  }
}