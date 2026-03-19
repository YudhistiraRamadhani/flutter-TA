import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart'; 
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/DetailPiutang.dart'; 

class Datapiutang extends StatefulWidget {
  const Datapiutang({super.key});

  @override
  _DatapiutangState createState() => _DatapiutangState();
}

class _DatapiutangState extends State<Datapiutang> {
  final Apidatapiutang _apiService = Apidatapiutang();

  // Fungsi untuk menyegarkan data
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                "DATA PIUTANG",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getdatapiutang(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data piutang atau gagal koneksi."));
          }

          final dataPiutang = snapshot.data!;

          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('NO', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nama Pelanggan', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Harga', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Jumlah Hutang', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Aksi / Detail', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: dataPiutang.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    bool isLunas = item['status']?.toString().toLowerCase() == "lunas";

                    return DataRow(cells: [
  DataCell(Text((index + 1).toString())),
  DataCell(Text(item['nama_pelanggan'].toString())),
  DataCell(Text(item['nama_barang'].toString())),
  DataCell(Text(item['harga'].toString())),
  DataCell(Text(item['jumlah_hutang'].toString())),
  DataCell(
    Row(
      children: [
        // TOMBOL DETAIL (Tetap ada)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPiutang(data: item),
              ),
            ).then((_) => _refreshData());
          },
          child: const Text("Detail"),
        ),
        const SizedBox(width: 8),

        // TAMPILAN STATUS (Hanya Label, Tidak Ada Tombol Bayar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            // Warna background: hijau jika lunas, merah muda/abu jika belum
            color: isLunas ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            isLunas ? "Lunas" : "Belum Lunas",
            style: TextStyle(
              color: isLunas ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
]);
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00E5BC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleIcon(Icons.assignment, Colors.yellow, () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  Laporanpenjualan()))),
          _buildCircleIcon(Icons.home_outlined, const Color(0xFF1A437E), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Landingpage()))),
          _buildCircleIcon(Icons.payments_outlined, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  Laporankeuangan()))),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}