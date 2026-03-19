import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';
import 'package:flutter_application_1/model/postdatapelanggan.dart';

void main() => runApp(Datapelanggan());

class Datapelanggan extends StatefulWidget {
  @override
  State<Datapelanggan> createState() => _DatapelangganState();
}

class _DatapelangganState extends State<Datapelanggan> {

  final apidatapelanggan api = apidatapelanggan();

  List<Postdatapelanggan> pelanggan = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await api.fetchTransaksi(page);

    setState(() {
      pelanggan = data['datapelanggan'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Pelanggan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: Scaffold(
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
                "DATA PELANGGAN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),

        body: pelanggan.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('NO', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nama Pelanggan', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nomor WA', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Pesan notifikasi', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Tanggal Notifikasi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],

                    rows: List.generate(pelanggan.length, (index) {
                      final data = pelanggan[index];

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(data.nama_pelanggan ?? "")),
                          DataCell(Text(data.no_whatsapp ?? "")),
                          DataCell(Text(data.pesannotifikasi ?? "")),
                          DataCell(Text(data.tanggal_notifikasi?.toString() ?? "")),
                        ],
                      );
                    }),
                  ),
                ),
              ),

        bottomNavigationBar: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF00E5BC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterIcon(
                icon: Icons.assignment,
                color: Colors.yellow,
              ),
              _buildFooterIcon(
                icon: Icons.home_outlined,
                color: const Color(0xFF1A437E),
              ),
              _buildFooterIcon(
                icon: Icons.payments_outlined,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterIcon({required IconData icon, required Color color}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
    );
  }
}