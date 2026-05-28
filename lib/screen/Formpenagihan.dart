import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apinotificationpenagihan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Formpenagihan extends StatefulWidget {
  @override
  _FormpenagihanState createState() => _FormpenagihanState();
}

class _FormpenagihanState extends State<Formpenagihan> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaController = TextEditingController();
  final _nomorwaController = TextEditingController();
  final _barangController = TextEditingController();
  final _pesanController = TextEditingController();

  final api = Apinotificationpenagihan();

  @override
  void dispose() {
    _namaController.dispose();
    _nomorwaController.dispose();
    _barangController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // --- LOGIKA PENGGABUNGAN PESAN ---
      // Membuat format pesan agar Nama, No WA, dan Barang ikut terkirim di dalam teks WA
      String pesanLengkap = 
          "Halo ${_namaController.text},\n" +
          "No. WA: ${_nomorwaController.text}\n" +
          "Barang: ${_barangController.text}\n\n" +
          "Pesan: ${_pesanController.text}";

      bool ok = await api.postPenagihan(
        nama: _namaController.text,
        phone: _nomorwaController.text,
        barang: _barangController.text,
        pesan_notifikasi_penagihan: pesanLengkap, // Mengirim pesan yang sudah diformat
      );

      if (!mounted) return;
      Navigator.pop(context); 

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Terkirim!"), backgroundColor: Colors.green),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengirim"), backgroundColor: Colors.red),
        );
      }
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
                "FORM PENAGIHAN",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTextFormField(_namaController, "Nama Pelanggan", Icons.person),
              const SizedBox(height: 16),
              _buildTextFormField(_nomorwaController, "Nomor WhatsApp", Icons.phone_android, isPhone: true),
              const SizedBox(height: 16),
              _buildTextFormField(_barangController, "Nama Barang", Icons.shopping_bag),
              const SizedBox(height: 16),
              _buildTextFormField(_pesanController, "Pesan Tambahan", Icons.message, maxLines: 4),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('KIRIM TAGIHAN',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Helper untuk merapikan kode UI Input
  Widget _buildTextFormField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00E5BC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(icon: Icons.assignment, color: Colors.yellow[600]!, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))),
          _buildFooterIcon(icon: Icons.home_outlined, color: const Color(0xFF1A437E), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()))),
          _buildFooterIcon(icon: Icons.payments_outlined, color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()))),
        ],
      ),
    );
  }
}