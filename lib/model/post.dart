class Post {
  int id;
  String? image;

 
  String Nama_Barang;
  String Harga;
  String Stok;

  DateTime? created_at;
  DateTime? updated_at;

  Post({
    required this.id,
    this.image,
    required this.Nama_Barang,
    required this.Harga,
    required this.Stok,
    this.created_at,
    this.updated_at,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      image: json['image']?.toString(),

      // ⭐ HARUS PERSIS
      Nama_Barang: json['Nama_Barang']?.toString() ?? '-',
      Harga: json['Harga']?.toString() ?? '0',
      Stok: json['Stok']?.toString() ?? '0',

      created_at: DateTime.tryParse(json['created_at'] ?? ''),
      updated_at: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'Nama_Barang': Nama_Barang,
      'Harga': Harga,
      'Stok': Stok,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
    };
  }
}