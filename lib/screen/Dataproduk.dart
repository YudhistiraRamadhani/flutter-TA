import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/repository.dart';
import 'package:flutter_application_1/model/postproduk.dart';
import 'package:flutter_application_1/screen/Detailproduk.dart';
import 'package:flutter_application_1/screen/EditDataproduk.dart';
// Import untuk Navigasi Footer
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Dataproduk extends StatefulWidget {
  @override
  State<Dataproduk> createState() => _DataprodukState();
}

class _DataprodukState extends State<Dataproduk> {
  final Repository repository = Repository();
  List<Postproduk> listProduk = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await repository.fetchPosts(1); 
      setState(() {
        listProduk = data['posts'];
        isLoading = false;
      });
    } catch (e) {
      print("Error load data: $e");
      setState(() => isLoading = false);
    }
  }

  
  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
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
                "DATA PRODUK",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  bool? refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditDataproduk()),
                  );
                  if (refresh == true) loadData();
                },
                child: const Text("Tambah data", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    // Padding bawah 100 agar item terakhir tidak tertutup footer melayang
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: listProduk.length,
                    itemBuilder: (context, index) {
                      final produk = listProduk[index];
                      return _buildProductCard(produk);
                    },
                  ),
          ),
        ],
      ),

      // FOOTER SESUAI DESAIN TRANSAKSI & DATA PELANGGAN
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC), // Warna Toska
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
              color: Colors.yellow[600]!,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()));
              },
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()));
              },
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: Colors.red,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Postproduk produk) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(

  "http://192.168.1.177:8000/storage/${produk.image}", 
  errorBuilder: (context, error, stackTrace) {
    print("Link Error: http://192.168.1.177:8000/storage/${produk.image}"); // Debug link di console
    return const Icon(Icons.broken_image, size: 50, color: Colors.white);
  },
),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () async {
                bool? refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Detailproduk(id: produk.id), 
                  ),
                );
                if (refresh == true) loadData(); // Refresh jika ada data dihapus di halaman detail
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("detail ", style: TextStyle(color: Colors.white, fontSize: 12)),
                    Icon(Icons.visibility, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}