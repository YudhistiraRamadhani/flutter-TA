import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/TransaksipemasukanVoucher.dart';
import 'package:flutter_application_1/screen/TransaksipemasukanBarang.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';

class Jenistransaksipemasukan extends StatelessWidget {
  const Jenistransaksipemasukan({super.key});

  // Helper Footer Icon bulat (Konsisten dengan halaman lain)
  Widget _buildFooterIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      backgroundColor: Colors.white,
      // 1. APPBAR UNGU MELENGKUNG (Sesuai tema aplikasi)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: Text(
                    "JENIS TRANSAKSI PEMASUKAN",
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                      letterSpacing: 1.2
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),

          // Menu Voucher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransaksipemasukanVoucher()),
                );
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A437E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 25),
                    const Icon(Icons.confirmation_number, size: 70, color: Colors.orange),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        'VOUCHER DAN\nKARTU PROVIDER',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Menu Barang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  TransaksipemasukanBarang()),
                );
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFCF6542),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 25),
                    const Icon(Icons.shopping_cart_outlined, size: 70, color: Colors.white),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        'BARANG',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 2. BOTTOM NAVIGATION BAR TOSKA (Sesuai tema aplikasi)
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), 
            topRight: Radius.circular(25)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterIcon(
              icon: Icons.assignment,
              color: Colors.yellow[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan())),
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }
}