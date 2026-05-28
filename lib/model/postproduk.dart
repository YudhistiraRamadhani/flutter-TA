class Postproduk {
  int? id;
  String? Nama_Barang;
  String? Harga;
  String? Stok;
  String? image;
 
  String? jenis_barang; // <--- TAMBAHAN BARU

  Postproduk({
    this.id,
    this.Nama_Barang,
    this.Harga,
    this.Stok,
    this.image,
  
    this.jenis_barang, // <--- TAMBAHAN BARU
  });

  String get fullImageUrl {
    if (image != null && image!.isNotEmpty) {
      return "http://192.168.1.5:8000/storage/$image";
    }
    return "https://via.placeholder.com/150";
  }

  Postproduk.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    Nama_Barang = json['Nama_Barang'];
    Harga = json['Harga']?.toString(); // Pastikan diconvert ke String jika dari API berupa int
    Stok = json['Stok']?.toString();
    image = json['image'];
   
    jenis_barang = json['jenis_barang']; // <--- TAMBAHAN BARU
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['Nama_Barang'] = Nama_Barang;
    data['Harga'] = Harga;
    data['Stok'] = Stok;
    data['image'] = image;
   
    data['jenis_barang'] = jenis_barang; 
    return data;
  }
}