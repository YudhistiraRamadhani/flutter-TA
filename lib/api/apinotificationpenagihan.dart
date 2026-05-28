import 'package:http/http.dart' as http;

class Apinotificationpenagihan {
  final String baseUrl = "http://172.20.10.2:8000/api/penagihan";
  
  Future<bool> postPenagihan({
    required String nama,
    required String phone,
    required String barang,
    String? pesan_notifikasi_penagihan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Accept": "application/json"},
        body: {
          'nama_pelanggan': nama,
          'nomorwa': phone,
          'nama_barang': barang,
          'pesan_notifikasi_penagihan': pesan_notifikasi_penagihan ?? "",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}