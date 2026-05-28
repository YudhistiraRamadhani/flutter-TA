import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Tambahdatapelanggan extends StatefulWidget {
  const Tambahdatapelanggan({super.key});

  @override
  State<Tambahdatapelanggan> createState() => _TambahdatapelangganState();
}

class _TambahdatapelangganState extends State<Tambahdatapelanggan> {
  final _formKey = GlobalKey<FormState>();
  final apidatapelanggan apiService = apidatapelanggan();

  // Controller standar untuk input manual
  final _namaController = TextEditingController();
  final _waController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      String finalNama = _namaController.text.trim();
      String finalWa = _waController.text.trim();

      try {
        // Mengirim isi pesan promo kosong "" secara default
        bool success = await apiService.insertData(
          finalNama,
          finalWa,
          "", 
        );

        setState(() => _isSaving = false);

        if (success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil Simpan Pelanggan Baru!"), backgroundColor: Colors.green),
          );
          // Kembali ke halaman utama dan memicu loadData()
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal Simpan! Periksa koneksi atau database."), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
      }
    }
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
        child: Icon(icon, color: Colors.white, size: 28),
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
                    "TAMBAH DATA PELANGGAN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Nama Pelanggan", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: "Masukkan nama pelanggan baru",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              const Text("Nomor WhatsApp", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _waController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Contoh: 081234567xxx",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? "Nomor WhatsApp wajib diisi" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) 
                    : const Text("SIMPAN DATA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
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
              icon: Icons.home,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments,
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }
}