class Postdatapelanggan {
  int? id;
  String? nama_pelanggan;
  String? no_whatsapp;
  
  String? pesannotifikasi;
  DateTime? tanggal_notifikasi;

  Postdatapelanggan({
    this.id,
    this.nama_pelanggan,
    this.no_whatsapp,
    
    this.pesannotifikasi,
    this.tanggal_notifikasi,
  });

  factory Postdatapelanggan.fromJson(Map<String, dynamic> json) {
    return Postdatapelanggan(
      id: json['id'],
      nama_pelanggan: json['nama_pelanggan'] ?? "",
      no_whatsapp: json['no_whatsapp'] ?? "",
      pesannotifikasi: json['pesannotifikasi'] ?? "",
      tanggal_notifikasi: json['tanggal_notifikasi'] != null
          ? DateTime.parse(json['tanggal_notifikasi'])
          : null,
    );
      
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pelanggan': nama_pelanggan,
      'no_whatsapp': no_whatsapp,
     
      'pesannotifikasi': pesannotifikasi,
      'tanggal_notifikasi': tanggal_notifikasi?.toIso8601String(),
    };
  }
}