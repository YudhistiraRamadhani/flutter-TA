import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/postdatapelanggan.dart';

class apidatapelanggan {
  //final String baseUrl = 'http://10.0.2.2:8000/api/admin/data-pelanggans';
  final String baseUrl = 'http://192.168.1.177:8000/api/pelanggan';

  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  Future<Map<String, dynamic>> fetchTransaksi(int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl?page=$page'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $apiToken", // Tambahkan token di sini
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Cek apakah struktur datanya data['data'] atau data['data']['data']
      // Biasanya Rupadana ApiService membungkusnya dalam data['data']
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

  Future<bool> insertdatapelanggan(
    String nama_pelanggan,
    String no_whatsapp,
    String tanggal_notifikasi,
    String pesannotifikasi,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $apiToken", // Tambahkan token di sini
      },
      body: jsonEncode({

        "nama_pelanggan": nama_pelanggan,
        "no_whatsapp": no_whatsapp,
        "pesannotifikasi": pesannotifikasi,
        "tanggal_notifikasi": tanggal_notifikasi,
      }),
    );

    print("STATUS PELANGGAN: ${response.statusCode}");
    print("BODY PELANGGAN: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}