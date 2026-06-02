import 'dart:convert';
import 'package:http/http.dart' as http;

class NotifikasiService {
  static const String baseUrl = "http://192.168.1.17:8000/api";

  static Future<List<dynamic>> fetchNotifikasi() async {
    final response = await http.get(Uri.parse('$baseUrl/notifikasi'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal ambil notifikasi');
    }
  }
}