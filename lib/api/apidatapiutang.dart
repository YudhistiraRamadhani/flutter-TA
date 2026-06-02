// api/apidatapiutang.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/postdatapiutang.dart';

class Apidatapiutang {
  final String baseUrl = 'http://192.168.1.17:8000/api/piutang';
  final String pelangganUrl = 'http://192.168.1.17:8000/api/get-pelanggan';
  final String produkUrl = 'http://192.168.1.17:8000/api/get-produk';
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  // 1. Ambil Semua Data Piutang
  Future<List<dynamic>> getdatapiutang() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );
      print("Respon Server: ${response.body}");
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

  // 2. Ambil Data Pelanggan untuk Autocomplete
  Future<List<Map<String, dynamic>>> getPelanggan() async {
    try {
      final response = await http.get(
        Uri.parse(pelangganUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );
      
      print('Status Code getPelanggan: ${response.statusCode}');
      print('Response getPelanggan: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Gagal mengambil data pelanggan: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error koneksi pelanggan: $e");
      return [];
    }
  }

  // 3. Ambil Data Produk untuk Autocomplete
  Future<List<Map<String, dynamic>>> getProduk() async {
    try {
      final response = await http.get(
        Uri.parse(produkUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );
      
      print('Status Code getProduk: ${response.statusCode}');
      print('Response getProduk: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Gagal mengambil data produk: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error koneksi produk: $e");
      return [];
    }
  }

  // 4. Tambah Data Piutang
  Future<bool> insertdatapiutang(
    String nama_pelanggan,
    int jumlah_hutang,
    String nama_barang,
    int harga,
    String status,
    String no_whatsapp, 
    String pesanpenagihan,
    String date,
  ) async {
    try {
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
          "status": status,
          "no_whatsapp": no_whatsapp, 
          "pesanpenagihan": pesanpenagihan,
          "date": date,
        }),
      );
      print('Insert response status: ${response.statusCode}');
      print('Insert response body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error koneksi saat insert: $e");
      return false;
    }
  }

  // 5. Update Data Piutang
  Future<bool> updatePiutang(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode != 200) {
        print("Update Gagal: ${response.body}");
      }
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // 6. Hapus Data Piutang
  Future<bool> deletePiutang(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }

  // 7. Send Broadcast WhatsApp
  Future<bool> sendBroadcast(String targets, String message) async {
    try {
      final url = Uri.parse("http://192.168.1.17:8000/api/broadcast-promo");
      
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
        },
        body: {
          'target': targets,
          'message': message,
        },
      ).timeout(const Duration(seconds: 15));

      print("Status Code: ${response.statusCode}");
      print("Respon: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Terjadi kesalahan koneksi: $e");
      return false;
    }
  }

  // 8. Update Status Lunas
  Future<bool> updateStatusLunas(dynamic id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
        body: jsonEncode({
          "status": "Lunas",
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error koneksi saat update: $e");
      return false;
    }
  }
}