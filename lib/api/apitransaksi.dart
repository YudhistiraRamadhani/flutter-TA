import 'dart:convert';
import 'package:http/http.dart' as http;

class PostTransaksi {
  final int? id;
  final String Nama_Barang;
  final String Harga;
  final String Jumlah;
  final DateTime? Tanggal;
  final String jenis_barang;
  final String jenis_transaksi;
  final String nama_supplier;
  final String deskripsi;
  final int pendapatan;
  final int pengeluaran;

  PostTransaksi({
    this.id,
    required this.Nama_Barang,
    required this.Harga,
    required this.Jumlah,
    this.Tanggal,
    required this.jenis_barang,
    required this.jenis_transaksi,
    required this.nama_supplier,
    this.deskripsi = "-",
    this.pendapatan = 0,
    this.pengeluaran = 0,
  });

  factory PostTransaksi.fromJson(Map<String, dynamic> json) {
    return PostTransaksi(
      id: json['id'],
      Nama_Barang: (json['Nama_Barang'] ?? json['nama_barang'] ?? '').toString(),
      Harga: json['Harga']?.toString() ?? json['harga']?.toString() ?? '0',
      Jumlah: json['Jumlah']?.toString() ?? json['jumlah']?.toString() ?? '0',
      Tanggal: json['Tanggal'] != null 
          ? DateTime.tryParse(json['Tanggal']) 
          : (json['tanggal'] != null ? DateTime.tryParse(json['tanggal']) : null),
      jenis_barang: (json['jenis_barang'] ?? '').toString(),
      jenis_transaksi: (json['jenis_transaksi'] ?? '').toString(),
      nama_supplier: (json['nama_supplier'] ?? json['supplier'] ?? '-').toString(),
      deskripsi: (json['deskripsi'] ?? '-').toString(),
      pendapatan: _toInt(json['pendapatan']),
      pengeluaran: _toInt(json['pengeluaran']),
    );
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      "Nama_Barang": Nama_Barang,
      "Harga": Harga,
      "Jumlah": Jumlah,
      "Tanggal": Tanggal?.toIso8601String(),
      "jenis_barang": jenis_barang,
      "jenis_transaksi": jenis_transaksi,
      "nama_supplier": nama_supplier,
      "deskripsi": deskripsi,
    };
  }
}

class Apitransaksi {
  final String baseUrl = "http://192.168.1.17:8000/api";
  
  // ==================== METHOD FETCH DATA ====================

