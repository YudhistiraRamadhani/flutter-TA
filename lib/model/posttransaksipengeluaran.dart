class PostTransaksipengeluaran {
  int? id;
  String Nama_Barang;
  String Harga;
  String Jumlah;
  String? pengeluaran;
  String? pendapatan;
  String? jenis_transaksi;
  String? nama_supplier;
  String? jenis_barang;
  DateTime? Tanggal;

  PostTransaksipengeluaran({
    this.id,
    required this.Nama_Barang,
    required this.Harga,
    required this.Jumlah,
    this.pengeluaran,
    this.pendapatan,
    this.jenis_transaksi,
    this.nama_supplier,
    this.jenis_barang,
    this.Tanggal,
  });

  factory PostTransaksipengeluaran.fromJson(Map<String, dynamic> json) => PostTransaksipengeluaran(
        id: json['id'],
        Nama_Barang: json['Nama_Barang'] ?? "",
        Harga: json['Harga']?.toString() ?? "0",
        Jumlah: json['Jumlah']?.toString() ?? "0",
        pengeluaran: json['pengeluaran']?.toString(),
        pendapatan: json['pendapatan']?.toString(),
        nama_supplier: json['nama_supplier'] ?? "-",
        jenis_barang: json['jenis_barang'] ?? "-",
        jenis_transaksi: json['jenis_transaksi'] ?? "Pengeluaran",
        Tanggal: json["Tanggal"] != null ? DateTime.parse(json["Tanggal"]) : null,
      );
}