import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';

class EditLaporanPenjualan extends StatefulWidget {
  // Mengambil data objek transaksi lengkap dari halaman laporan
  final PostTransaksi transaksi;

  const EditLaporanPenjualan({Key? key, required this.transaksi}) : super(key: key);

  @override
  _EditLaporanPenjualanState createState() => _EditLaporanPenjualanState();
}

class _EditLaporanPenjualanState extends State<EditLaporanPenjualan> {
  final Apitransaksi apiService = Apitransaksi();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk menampung data yang akan diubah
  late TextEditingController _namaBarangController;
  late TextEditingController _hargaController;
  late TextEditingController _jumlahController;

  @override
  void initState() {
    super.initState();
    // Mengisi controller langsung dengan data lama saat halaman dibuka
    _namaBarangController = TextEditingController(text: widget.transaksi.Nama_Barang);
    // Menghapus karakter non-angka pada harga agar bisa di-input ulang
    _hargaController = TextEditingController(
        text: widget.transaksi.Harga.replaceAll(RegExp(r'[^0-9]'), ''));
    _jumlahController = TextEditingController(text: widget.transaksi.Jumlah);
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header dengan UI yang sama (Ungu dan Melengkung)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: Text(
                    "EDIT DATA PENJUALAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Menampilkan ID sebagai referensi (ReadOnly)
              Text(
                "ID Transaksi: ${widget.transaksi.id}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              
              const Text("NAMA BARANG", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaBarangController,
                decoration: InputDecoration(
                  hintText: "Nama Barang",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? "Harap isi nama barang" : null,
              ),

              const SizedBox(height: 20),
              const Text("HARGA SATUAN", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  hintText: "0",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? "Harap isi harga" : null,
              ),

              const SizedBox(height: 20),
              const Text("JUMLAH (QTY)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "0",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? "Harap isi jumlah" : null,
              ),

              const SizedBox(height: 40),
              
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                onPressed: () async {
  if (_formKey.currentState!.validate()) {
    // Tampilkan loading sebentar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Siapkan data Map untuk dikirim ke API
    Map<String, dynamic> dataUpdate = {
      "Nama_Barang": _namaBarangController.text,
      "Harga": _hargaController.text,
      "Jumlah": _jumlahController.text,
      "jenis_barang": widget.transaksi.jenis_barang,
      "jenis_transaksi": widget.transaksi.jenis_transaksi,
      "nama_supplier": widget.transaksi.nama_supplier,
      "deskripsi": widget.transaksi.deskripsi,
      "Tanggal": widget.transaksi.Tanggal?.toIso8601String(),
    };

    // PANGGIL API UPDATE
    bool success = await apiService.updateTransaksi(
      widget.transaksi.id.toString(), 
      dataUpdate
    );

    if (mounted) {
      Navigator.pop(context); // Tutup loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui")),
        );
        // Kembali ke halaman laporan dan beri instruksi refresh (true)
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui data ke server")),
        );
      }
    }
  }
},
                  child: const Text(
                    "SIMPAN PERUBAHAN",
                    style: TextStyle(
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
      ),
    );
  }
}