import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class TransaksipemasukanVoucher extends StatefulWidget {
  const TransaksipemasukanVoucher({super.key});

  @override
  State<TransaksipemasukanVoucher> createState() =>
      _TransaksipemasukanVoucherState();
}

class _TransaksipemasukanVoucherState extends State<TransaksipemasukanVoucher> {
  final _formKey = GlobalKey<FormState>();
  final Apitransaksi apiService = Apitransaksi();

  List<dynamic> _listVoucher = [];
  Map<String, dynamic>? _selectedVoucher;

  bool _isFetching = true;
  bool _isSaving = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchVoucher();
    _jumlahController.addListener(_hitungTotal);
    _hargaController.addListener(_hitungTotal);
  }

  @override
  void dispose() {
    _jumlahController.removeListener(_hitungTotal);
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _totalController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  void _hitungTotal() {
    double harga = double.tryParse(_hargaController.text) ?? 0;
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;

    setState(() {
      _totalController.text = (harga * jumlah).toStringAsFixed(0);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _fetchVoucher() async {
    try {
      final response = await http.get(Uri.parse('${apiService.baseUrl}/produks-list'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        
        setState(() {
          _listVoucher = data.where((item) {
            final jenis = item['jenis_barang']?.toString().toLowerCase() ?? '';
            return (jenis == 'voucher' || jenis == 'kartu provider');
          }).toList();
        });
      }
    } catch (e) {
      print("Koneksi Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVoucher == null) {
      _showSnackBar("⚠️ Silakan pilih voucher dari hasil pencarian", Colors.orange);
      return;
    }

    int jumlahInt = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlahInt <= 0) {
      _showSnackBar("⚠️ Jumlah harus lebih dari 0", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    bool success = await apiService.insertTransaksi(
      _namaController.text,
      _hargaController.text,
      _jumlahController.text,
      _tanggalController.text,
      _selectedVoucher!['jenis_barang'] ?? "Voucher",
      "Pemasukan",
      _selectedVoucher!['nama_supplier'] ?? "-",
      "Penjualan Voucher: ${_namaController.text}",
    );

    setState(() => _isSaving = false);

    if (success) {
      String jumlah = _jumlahController.text;
      String namaVoucher = _namaController.text;
      
      _showSnackBar(
        "✅ Transaksi berhasil!\nStok Voucher '$namaVoucher' berkurang $jumlah unit", 
        Colors.green
      );
      Navigator.pop(context, true);
    } else {
      _showSnackBar("❌ Gagal menyimpan transaksi", Colors.red);
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
        child: Icon(icon, color: Colors.white, size: 28),
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
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: Text(
                    "TRANSAKSI PENJUALAN VOUCHER",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // AUTOCOMPLETE VOUCHER
                    Autocomplete<Map<String, dynamic>>(
                      displayStringForOption: (option) => option['Nama_Barang'] ?? '',
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable.empty();
                        }
                        return _listVoucher.where((item) {
                          String nama = item['Nama_Barang']?.toString().toLowerCase() ?? '';
                          return nama.contains(textEditingValue.text.toLowerCase());
                        }).map((e) => Map<String, dynamic>.from(e));
                      },
                      onSelected: (Map<String, dynamic> value) {
                        setState(() {
                          _selectedVoucher = value;
                          _namaController.text = value['Nama_Barang'] ?? '';
                          _hargaController.text = value['Harga']?.toString() ?? '0';
                          _hitungTotal();
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Cari Nama Voucher / Kartu",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            hintText: "Ketik nama barang...",
                          ),
                          validator: (v) => v!.isEmpty ? "Pilih barang dulu" : null,
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _hargaController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Harga Jual",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments),
                        prefixText: "Rp ",
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Jumlah Terjual",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sell_outlined),
                        helperText: "Stok akan berkurang sesuai jumlah ini",
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return "Isi jumlah";
                        int jumlah = int.tryParse(v) ?? 0;
                        if (jumlah <= 0) return "Jumlah minimal 1";
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _totalController,
                      readOnly: true,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      decoration: InputDecoration(
                        labelText: "Total Pendapatan",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calculate),
                        prefixText: "Rp ",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D48ED),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SIMPAN PENJUALAN", 
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              color: const Color(0xFFFDB515),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan())),
            ),
            _buildFooterIcon(
              icon: Icons.home,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments,
              color: const Color(0xFFE51C23),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }
}