class Postdatapiutang {
  int id;
  String nama_pelanggan;
  int jumlah_hutang;
  String nama_barang;
  int harga;
  String status;
  String no_whatsapp; 
  String? pesanpenagihan;
String? date;
  Postdatapiutang({
    required this.id,
    required this.nama_pelanggan,
    required this.jumlah_hutang,
    required this.nama_barang,
    required this.harga,
    required this.status,
    required this.no_whatsapp, // Tambahkan field no_whatsapp
    this.pesanpenagihan, // Tambahkan field pesan_penagihan
    this.date, // Tambahkan field date
  });

  factory Postdatapiutang.fromJson(Map<String, dynamic> json) {
    return Postdatapiutang(
      id: json['id'] ?? 0,
      nama_pelanggan: json['nama_pelanggan']?.toString() ?? '',
      jumlah_hutang: json['jumlah_hutang'] ?? 0,
      nama_barang: json['nama_barang']?.toString() ?? '',
      harga: json['harga'] ?? 0,
      status: json['status']?.toString() ?? 'Belum Lunas',
      no_whatsapp: json['no_whatsapp']?.toString() ?? '',
      pesanpenagihan: json['pesanpenagihan']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }

  // Tambahkan method toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pelanggan': nama_pelanggan,
      'jumlah_hutang': jumlah_hutang,
      'nama_barang': nama_barang,
      'harga': harga,
      'status': status,
      'no_whatsapp': no_whatsapp,
      'pesanpenagihan': pesanpenagihan,
      'date': date,
    };
  }
}