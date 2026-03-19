import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart'; // Import API Piutang Anda
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class DetailPiutang extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPiutang({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailPiutang> createState() => _DetailPiutangState();
}

class _DetailPiutangState extends State<DetailPiutang> {
  final Apidatapiutang apiService = Apidatapiutang();
  late Map<String, dynamic> currentData;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    currentData = widget.data;
  }

  // Fungsi untuk memproses pelunasan
  Future<void> _prosesPelunasan() async {
    setState(() => isProcessing = true);
    try {
      // Pastikan fungsi updateStatusLunas sudah dibuat di apidatapiutang.dart
      bool success = await apiService.updateStatusLunas(currentData['id']);
      
      if (success) {
        setState(() {
          currentData['status'] = "Lunas";
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status berhasil diperbarui menjadi Lunas")),
        );
      } else {
        throw Exception("Gagal memperbarui status");
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLunas = currentData['status']?.toString().toLowerCase() == "lunas";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                "DETAIL PIUTANG",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // const Icon(Icons.receipt_long, size: 80, color: Color(0xFF5D48ED)),
              const SizedBox(height: 30),
              _buildInfoRow("Pelanggan", currentData['nama_pelanggan'] ?? "-"),
              const SizedBox(height: 12),
              _buildInfoRow("Barang", currentData['nama_barang'] ?? "-"),
              const SizedBox(height: 12),
              _buildInfoRow("Harga", "Rp ${currentData['harga']}"),
              const SizedBox(height: 12),
              _buildInfoRow("Total Hutang", "Rp ${currentData['jumlah_hutang']}"),
              const SizedBox(height: 12),
              _buildStatusRow("Status", currentData['status'] ?? "Belum Lunas"),
              const SizedBox(height: 40),
              
              // TOMBOL AKSI
              isLunas 
                ? const Text("Transaksi ini telah lunas", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isProcessing ? null : () => _showConfirmDialog(),
                      icon: isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text("BAYAR LUNAS SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  // Row untuk info teks biasa
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(4)),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // Row khusus status dengan warna
  Widget _buildStatusRow(String label, String value) {
    bool lunas = value.toLowerCase() == "lunas";
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lunas ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4)
            ),
            child: Text(
              value.toUpperCase(), 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: lunas ? Colors.green[700] : Colors.red[700])
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pelunasan"),
        content: const Text("Apakah Anda yakin ingin mengubah status data ini menjadi LUNAS?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _prosesPelunasan();
            }, 
            child: const Text("Ya, Lunas", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00E5BC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(Icons.assignment, Colors.yellow[600]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))),
          _buildFooterIcon(Icons.home_outlined, const Color(0xFF1A437E), () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()))),
          _buildFooterIcon(Icons.payments_outlined, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()))),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, Color color, VoidCallback onTap) {
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