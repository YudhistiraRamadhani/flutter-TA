import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apinotificationpromo.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Formpromo extends StatefulWidget {
  @override
  _FormpromoState createState() => _FormpromoState();
}

class _FormpromoState extends State<Formpromo> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk input field
  final _namaController = TextEditingController();
  final _nomorwaController = TextEditingController();
  final _barangController = TextEditingController(); // Untuk 'namabarang'
  final _pesanController = TextEditingController();  // Untuk 'pesannotifikasi'

  final api = Apinotificationpromo();

  @override
  void dispose() {
    _namaController.dispose();
    _nomorwaController.dispose();
    _barangController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Menampilkan Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Format pesan teks yang akan diterima pelanggan di WhatsApp
      String pesanKeWhatsapp = 
          "Halo ${_namaController.text},\n" +
          "No. WA: ${_nomorwaController.text}\n" +
          "Promo Barang: ${_barangController.text}\n\n" + 
          "PESAN PROMO:\n" +
          "${_pesanController.text}";


      bool success = await api.postNotification(
        nama: _namaController.text,
        phone: _nomorwaController.text,
        barang: _barangController.text, 
        message: pesanKeWhatsapp,     
        tanggal: null,                 
      );

      if (!mounted) return;
      Navigator.pop(context); // Menutup loading dialog
      setState(() => _isLoading = false);

      // SnackBar Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Berhasil kirim WA Promo" : "Gagal kirim, cek koneksi/log"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) _clearForm();
    }
  }

  void _clearForm() {
    _namaController.clear();
    _nomorwaController.clear();
    _barangController.clear();
    _pesanController.clear();
  }

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
                "KIRIM NOTIFIKASI PROMO",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Input Nama Pelanggan
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Pelanggan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              // Input Nomor WA
              TextFormField(
                controller: _nomorwaController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Nomor WhatsApp",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Nomor wajib diisi";
                  if (v.length < 10) return "Nomor tidak valid";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Input Nama Barang -> Akan dikirim ke 'namabarang'
              TextFormField(
                controller: _barangController,
                decoration: const InputDecoration(
                  labelText: "Nama Barang Promo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) => v!.isEmpty ? "Nama barang wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              // Input Isi Pesan -> Akan digabung dan dikirim ke 'pesannotifikasi'
              TextFormField(
                controller: _pesanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Pesan Promo",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.message),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Pesan wajib diisi" : null,
              ),
              const SizedBox(height: 30),
              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _isLoading ? null : simpanData,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kirim Promo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
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