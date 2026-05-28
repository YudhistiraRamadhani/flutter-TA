import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan struktur folder Anda
import 'package:flutter_application_1/screen/Formpromo.dart'; 
import 'package:flutter_application_1/screen/Formpenagihan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class JenisNotifikasi extends StatelessWidget {
  const JenisNotifikasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(70),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                "JENIS PESAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),

      // 2. BODY DENGAN 2 CARD MENU
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          children: [
            // CARD 1: NOTIFIKASI PROMO
            _buildMenuCard(
              context: context,
              backgroundColor: const Color(0xFF2E57AF),
              iconWidget: const Icon(
                Icons.confirmation_number_sharp,
                color: Color(0xFFFDB515),
                size: 60,
              ),
              titleText: "PESAN PROMO",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Formpromo()),
                );
              },
            ),

            const SizedBox(height: 30),

            // CARD 2: NOTIFIKASI PENAGIHAN
            _buildMenuCard(
              context: context,
              backgroundColor: const Color(0xFFCA6140),
              iconWidget: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 60,
              ),
              titleText: "PESAN PENAGIHAN",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Formpenagihan()),
                );
              },
            ),
          ],
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR
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
            _buildBottomIcon(
              icon: Icons.assignment,
              circleColor: const Color(0xFFFDB515),
              iconColor: Colors.black,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan())),
            ),
            _buildBottomIcon(
              icon: Icons.home_outlined,
              circleColor: const Color(0xFF1A437E),
              iconColor: Colors.black,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage())),
            ),
            _buildBottomIcon(
              icon: Icons.payments_outlined,
              circleColor: const Color(0xFFE51C23),
              iconColor: Colors.black,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER UNTUK CARD MENU
  Widget _buildMenuCard({
    required BuildContext context,
    required Color backgroundColor,
    Widget? iconWidget,
    required String titleText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Center(child: iconWidget ?? const SizedBox()),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER UNTUK IKON BOTTOM BAR
  Widget _buildBottomIcon({
    required IconData icon,
    required Color circleColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}