import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/postproduk.dart';

class Repository {

  final String baseUrl = 'http://172.20.10.2:8000/api/produks';
  
  // Token Bearer dari API Laravel Anda
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  /*
  =================================
  1. FETCH POSTS (MENAMPILKAN LIST)
  =================================
  */
  Future<Map<String, dynamic>> fetchPosts(int page) async {
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

        List<Postproduk> posts = (data['data'] as List)
            .map((e) => Postproduk.fromJson(e))
            .toList();

        return {
          'posts': posts,
          'nextPageUrl': data['next_page_url'],
        };
      } else {
        throw Exception('Gagal memuat daftar produk');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /*
  =================================
  2. FETCH POST BY ID (DETAIL)
  =================================
  */
  Future<Postproduk> fetchPostById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/$id"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $apiToken",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final dynamic data = body.containsKey('data') ? body['data'] : body;
      return Postproduk.fromJson(data);
    } else {
      throw Exception("Gagal memuat detail produk");
    }
  }

  /*
  =================================
  3. INSERT POST (TAMBAH DATA)
  =================================
  */
  Future<bool> insertPost(
    File? image,
    String namaBarang,
    String harga,
    String stok,
 
    String jenisBarang, // Parameter tambahan untuk dropdown
  ) async {
    try {
      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $apiToken",
      });

      // Menambahkan field teks
      request.fields["Nama_Barang"] = namaBarang;
      request.fields["Harga"] = harga;
      request.fields["Stok"] = stok;
     
      request.fields["jenis_barang"] = jenisBarang; // Kirim data dropdown

      // Menambahkan file gambar jika ada
      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            image.path,
            filename: image.path.split("/").last,
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print("INSERT STATUS: ${response.statusCode}");
      print("RESPONSE BODY: $responseData");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("INSERT ERROR: $e");
      return false;
    }
  }

  /*
  =================================
  4. UPDATE POST (UBAH DATA)
  =================================
  */
  Future<bool> updatePost(
    int id,
    File? image,
    String namaBarang,
    String harga,
    String stok,

    String jenisBarang,
  ) async {
    try {

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id'));

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiToken',
      });

      request.fields['_method'] = 'PUT'; // Memberitahu Laravel ini adalah request Update
      request.fields['Nama_Barang'] = namaBarang;
      request.fields['Harga'] = harga;
      request.fields['Stok'] = stok;
   
      request.fields['jenis_barang'] = jenisBarang;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      print("UPDATE STATUS: ${res.statusCode}");
      print("RESPONSE BODY: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("UPDATE ERROR: $e");
      return false;
    }
  }

 
  Future<bool> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
      );

      print("DELETE STATUS: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("DELETE ERROR: $e");
      return false;
    }
  }
}