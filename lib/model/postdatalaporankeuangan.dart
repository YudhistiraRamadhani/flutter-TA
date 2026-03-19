class Postdatalaporankeuangan {
  int? id;
  String? nama_barang;
  int pendapatan; // Non-nullable
  int pengeluaran; // Non-nullable
  int? harga;
  DateTime? tanggal;

  Postdatalaporankeuangan({
    this.id,
    this.nama_barang,
    this.harga,
    this.tanggal,
    required this.pendapatan, // Gunakan required untuk non-nullable
    required this.pengeluaran,
  });

  factory Postdatalaporankeuangan.fromJson(Map<String, dynamic> json) {
    return Postdatalaporankeuangan(
      id: json['id'],
      nama_barang: json['nama_barang'] ?? "",
      // Perbaikan: Gunakan int.tryParse jika ada kemungkinan harga dikirim sebagai String dari API
      harga: json['harga'] is String 
          ? int.tryParse(json['harga']) 
          : json['harga'],
      pendapatan: json['pendapatan'] ?? 0, // Ditambahkan koma di sini
      pengeluaran: json['pengeluaran'] ?? 0,
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': nama_barang,
      'harga': harga,
      'pendapatan': pendapatan,
      'pengeluaran': pengeluaran,
      'tanggal': tanggal?.toIso8601String(),
    };
  }
}