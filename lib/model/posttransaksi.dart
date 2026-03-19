class PostTransaksi {
  int id;
  String Nama_Barang;
  String Harga;
  String Jumlah;
  String  Voucher;
  String? jenis_transaksi;
  DateTime? Tanggal;

  PostTransaksi({
    required this.id,
    required this.Nama_Barang,
    required this.Harga,
    required this.jenis_transaksi,
    required this.Jumlah,
    required this.Voucher,
      this.Tanggal,
  });

  factory PostTransaksi.fromJson(Map<String, dynamic> json) => PostTransaksi(
      id: json['id'],
    Nama_Barang: json['Nama_Barang'] ?? "", // Beri default string kosong jika null
    Harga: json['Harga']?.toString() ?? "0", 
    Jumlah: json['Jumlah']?.toString() ?? "0",
    Voucher: json['Voucher'] ?? "-", // Tangani Voucher null dari database
    Tanggal: json["Tanggal"] != null ? DateTime.parse(json["Tanggal"]) : null,
    jenis_transaksi: json['jenis_transaksi'] ?? "Pemasukan", // Default ke Pemasukan jika null
      );
      Map<String, dynamic> toJson() => {
        'id': id,
        'Nama_Barang': Nama_Barang,
        'Harga': Harga,
        'jenis_transaksi': jenis_transaksi,
        'Jumlah': Jumlah,
        'Voucher': Voucher,
        'Tanggal': Tanggal?.toIso8601String(),
      };
}