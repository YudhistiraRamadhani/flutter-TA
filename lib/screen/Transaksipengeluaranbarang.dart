import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Transaksipengeluaranbarang extends StatefulWidget {
  const Transaksipengeluaranbarang({super.key});

  @override
  State<Transaksipengeluaranbarang> createState() =>
      _TransaksipengeluaranbarangState();
}

class _TransaksipengeluaranbarangState
    extends State<Transaksipengeluaranbarang> {
  final _formKey = GlobalKey<FormState>();
  final Apitransaksi _apiService = Apitransaksi();

  bool _isLoading = false;

  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController(); // GANTI: dari deskripsi menjadi supplier
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _supplierController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _namaBarangController.clear();
    _supplierController.clear();
    _hargaController.clear();
    _jumlahController.clear();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _simpanTransaksi() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String supplierText = _supplierController.text.trim();
      String deskripsiText = supplierText.isEmpty ? "-" : "Pembelian dari $supplierText";

      print("========== TRANSAKSI PENGELUARAN BARANG ==========");
      print("Nama Barang: ${_namaBarangController.text}");
      print("Supplier: $supplierText");
      print("Harga: ${_hargaController.text}");
      print("Jumlah: ${_jumlahController.text}");
      print("Tanggal: ${_tanggalController.text}");
      print("==================================================");

      // Parameter: nama, harga, jumlah, tanggal, jenisBarang, jenisTransaksi, supplier, deskripsi
      bool success = await _apiService.insertTransaksi(
        _namaBarangController.text.trim(), // nama
        _hargaController.text,              // harga
        _jumlahController.text,             // jumlah
        _tanggalController.text,            // tanggal
        "Barang",                           // jenisBarang
        "Pengeluaran",                      // jenisTransaksi
        supplierText.isEmpty ? "-" : supplierText, // supplier
        deskripsiText,                      // deskripsi
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        _showSnackBar("✅ Transaksi Pengeluaran Barang Berhasil Disimpan!", Colors.green);
        _clearForm();
      } else {
        _showSnackBar("❌ Gagal menyimpan! Periksa koneksi atau database.", Colors.red);
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
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // APPBAR
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
                "TRANSAKSI PENGELUARAN BARANG",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),

      // BODY
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Transaksi ini akan mencatat pengeluaran untuk pembelian barang (Stok akan BERTAMBAH)",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Nama Barang
              TextFormField(
                controller: _namaBarangController,
                decoration: const InputDecoration(
                  labelText: "Nama Barang",
                  hintText: "Contoh: Kipas Angin, Mouse, dll",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Nama barang wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              // SUPPLIER (GANTI dari Deskripsi)
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: "Supplier",
                  hintText: "Nama toko atau supplier barang",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Satuan",
                  hintText: "Harga per barang",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: "Rp ",
                ),
                validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              // Jumlah
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah",
                  hintText: "Jumlah barang yang dibeli",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (v) => v!.isEmpty ? "Jumlah wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              // Tanggal
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Tanggal Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _isLoading ? null : _simpanTransaksi,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SIMPAN TRANSAKSI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      // FOOTER
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
            _buildFooterIcon(
              icon: Icons.assignment,
              color: const Color(0xFFFDB515),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Laporanpenjualan()),
              ),
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Landingpage()),
              ),
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: const Color(0xFFE51C23),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Laporankeuangan()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}