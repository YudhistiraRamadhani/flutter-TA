import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Transaksipengeluaran extends StatefulWidget {
  @override
  _TransaksipengeluaranState createState() => _TransaksipengeluaranState();
}

class _TransaksipengeluaranState extends State<Transaksipengeluaran> {
  final _formKey = GlobalKey<FormState>();
  
  final _namaBarangController = TextEditingController();
  final _hargaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _jumlahController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default tanggal hari ini
    _tanggalController.text = DateTime.now().toString().split(' ')[0];
    
    // Opsional: Jika ingin menguji nilai default harga yang tidak bisa diedit
    // _hargaController.text = "15000"; 
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _hargaController.dispose();
    _tanggalController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanTransaksi() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaksi Pengeluaran Berhasil Disimpan")),
      );
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
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                "TRANSAKSI PENGELUARAN",
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
              // Nama Barang
              TextFormField(
                controller: _namaBarangController,
                decoration: const InputDecoration(
                  labelText: "Nama Barang",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (v) => v!.isEmpty ? "Nama barang wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Harga Satuan (DIJADIKAN DISABLE / READ ONLY)
              TextFormField(
                controller: _hargaController,
                readOnly: true, // Mencegah keyboard muncul dan menutup akses edit langsung
                style: const TextStyle(color: Colors.black87), // Memastikan teks tetap jelas dibaca
                decoration: InputDecoration(
                  labelText: "Harga Satuan",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey[100], // Memberikan warna background abu-abu tipis sebagai tanda dinonaktifkan
                ),
                validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Jumlah
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah (Qty)",
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
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _tanggalController.text = pickedDate.toString().split(' ')[0];
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
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: _simpanTransaksi,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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