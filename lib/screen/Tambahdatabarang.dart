import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/api/repository.dart'; 

import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class Tambahdatabarang extends StatefulWidget {
  const Tambahdatabarang({Key? key}) : super(key: key);

  @override
  State<Tambahdatabarang> createState() => _TambahdatabarangState();
}

class _TambahdatabarangState extends State<Tambahdatabarang> {
  final _formKey = GlobalKey<FormState>();

  // Gunakan late untuk efisiensi inisialisasi
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _jenisBarangController;

  final _titleFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _stockFocus = FocusNode();
  final _jenisFocus = FocusNode();

  File? _image;
  final ImagePicker picker = ImagePicker();
  final Repository apiService = Repository();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller di sini agar tidak berat saat build
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _jenisBarangController = TextEditingController();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kecilkan kualitas untuk menghemat memori & mempercepat upload
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  void dispose() {
  
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _jenisBarangController.dispose();
    _titleFocus.dispose();
    _priceFocus.dispose();
    _stockFocus.dispose();
    _jenisFocus.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        bool success = await apiService.insertPost(
          _image,
          _titleController.text,
          _priceController.text,
          _stockController.text,
          _jenisBarangController.text,
        );

        if (mounted) Navigator.pop(context); // Tutup loading

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil simpan!")),
            );
            Navigator.pop(context, true); 
          }
        } else {
          throw Exception("Gagal simpan");
        }
      } catch (e) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan koneksi/server")),
        );
      }
    }
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
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

              _buildTextField(_titleController, _titleFocus, 'Nama Barang', Icons.shopping_bag),
              const SizedBox(height: 16),
              _buildTextField(_jenisBarangController, _jenisFocus, 'Jenis Barang', Icons.category),
              const SizedBox(height: 16),
              _buildTextField(_priceController, _priceFocus, 'Harga Barang', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_stockController, _stockFocus, 'Stok Barang', Icons.inventory, isNumber: true),
              
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Refactor TextField untuk meringankan build tree
  Widget _buildTextField(TextEditingController controller, FocusNode focus, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
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
          _navIcon(Icons.assignment, Colors.yellow[600]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))),
          _navIcon(Icons.home_outlined, const Color(0xFF1A437E), () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()))),
          _navIcon(Icons.payments_outlined, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()))),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}