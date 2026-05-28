import 'dart:convert';
import 'package:http/http.dart' as http;

class NotifikasiService {
  static const String baseUrl = "http://172.20.10.2:8000/api";

  static Future<List<dynamic>> fetchNotifikasi() async {
    final response = await http.get(Uri.parse('$baseUrl/notifikasi'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal ambil notifikasi');
    }
  }
}