  // Ambil semua transaksi
  Future<List<PostTransaksi>> fetchTransaksi() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/transaksi"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List listData = jsonData is Map ? jsonData['data'] : jsonData;
        return listData.map((e) => PostTransaksi.fromJson(e)).toList();
      } else {
        throw Exception("Gagal load transaksi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Fetch: $e");
      throw Exception("Koneksi Error: $e");
    }
  }

  // Ambil laporan keuangan - DENGAN FITER DATA DOBEL
  Future<List<PostTransaksi>> fetchLaporanKeuangan() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/laporankeuangan"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List listData = data is Map ? (data['data'] ?? []) : data;
        
        // Konversi ke PostTransaksi
        List<PostTransaksi> allData = listData.map((e) => PostTransaksi.fromJson(e)).toList();
        
        // 🔥 HILANGKAN DATA DOBEL berdasarkan ID
        Map<int, PostTransaksi> uniqueMap = {};
        for (var item in allData) {
          if (item.id != null) {
            // Jika ID sudah ada, skip (data dobel)
            if (!uniqueMap.containsKey(item.id)) {
              uniqueMap[item.id!] = item;
            } else {
              print("⚠️ Data dobel ditemukan! ID: ${item.id} - ${item.Nama_Barang}");
            }
          }
        }
        
        // 🔥 URUTKAN DESCENDING (TERBARU DI ATAS) berdasarkan Tanggal
        List<PostTransaksi> uniqueData = uniqueMap.values.toList();
        uniqueData.sort((a, b) {
          if (a.Tanggal == null && b.Tanggal == null) return 0;
          if (a.Tanggal == null) return 1;
          if (b.Tanggal == null) return -1;
          return b.Tanggal!.compareTo(a.Tanggal!);
        });
        
        print("📊 Total data dari API: ${allData.length}");
        print("📊 Data unik: ${uniqueData.length}");
        print("📊 Data dobel: ${allData.length - uniqueData.length}");
        
        return uniqueData;
      } else {
        return fetchTransaksi();
      }
    } catch (e) {
      print("Error fetchLaporanKeuangan: $e");
      return fetchTransaksi();
    }
  }

  // Ambil daftar voucher
  Future<List<String>> fetchVoucherList() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/produks-list")
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        List filtered = data.where((item) {
          final jenis = item['jenis_barang']?.toString().toLowerCase();
          return jenis == 'voucher' || jenis == 'kartu provider';
        }).toList();

        return filtered
            .map<String>((item) => item['Nama_Barang'].toString())
            .toList();
      } else {
        print("Gagal ambil voucher: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error Fetch Voucher List: $e");
      return [];
    }
  }

  // Cek stok produk
  Future<Map<String, dynamic>> cekStokProduk(String namaBarang) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/produks-list"),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        var produk = data.firstWhere(
          (item) => item['Nama_Barang'].toString().toLowerCase() == namaBarang.toLowerCase(),
          orElse: () => null,
        );
        
        if (produk != null) {
          return {
            'found': true,
            'stok': produk['Stok'] ?? 0,
            'nama': produk['Nama_Barang'],
            'harga': produk['Harga'],
            'id': produk['id'],
          };
        }
      }
      return {'found': false, 'stok': 0};
    } catch (e) {
      print("Error cek stok: $e");
      return {'found': false, 'stok': 0};
    }
  }

  // ==================== METHOD INSERT TRANSAKSI ====================

  // Insert transaksi umum (Pemasukan/Pengeluaran)
  Future<bool> insertTransaksi(
    String nama, 
    String harga, 
    String jumlah, 
    String tanggal,
    String jenisBarang, 
    String jenisTransaksi, 
    String supplier, 
    String deskripsi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/transaksi"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "Nama_Barang": nama.trim(),
          "Harga": harga,
          "Jumlah": jumlah,
          "Tanggal": tanggal,
          "jenis_barang": jenisBarang,
          "jenis_transaksi": jenisTransaksi,
          "nama_supplier": supplier.isEmpty ? "-" : supplier,
          "deskripsi": deskripsi.isEmpty ? "-" : deskripsi,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error insertTransaksi: $e");
      return false;
    }
  }

  // Insert transaksi voucher
  Future<bool> insertTransaksiVoucher(
    String nama, 
    String supplier, 
    String tanggal, 
    String jumlah, 
    String harga, 
    String deskripsi, 
    String jenis
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/transaksi-voucher"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "Nama_Barang": nama.trim(),
          "nama_supplier": supplier.isEmpty ? "-" : supplier,
          "Tanggal": tanggal,
          "Jumlah": jumlah,
          "Harga": harga,
          "jenis_barang": jenis,
          "jenis_transaksi": "Pengeluaran",
          "deskripsi": deskripsi.isEmpty ? "-" : deskripsi,
        }),
      );
      
      print("VOUCHER STATUS: ${response.statusCode}");
      print("VOUCHER BODY: ${response.body}");
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("VOUCHER ERROR: $e");
      return false;
    }
  }

  // Insert transaksi dengan detail response
  Future<Map<String, dynamic>> insertTransaksiWithDetail(
    String nama, 
    String harga, 
    String jumlah, 
    String tanggal,
    String jenisBarang, 
    String jenisTransaksi, 
    String supplier, 
    String deskripsi,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/transaksi"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "Nama_Barang": nama.trim(),
          "Harga": harga,
          "Jumlah": jumlah,
          "Tanggal": tanggal,
          "jenis_barang": jenisBarang,
          "jenis_transaksi": jenisTransaksi,
          "nama_supplier": supplier.isEmpty ? "-" : supplier,
          "deskripsi": deskripsi.isEmpty ? "-" : deskripsi,
        }),
      ).timeout(const Duration(seconds: 10));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Transaksi berhasil',
          'data': responseData['data'] ?? {},
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Gagal menyimpan transaksi',
        };
      }
    } catch (e) {
      print("Error insertTransaksiWithDetail: $e");
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  // ==================== METHOD UPDATE & DELETE ====================

  // Update transaksi
  Future<bool> updateTransaksi(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/transaksi/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      print("Status Update: ${response.statusCode}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // Delete transaksi
  Future<bool> deleteTransaksi(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/transaksi/$id"),
        headers: {"Accept": "application/json"},
      );

      print("Status Delete: ${response.statusCode}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }

  // Update laporan keuangan
  Future<bool> updateLaporanKeuangan(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/laporankeuangan/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      print("Status Update Laporan: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error Update Laporan: $e");
      return false;
    }
  }

  // Delete laporan keuangan
  Future<bool> deleteLaporanKeuangan(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/laporankeuangan/$id"),
        headers: {"Accept": "application/json"},
      );

      print("Status Delete Laporan: ${response.statusCode}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("Error Delete Laporan: $e");
      return false;
    }
  }
}