class Postdatalaporankeuangan {
  int? id;
  String? nama_barang;
  String? jenis_barang;
  String? nama_supplier;
  int? harga;
  int? jumlah;
  String? jenis_transaksi;
  String? pengeluaran;
  String? pendapatan;
  DateTime? tanggal;

  Postdatalaporankeuangan({
    this.id,
    this.nama_barang,
    this.jenis_barang,
    this.nama_supplier,
    this.harga,
    this.jenis_transaksi,
    this.jumlah,
    this.pengeluaran,
    this.pendapatan,
    this.tanggal,
  });

  factory Postdatalaporankeuangan.fromJson(Map<String, dynamic> json) {
    return Postdatalaporankeuangan(
      id: json['id'],
      nama_barang: json['Nama_Barang'] ?? json['nama_barang'] ?? "-",
      jenis_barang: json['jenis_barang'] ?? "-",
      nama_supplier: json['nama_supplier'] ?? json['nama_suppier'] ?? "-",
      
      // PARSING INT
      harga: int.tryParse(json['Harga']?.toString() ?? json['harga']?.toString() ?? "0") ?? 0,
      jumlah: int.tryParse(json['Jumlah']?.toString() ?? json['jumlah']?.toString() ?? "1") ?? 1,
      
      // MAPPING STRING (PENTING: Baris ini sebelumnya tidak ada di fromJson kamu)
      jenis_transaksi: json['jenis_transaksi'] ?? json['Jenis_Transaksi'] ?? "Pemasukan",
      
      pengeluaran: json['Pengeluaran'] ?? json['pengeluaran'] ?? "0",
      pendapatan: json['Pendapatan'] ?? json['pendapatan'] ?? "0",
      
      tanggal: json['Tanggal'] != null ? DateTime.tryParse(json['Tanggal'].toString()) : 
               (json['tanggal'] != null ? DateTime.tryParse(json['tanggal'].toString()) : null),
    );
  }
}