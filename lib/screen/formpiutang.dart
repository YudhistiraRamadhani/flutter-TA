import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter
import 'package:flutter_application_1/api/apidatapiutang.dart'; 
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class formpiutang extends StatefulWidget {
  @override
  _FormpiutangState createState() => _FormpiutangState();
}

class _FormpiutangState extends State<formpiutang> {
  final TextEditingController _nama_barangController = TextEditingController();
  final TextEditingController _nama_pelangganController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlah_hutangController = TextEditingController();
  
  final Apidatapiutang _apiService = Apidatapiutang(); 

  void _simpanData() async {
    // Validasi input wajib
    if (_nama_pelangganController.text.isEmpty || 
        _jumlah_hutangController.text.isEmpty || 
        _nama_barangController.text.isEmpty || 
        _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom wajib diisi!")),
      );
      return;
    }

    // KONVERSI STRING KE INTEGER (Agar sinkron dengan Controller Laravel Anda)
    int jumlahHutangInt = int.tryParse(_jumlah_hutangController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int hargaInt = int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // Mengirim data ke API
    // Pastikan fungsi di insertdatapiutang sudah menerima (String, int, String, int, String)
    bool sukses = await _apiService.insertdatapiutang(
      _nama_pelangganController.text,
      jumlahHutangInt, // Dikirim sebagai Integer
      _nama_barangController.text,
      hargaInt,        // Dikirim sebagai Integer
      "Belum Lunas",   // Status default
    );    

    if (sukses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Piutang Berhasil Disimpan!")),
      );
      // Bersihkan form
      _nama_barangController.clear();
      _nama_pelangganController.clear();
      _hargaController.clear();
      _jumlah_hutangController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data ke server. Periksa Log Laravel!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text("form pencatatan piutang", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 30),
                  _buildInputField("Nama barang", _nama_barangController),
                  _buildInputField("Nama Pelanggan", _nama_pelangganController),
                  _buildInputField("Harga Satuan", _hargaController, isNumber: true),
                  _buildInputField("Jumlah Hutang", _jumlah_hutangController, isNumber: true),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A437E),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("kirim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF5D48ED),
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
        ),
        child: const SafeArea(child: Center(child: Text("FORM PIUTANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(4)),
              child: TextFormField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
                decoration: const InputDecoration(contentPadding: EdgeInsets.all(10), border: InputBorder.none, isDense: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFF00E5BC), borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleIcon(Icons.assignment, Colors.yellow, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))),
          _buildCircleIcon(Icons.home_outlined, const Color(0xFF1A437E), () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()))),
          _buildCircleIcon(Icons.payments_outlined, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()))),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(width: 1.5)),
        child: Icon(icon, size: 28),
      ),
    );
  }
}