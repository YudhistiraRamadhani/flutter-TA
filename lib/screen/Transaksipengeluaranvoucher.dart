import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Transaksipengeluaranvoucher extends StatefulWidget {
  const Transaksipengeluaranvoucher({super.key});

  @override
  State<Transaksipengeluaranvoucher> createState() =>
      _TransaksipengeluaranvoucherState();
}

class _TransaksipengeluaranvoucherState
    extends State<Transaksipengeluaranvoucher> {
  final _formKey = GlobalKey<FormState>();
  final Apitransaksi _apiService = Apitransaksi();

  bool _isLoading = false;

  final _namaBarangController = TextEditingController();
  final _supplierController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _hargaController = TextEditingController();
  final _tglController = TextEditingController();

  String? _selectedJenis;
  final List<String> _jenisOptions = ["Voucher", "Kartu Provider"];

  @override
  void initState() {
    super.initState();
    _tglController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _supplierController.dispose();
    _jumlahController.dispose();
    _hargaController.dispose();
    _tglController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _namaBarangController.clear();
    _supplierController.clear();
    _jumlahController.clear();
    _hargaController.clear();
    setState(() {
      _selectedJenis = null;
    });
    _tglController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

      try {
        String namaBarang = _namaBarangController.text.trim();
        String supplier = _supplierController.text.trim();
        String jumlah = _jumlahController.text.trim();
        String harga = _hargaController.text.trim();
        String tanggal = _tglController.text;
        String jenis = _selectedJenis ?? "Voucher";
        
        // Deskripsi tidak diambil dari UI, akan diisi default "-" di API

        print("========== TRANSAKSI VOUCHER ==========");
        print("Nama Barang: $namaBarang");
        print("Supplier: $supplier");
        print("Jumlah: $jumlah");
        print("Harga: $harga");
        print("Tanggal: $tanggal");
        print("Jenis: $jenis");
        print("=======================================");

        // Panggil method voucher (deskripsi akan diisi default di API)
        bool success = await _apiService.insertTransaksiVoucher(
          namaBarang,
          supplier,
          tanggal,
          jumlah,
          harga,
          "", // Deskripsi kosong, akan diisi default "-" di API
          jenis,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (success) {
          _showSnackBar("✅ Transaksi Voucher berhasil disimpan!", Colors.green);
          _clearForm();
        } else {
          _showSnackBar("❌ Gagal menyimpan transaksi voucher!", Colors.red);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBar("❌ Terjadi kesalahan: ${e.toString()}", Colors.red);
        print("ERROR: $e");
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
                "TRANSAKSI PENGELUARAN VOUCHER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Transaksi ini akan mencatat pengeluaran untuk pembelian voucher/kartu provider",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Dropdown Jenis Barang
              DropdownButtonFormField<String>(
                value: _selectedJenis,
                decoration: const InputDecoration(
                  labelText: "Jenis Barang",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _jenisOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJenis = newValue;
                  });
                },
                validator: (v) => v == null ? "Pilih jenis barang" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _namaBarangController,
                decoration: const InputDecoration(
                  labelText: "Nama Barang",
           
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: "Supplier",
                  hintText: "Nama toko atau supplier",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah",
                  hintText: "Jumlah voucher yang dibeli",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Satuan",
                  hintText: "Harga per voucher",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _tglController,
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
                      _tglController.text = DateFormat('yyyy-MM-dd').format(picked);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Tanggal Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanTransaksi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIMPAN TRANSAKSI",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Laporanpenjualan())),
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: const Color(0xFFE51C23),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }
}