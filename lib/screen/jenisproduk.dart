import 'package:flutter/material.dart';
class jenisproduk extends StatefulWidget {
  const jenisproduk({super.key});

  @override
  State<jenisproduk> createState() => _jenisprodukState();
}

class _jenisprodukState extends State<jenisproduk> {
  int _selectedCategoryIndex = 0; // 0 untuk Produk Barang, 1 untuk Produk Voucher
  String? _selectedKategoriBarang = 'Pakaian'; // Kategori default

  final List<String> _kategoriBarangList = [
    'Pakaian',
    'Elektronik',
    'Rumah Tangga',
    'Kesehatan',
    'Kecantikan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        actions: [
          TextButton(
            onPressed: () {
              // Logika simpan produk
              print('Simpan Produk ditekan');
            },
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Kategori Produk
            const Text(
              'Kategori Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCategoryTab(0, Icons.inventory_2_outlined, 'Produk Barang'),
                const SizedBox(width: 12),
                _buildCategoryTab(1, Icons.confirmation_number_outlined, 'Produk Voucher'),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildTextField('Nama Produk', 'Wajib', 'Masukkan nama produk...'),
            const SizedBox(height: 16),
            _buildTextField('Deskripsi Produk', 'Contoh: Baju Kaos Pria', 'Masukkan deskripsi produk...', isMultiLine: true),
            const SizedBox(height: 16),
            _buildPhotoUploadSection(),
            const SizedBox(height: 16),
            _buildDropdownField('Kategori Barang', _selectedKategoriBarang, _kategoriBarangList, (String? newValue) {
              setState(() {
                _selectedKategoriBarang = newValue;
              });
            }),
            const SizedBox(height: 16),
            _buildPriceStockSection(),
            const SizedBox(height: 16),
            _buildTextField('Berat (gr)', '500', 'Masukkan berat...', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Sku Produk', 'Contoh: SKU-001', 'Masukkan SKU...'),
            const SizedBox(height: 32),

            // Button: Simpan Produk
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logika simpan produk
                  print('Simpan Produk ditekan');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF337AB7), // Warna biru tombo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'SIMPAN PRODUK BARANG',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(int index, IconData icon, String label) {
    bool isSelected = _selectedCategoryIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F0F8) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF337AB7) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF337AB7) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF337AB7) : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String example, String placeholder, {bool isMultiLine = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: ' ($example)',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: isMultiLine ? 3 : 1,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Produk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Logika unggah foto
            print('Unggah Foto ditekan');
          },
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  'Unggah Foto',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceStockSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField('Harga Jual (Rp)', 'Contoh: Baju Kaos Pria', 'Masukkan harga...', keyboardType: TextInputType.number),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildTextField('Stok Jual', '1', 'Masukkan stok...', keyboardType: TextInputType.number),
        ),
      ],
    );
  }
}