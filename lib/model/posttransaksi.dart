class PostTransaksi {
  final String Nama_Barang;
  final String Harga;
  final String Jumlah;
  final DateTime? Tanggal;
  final String jenis_barang;
  final String jenis_transaksi;
  final String nama_supplier;
  final int pendapatan; // Tambahkan ini
  final int pengeluaran;

  PostTransaksi({
    required this.Nama_Barang,
    required this.Harga,
    required this.Jumlah,
    required this.Tanggal,
    required this.jenis_barang,
    required this.jenis_transaksi,
    required this.nama_supplier,
    required this.pendapatan,
    required this.pengeluaran
  });

  factory PostTransaksi.fromJson(Map<String, dynamic> json) {
  return PostTransaksi(
    Nama_Barang: json['Nama_Barang'] ?? json['nama_barang'] ?? '',
    Harga: json['Harga']?.toString() ?? json['harga']?.toString() ?? '0',
    Jumlah: json['Jumlah']?.toString() ?? json['jumlah']?.toString() ?? '0',
    Tanggal: json['Tanggal'] != null 
        ? DateTime.tryParse(json['Tanggal']) 
        : (json['tanggal_transaksi'] != null ? DateTime.tryParse(json['tanggal_transaksi']) : null),
    jenis_barang: json['jenis_barang'] ?? '',
    jenis_transaksi: json['jenis_transaksi'] ?? '',
    nama_supplier: (json['nama_supplier'] ?? json['supplier'] ?? '-').toString(),
    pendapatan: json['pendapatan'] ?? 0,
      pengeluaran: json['pengeluaran'] ?? 0,
  );
}
}