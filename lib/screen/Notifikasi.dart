import 'package:flutter/material.dart';

class Notifikasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ganti warna background screen agar card putih terlihat jelas
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Notifikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- 1. CARD PENAGIHAN (Billing) ---
            Card(
              elevation: 2, // Memberikan sedikit bayangan agar terlihat melayang
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Sudut melengkung
              ),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE), // Merah muda pudar
                  child: Icon(
                    Icons.receipt_long,
                    color: Color(0xFFD32F2F), // Merah tua
                  ),
                ),
                title: Text(
                  "Penagihan ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("Segera lakukan penagihan sebelum jatuh tempo."),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

            const SizedBox(height: 16), // Jarak antar card

            // --- 2. CARD PROMO ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9), // Hijau muda pudar
                  child: Icon(
                    Icons.local_offer,
                    color: Color(0xFF388E3C), // Hijau tua
                  ),
                ),
                title: Text(
                  "Promo Spesial Hari Ini! 🔥",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text("promo"),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

