import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/repository.dart';
import 'package:flutter_application_1/model/postproduk.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditDataproduk extends StatefulWidget {
  final Postproduk postproduk;

  const EditDataproduk({Key? key, required this.postproduk}) : super(key: key);

  @override
  State<EditDataproduk> createState() => _EditDataprodukState();
}

class _EditDataprodukState extends State<EditDataproduk> {
  final Repository repository = Repository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  String? _selectedJenis;
  File? _imageFile;
  bool _isSaving = false;

  final List<String> _jenisList = ['Produk', 'Voucher', 'Kartu Provider'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.postproduk.Nama_Barang);
    _hargaController = TextEditingController(text: widget.postproduk.Harga.toString());
    _stokController = TextEditingController(text: widget.postproduk.Stok.toString());
    _selectedJenis = widget.postproduk.jenis_barang;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _updateData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      bool success = await repository.updatePost(
        widget.postproduk.id!,
        _imageFile,
        _namaController.text,
        _hargaController.text,
        _stokController.text,
        _selectedJenis ?? 'Produk',
      );

      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil diperbarui!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui data!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT DATA PRODUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D48ED),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FOTO PRODUK SEKARANG DI PALING ATAS ---
                    const Center(
                      child: Text("Foto Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150, // Ukuran sedikit diperbesar agar lebih jelas
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFF5D48ED), width: 1),
                          ),
                          child: Stack(
                            children: [
                              _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(_imageFile!, fit: BoxFit.cover, width: 150, height: 150),
                                    )
                                  : (widget.postproduk.image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            "https://aplikasi-pencatatan-keuangan.onrender.com/storage/${widget.postproduk.image}",
                                            fit: BoxFit.cover,
                                            width: 150,
                                            height: 150,
                                          ),
                                        )
                                      : const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xFF5D48ED), shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- INPUT FIELDS ---
                    const Text("Jenis Barang", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _jenisList.contains(_selectedJenis) ? _selectedJenis : null,
                      items: _jenisList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedJenis = val),
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 15),

                    const Text("Nama Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      decoration: _inputDecoration(),
                      validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 15),

                    const Text("Harga", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(),
                      validator: (v) => v!.isEmpty ? "Harga tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 15),

                    const Text("Stok", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(),
                      validator: (v) => v!.isEmpty ? "Stok tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 40),

                    // --- BUTTON SIMPAN ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _updateData,
                        child: const Text("SIMPAN PERUBAHAN", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}