import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/postdatapelanggan.dart';

class apidatapelanggan {
  final String baseUrl = 'http://192.168.1.17:8000/api/pelanggan';
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  Future<Map<String, dynamic>> fetchTransaksi(int page) async {
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

      List<Postdatapelanggan> datapelanggan = (listData as List)
          .map((json) => Postdatapelanggan.fromJson(json))
          .toList();

      return {
        'datapelanggan': datapelanggan,
        'nextPageUrl': data['data']?['next_page_url'] ?? data['next_page_url'],
      };
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  Future<List<Postdatapelanggan>> fetchAllPelanggan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=1&limit=100'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var listData = data['data'] is List ? data['data'] : data['data']['data'];
        
        List<Postdatapelanggan> datapelanggan = (listData as List)
            .map((json) => Postdatapelanggan.fromJson(json))
            .toList();
        
        return datapelanggan;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetchAllPelanggan: $e");
      return [];
    }
  }

  Future<bool> insertData(
    String nama_pelanggan,
    String no_whatsapp,
    String? pesannotifikasi,
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
        "no_whatsapp": no_whatsapp,
        "pesannotifikasi": pesannotifikasi ?? "",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updatePelanggan(String id, Map<String, dynamic> data) async {
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
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePelanggan(String id) async {
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
      return false;
    }
  }

  // ... (bagian atas kode tetap sama)

  Future<bool> sendBroadcast(String targets, String message) async {
    try {
      final url = Uri.parse("http://192.168.1.17:8000/api/broadcast-promo");
      
      // Timeout ditingkatkan menjadi 10 menit (600 detik) 
      // Karena Laravel akan mengirim pesan dengan delay sekuensial
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'target': targets,
          'message': message,
        },
      ).timeout(const Duration(minutes: 10)); 

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error broadcast: $e");
      return false;
    }
  }

  // Gunakan ini untuk mengirim daftar pelanggan
  Future<Map<String, int>> sendBatchBroadcast(List<Map<String, String>> targets, String message) async {
    // Gabungkan nomor dengan koma agar dikirim dalam satu string target
    // Laravel akan menangani perulangan dan jedanya (lebih aman)
    String nomorGabungan = targets.map((t) => t['nomor']).join(',');
    
    bool success = await sendBroadcast(nomorGabungan, message);
    
    return {
      'success': success ? 1 : 0,
      'fail': success ? 0 : 1,
    };
  }
}
