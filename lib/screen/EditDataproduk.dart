// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/api/repository.dart';
import 'package:flutter_application_1/model/postproduk.dart';
// Import untuk navigasi footer
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class EditDataproduk extends StatefulWidget {
  final Postproduk? postproduk;
  
  const EditDataproduk({
    super.key,
    this.postproduk,
  });

  @override
  State<EditDataproduk> createState() => _EditDataprodukState();
}

class _EditDataprodukState extends State<EditDataproduk> {
  final _formKey = GlobalKey<FormState>();
  
  final _NamaBarangController = TextEditingController();
  final _HargaController = TextEditingController();
  final _StokController = TextEditingController();
  final _voucherController = TextEditingController();
  
  File? _image;
  final picker = ImagePicker();
  final Repository repository = Repository();

  @override
  void initState() {
    super.initState();
    if (widget.postproduk != null) {
      _NamaBarangController.text = widget.postproduk!.Nama_Barang ?? '';
      _HargaController.text = widget.postproduk!.Harga?.toString() ?? '0';
      _StokController.text = widget.postproduk!.Stok?.toString() ?? '0';
      _voucherController.text = widget.postproduk!.voucher ?? '';
    }
  }

  @override
  void dispose() {
    _NamaBarangController.dispose();
    _HargaController.dispose();
    _StokController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;

      if (widget.postproduk != null) {
        success = await repository.updatePost(
          widget.postproduk!.id!, 
          _image,
          _NamaBarangController.text,
          _HargaController.text,
          _StokController.text,
          _voucherController.text,
        );
      } else {
        success = await repository.insertPost(
          _image,
          _NamaBarangController.text,
          _HargaController.text,
          _StokController.text,
          _voucherController.text,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data ke server')),
        );
      }
    }
  }

  // HELPER FOOTER: Desain Lingkaran Konsisten
  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
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
                "EDIT DATA PRODUK",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding bawah agar tidak tertutup footer
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                              Text('Ketuk untuk pilih gambar'),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _NamaBarangController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) => value!.isEmpty ? 'Nama barang tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _HargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) => value!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _StokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) => value!.isEmpty ? 'Stok tidak boleh kosong' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _voucherController,
                decoration: const InputDecoration(
                  labelText: 'Voucher',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitData,
                  child: Text(
                    widget.postproduk == null ? 'SIMPAN PRODUK' : 'UPDATE PRODUK',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // FOOTER SESUAI DESAIN TRANSAKSI
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC), // Warna Toska khas
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
              color: Colors.yellow[600]!,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()));
              },
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()));
              },
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: Colors.red,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()));
              },
            ),
          ],
        ),
      ),
    );
  }
}