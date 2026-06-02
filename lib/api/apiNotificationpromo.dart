import 'dart:convert';
import 'package:http/http.dart' as http;

class Apinotificationpromo {
  final String baseUrl = "http://192.168.1.17:8000/api/promo";
  
  Future<bool> postNotification({
    required String nama,
    required String phone,
    required String message,
    required String barang, 
    String? tanggal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json", 
        },
        body: jsonEncode({
          'nama': nama,
          'nomorwa': phone,
          'pesannotifikasi': message,
          'namabarang': barang,
          'tanggal_kirim': tanggal, 
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error koneksi API: $e");
      return false;
    }
  }
}