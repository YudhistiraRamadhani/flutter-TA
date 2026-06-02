import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/postdatalaporankeuangan.dart';
class apilaporankeuangan {
final String baseUrl = 'http://192.168.1.17:8000/api/laporankeuangan'; // G
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  Future<List<dynamic>> getLaporanKeuangan() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $apiToken"
        }
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
  }}