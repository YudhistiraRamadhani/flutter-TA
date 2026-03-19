import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/postproduk.dart';

class Repository {
  // final String baseUrl = 'http://10.0.2.2:8000/api/admin/produks';
  final String baseUrl = 'http://192.168.1.177:8000/api/produks';
  // Token yang sudah Anda buat di terminal tadi
  final String apiToken = "1|fl4Xog5gUWR78vc40UDWAXGppHppCMPPXKpOd8sPeea9f88e";

  /*
  =================================
  FETCH POST BY ID (DITAMBAHKAN KEMBALI)
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
      
      // Mengambil data dari key 'data' (standar API Filament)
      final dynamic data = body.containsKey('data') ? body['data'] : body;
      
      return Postproduk.fromJson(data);
    } else {
      throw Exception("Gagal memuat detail produk");
    }
  }

  /*
  =================================
  FETCH POSTS (LIST)
  =================================
  */
  Future<Map<String, dynamic>> fetchPosts(int page) async {
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
  }

  /*
  =================================
  INSERT POST
  =================================
  */
 Future<bool> insertPost(
  File? image,
  String Nama_Barang,
  String Harga,
  String Stok,
  String voucher,
) async {
  try {
    var uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $apiToken",
    });

    request.fields["Nama_Barang"] = Nama_Barang;
    request.fields["Harga"] = Harga;
    request.fields["Stok"] = Stok;
    request.fields["voucher"] = voucher;

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
  UPDATE POST
  =================================
  */
  Future<bool> updatePost(
    int id,
    File? image,
    String Nama_Barang,
    String Harga,
    String Stok,
    String voucher,
  ) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id'));

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiToken',
      });

      request.fields['_method'] = 'PUT';
      request.fields['Nama_Barang'] = Nama_Barang;
      request.fields['Harga'] = Harga;
      request.fields['Stok'] = Stok;
      request.fields['voucher'] = voucher;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      print("UPDATE STATUS: ${res.statusCode}");
      return res.statusCode == 200;
    } catch (e) {
      print("UPDATE ERROR: $e");
      return false;
    }
  }

  /*
  =================================
  DELETE POST
  =================================
  */
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