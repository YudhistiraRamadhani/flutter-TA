class Postdatapiutang {
  int id;
  String nama_pelanggan;
  int jumlah_hutang;
  String nama_barang;
  int harga;
  String status;

  Postdatapiutang({
    required this.id,
    required this.nama_pelanggan,
    required this.jumlah_hutang,
    required this.nama_barang,
    required this.harga,
    required this.status,
  });

  factory Postdatapiutang.fromJson(Map<String, dynamic> json) {
    return Postdatapiutang(
      id: json['id'],
      nama_pelanggan: json['nama_pelanggan'],
      jumlah_hutang: json['jumlah_hutang'],
      nama_barang: json['nama_barang'],
      harga: json['harga'],
      status: json['status'],
    );
  }
}