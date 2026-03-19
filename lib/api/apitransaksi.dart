import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/posttransaksi.dart';

class Apitransaksi {
  final String baseUrl = 'http://192.168.1.177:8000/api/transaksi'; 
  final String produkUrl = 'http://192.168.1.177:8000/api/admin/produks'; 

  Future<List<String>> fetchVoucherList() async {
    try {
      final response = await http.get(Uri.parse(produkUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List posts = data['data']; 
        return posts
            .map((e) => e['voucher']?.toString() ?? "")
            .where((v) => v.isNotEmpty)
            .toSet() 
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error Fetch Voucher: $e");
      return [];
    }
  }

 
  Future<Map<String, dynamic>> fetchTransaksi({
    int page = 1, 
    String? search, 
    int? month, 
    int? year
  }) async {
    
    String url = '$baseUrl?page=$page';
    if (search != null && search.isNotEmpty) url += '&search=$search';
    if (month != null) url += '&month=$month';
    if (year != null) url += '&year=$year';

    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<PostTransaksi> transaksi = (data['data'] as List)
          .map((json) => PostTransaksi.fromJson(json))
          .toList();

      return {
        'transaksi': transaksi,
        'nextPageUrl': data['next_page_url'],
      };
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  Future<bool> insertTransaksi(
    String Nama_Barang, String Harga, String Tanggal, String Jumlah, String Voucher, String jenisTransaksi
  ) async {
    const String hardcodedToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $hardcodedToken",
        },
        body: jsonEncode({
          "Nama_Barang": Nama_Barang,
          "Harga": Harga,
          "Tanggal": Tanggal,
          "Jumlah": Jumlah,
          "Voucher": Voucher,
          "jenis_transaksi": jenisTransaksi, // Sesuaikan case dengan database
        }),
      );

      print("Status Code: ${response.statusCode}");
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error koneksi: $e");
      return false;
    }
  }
}