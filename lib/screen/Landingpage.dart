import 'package:flutter/material.dart';

import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Datapelanggan.dart';
import 'package:flutter_application_1/screen/Transaksi.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Dataproduk.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/Datapiutang.dart';
import 'package:flutter_application_1/screen/Tambahdatapelanggan.dart';
import 'package:flutter_application_1/screen/formpiutang.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Landingpage(),
  ));
}

class Landingpage extends StatelessWidget {
  const Landingpage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
         
          Container(
            width: double.infinity,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF4D4DFF),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
            ),
            padding: const EdgeInsets.only(left: 30, top: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('HALO PEMILIK JS CELL', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 15),
                Text('Data aman tersimpan di aplikasi ini', 
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // Grid Menu
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              children: [
               
                _buildMenuItem(context, Image.asset("images/transaksi.png", width: 60, height: 60), "transaksi", const Color(0xFFC5E1A5), Transaksi()),
                
                _buildMenuItem(context, Image.asset("images/laporan.png", width: 60, height: 60), "laporan penjualan", const Color(0xFFD4E157), Laporanpenjualan()),
                _buildMenuItem(context, Image.asset("images/produk.png", width: 60, height: 60), "data produk", const Color(0xFF42A5F5), Dataproduk()),
                _buildMenuItem(context, Image.asset("images/laporankeuangan.png", width: 60, height: 60), "laporan keuangan", const Color(0xFFFF7043), Laporankeuangan()),
                _buildMenuItem(context, Image.asset("images/datahutang.png", width: 60, height: 60), "data Hutang", const Color(0xFFCE93D8), Datapiutang()),
                _buildMenuItem(context, Image.asset("images/laporan.png",width: 60, height: 60),"formpiutang", const Color(0xFFFF7043), formpiutang()), 
                _buildMenuItem(context, const Icon(Icons.person_outline, size: 60), "pelanggan", const Color(0xFF9C27B0), Tambahdatapelanggan()),
                _buildMenuItem(context, const Icon(Icons.assignment_ind_outlined, size: 60), "data pelanggan", const Color(0xFFE0E0E0), Datapelanggan()),
                
              ],
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF00D2B4),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterIcon(Icons.assignment, Colors.yellow[700]!, () {
               
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()));
              
            }),
            _buildFooterIcon(Icons.home_outlined, const Color(0xFF1A237E), () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()));
  }),
            _buildFooterIcon(Icons.payments_outlined, Colors.red, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()));
            }),
          ],
        ),
      ),
    );
  }


  Widget _buildMenuItem(BuildContext context, Widget leading, String label, Color color, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black45),
            ),
            child: leading, 
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, Color circleColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: circleColor,
shape: BoxShape.circle,
border: Border.all(color: Colors.black, width: 1.5),

      
),
child: Icon(icon, color: Colors.black, size: 26),
      
      )
      );
  }
  // footer
 
}