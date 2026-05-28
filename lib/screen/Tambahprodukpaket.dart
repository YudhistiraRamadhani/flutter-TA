import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tambahprodukpaket extends StatefulWidget {
  @override
  _FormTambahProdukState createState() => _FormTambahProdukState();
}

class _FormTambahProdukState extends State<Tambahprodukpaket> {

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  
  // State untuk Dropdown
  String? _selectedJenis;
  final List<String> _kategori = ['Paket Data', 'Kartu Provider'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "INPUT DATA PRODUK",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1A437E),
                            letterSpacing: 1.1
                          ),
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      
                      // Field Nama Barang
                      _buildLabel("Nama Barang"),
                      _buildTextField(_namaController, "Masukkan nama produk...", Icons.inventory_2_outlined),
                      
                      // Field Dropdown Jenis
                      _buildLabel("Jenis Produk"),
                      _buildDropdown(),

                      // Field Harga & Stok (Bersebelahan)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Harga"),
                                _buildTextField(_hargaController, "Rp", Icons.payments_outlined, isNumber: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Stok"),
                                _buildTextField(_stokController, "0", Icons.layers_outlined, isNumber: true),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Field Upload Gambar (Placeholder UI)
                      _buildLabel("Gambar Produk"),
                      _buildImagePickerBox(),

                      const SizedBox(height: 30),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Sementara hanya print log
                            print("Data Tersimpan di UI");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A437E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          child: const Text(
                            "SIMPAN DATA",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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
        child: const SafeArea(
          child: Center(
            child: Text(
              "TAMBAH PRODUK",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1A437E)),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJenis,
          isExpanded: true,
          hint: const Text("Pilih Jenis", style: TextStyle(fontSize: 13, color: Colors.grey)),
          icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF1A437E)),
          items: _kategori.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedJenis = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return InkWell(
      onTap: () => print("Pilih Gambar"),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text("Ketuk untuk upload gambar", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}