import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/postdatapiutang.dart';

class Apidatapiutang {
  final String baseUrl = 'http://192.168.1.177:8000/api/piutang';
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  // 1. Ambil Semua Data
  Future<List<dynamic>> getdatapiutang() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Server error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error koneksi: $e");
      return [];
    }
  }

  // 2. Update Status ke Lunas
  // Pastikan ID dikirim dengan benar ke URL backend (misal: /api/piutang/1)
  Future<bool> updateStatusLunas(dynamic id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'), // Mengarah ke route update laravel: api/piutang/{id}
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
        body: jsonEncode({
          "status": "Lunas", // Data yang ingin diubah
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Ini akan mencetak pesan error dari Laravel jika terjadi error 500
        print("Server error ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error koneksi saat update: $e");
      return false;
    }
  }

  // 3. Tambah Data Baru
  Future<bool> insertdatapiutang(
    String nama_pelanggan,
    int jumlah_hutang,
    String nama_barang,
    int harga,
    String status,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $apiToken",
      },
      body: jsonEncode({
        "nama_pelanggan": nama_pelanggan,
        "jumlah_hutang": jumlah_hutang,
        "nama_barang": nama_barang,
        "harga": harga,
        "status": status
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. Fetch dengan Pagination (Existing)
  Future<Map<String, dynamic>> fetchTransaksi(int page) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var listData = data['data'] is List ? data['data'] : data['data']['data'];

        List<Postdatapiutang> datapiutang = (listData as List)
            .map((json) => Postdatapiutang.fromJson(json))
            .toList();

        return {
          'datapiutang': datapiutang,
          'nextPageUrl': data['data']?['next_page_url'] ?? data['next_page_url'],
        };
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}