import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/api/repository.dart';


import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class Tambahdatabarang extends StatefulWidget {
  const Tambahdatabarang({Key? key}) : super(key: key);

  @override
  State<Tambahdatabarang> createState() => _TambahdatabarangState();
}

class _TambahdatabarangState extends State<Tambahdatabarang> {
  final _formKey = GlobalKey<FormState>();
//deklarasi controller untuk form input sesuai API
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _voucherController = TextEditingController();

  final _titleFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _stockFocus = FocusNode();
  final _voucherFocus = FocusNode();

  File? _image;
  final picker = ImagePicker();
  final Repository apiService = Repository();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Image Selected')),
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _voucherController.dispose();
    _titleFocus.dispose();
    _priceFocus.dispose();
    _stockFocus.dispose();
    _voucherFocus.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      bool success = await apiService.insertPost(
        _image,
        _titleController.text,
        _priceController.text,
        _stockController.text,
        _voucherController.text,
      );

      Navigator.pop(context);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil simpan ke PostgreSQL!")),
          );
          Navigator.pop(context, true); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menyimpan. Periksa koneksi/log Laravel.")),
          );
        }
      }
    }
  }

  // HELPER FOOTER ICON (Konsisten dengan class lain)
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
                "TAMBAH DATA BARANG",
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
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image == null
                        ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Barang',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (val) => val!.isEmpty ? 'Masukkan nama barang' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _voucherController,
                focusNode: _voucherFocus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Voucher',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                focusNode: _priceFocus,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Harga Barang',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) => val!.isEmpty ? 'Masukkan harga' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _stockController,
                focusNode: _stockFocus,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Stok Barang',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (val) => val!.isEmpty ? 'Masukkan stok' : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5D48ED)),
                  onPressed: _submitData,
                  child: const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),

      // FOOTER NAVIGASI (Identik dengan Laporan & Edit)
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