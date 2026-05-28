class Notificationlocal {
  final int id;
  final String judul;
  final String pesan;
  final DateTime waktu;

  Notificationlocal({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
  });

  factory Notificationlocal.fromJson(Map<String, dynamic> json) {
    return Notificationlocal(
      id: json['id'],
      judul: json['judul'],
      pesan: json['pesan'],
      waktu: DateTime.parse(json['waktu']),
    );
  }
}