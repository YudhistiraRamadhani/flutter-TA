

class Posttransaksi {
  final int? id;
  final String? Nama_Barang;

 
  Posttransaksi({this.id, this.Nama_Barang});

  factory Posttransaksi.fromJson(Map<String, dynamic> json) {
    return Posttransaksi(
      id: json['id'],
      Nama_Barang: json['Nama_Barang'],
    );
  }
}
class Postproduk {
  int? id;
  String? Nama_Barang;
  String? Harga;
  String? Stok;
  String? image;
  String? voucher;

  Postproduk({
    this.id,
    this.Nama_Barang,
    this.Harga,
    this.Stok,
    this.image,
    this.voucher,
  });
 
String get fullImageUrl {
    if (image != null && image!.isNotEmpty) {
      // Pastikan IP ini sama dengan baseUrl di Repository Anda
      return "http://192.168.1.3:8000/storage/$image";
    }
    // Gambar placeholder jika null
    return "https://via.placeholder.com/150"; 
  }
  Postproduk.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    Nama_Barang = json['Nama_Barang'];
    Harga = json['Harga'];
    Stok = json['Stok'];
    image = json['image'];
    voucher = json['voucher'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['Nama_Barang'] = Nama_Barang;
    data['Harga'] = Harga;
    data['Stok'] = Stok;
    data['image'] = image;
    data['voucher'] = voucher;
    return data;
  }
}