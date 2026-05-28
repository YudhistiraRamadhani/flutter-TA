import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:flutter_application_1/api/repository.dart';
import 'package:flutter_application_1/model/postproduk.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransaksiPemasukan extends StatefulWidget {
  const TransaksiPemasukan({super.key});

  @override
  State<TransaksiPemasukan> createState() => _TransaksiPemasukanState();
}

class _TransaksiPemasukanState extends State<TransaksiPemasukan> {
  int _selectedTab = 0; // 0 = Barang, 1 = Voucher
  
  // Controller untuk form Barang
  final _formKeyBarang = GlobalKey<FormState>();
  final Apitransaksi _apiService = Apitransaksi();
  final Repository _produkRepo = Repository();
  
  bool _isLoadingBarang = false;
  List<Postproduk> _listProduk = [];
  String _selectedJenisBarang = "Barang";

  final TextEditingController _namaControllerBarang = TextEditingController();
  final TextEditingController _hargaControllerBarang = TextEditingController();
  final TextEditingController _jumlahControllerBarang = TextEditingController();
  final TextEditingController _tglControllerBarang = TextEditingController();
  final TextEditingController _totalControllerBarang = TextEditingController();

  // Controller untuk form Voucher
  final _formKeyVoucher = GlobalKey<FormState>();
  
  List<Map<String, dynamic>> _listVoucher = [];
  Map<String, dynamic>? _selectedVoucher;
  bool _isFetchingVoucher = true;
  bool _isSavingVoucher = false;

  final TextEditingController _namaControllerVoucher = TextEditingController();
  final TextEditingController _hargaControllerVoucher = TextEditingController();
  final TextEditingController _jumlahControllerVoucher = TextEditingController();
  final TextEditingController _tanggalControllerVoucher = TextEditingController();
  final TextEditingController _totalControllerVoucher = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi form Barang
    _loadProdukData();
    _tglControllerBarang.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _jumlahControllerBarang.addListener(_hitungTotalBarang);
    _hargaControllerBarang.addListener(_hitungTotalBarang);

    // Inisialisasi form Voucher
    _tanggalControllerVoucher.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchVoucherData();
    _jumlahControllerVoucher.addListener(_hitungTotalVoucher);
    _hargaControllerVoucher.addListener(_hitungTotalVoucher);
  }

  @override
  void dispose() {
    // Dispose form Barang
    _jumlahControllerBarang.removeListener(_hitungTotalBarang);
    _hargaControllerBarang.removeListener(_hitungTotalBarang);
    _namaControllerBarang.dispose();
    _hargaControllerBarang.dispose();
    _jumlahControllerBarang.dispose();
    _tglControllerBarang.dispose();
    _totalControllerBarang.dispose();

    // Dispose form Voucher
    _jumlahControllerVoucher.removeListener(_hitungTotalVoucher);
    _namaControllerVoucher.dispose();
    _hargaControllerVoucher.dispose();
    _jumlahControllerVoucher.dispose();
    _totalControllerVoucher.dispose();
    _tanggalControllerVoucher.dispose();
    
    super.dispose();
  }

  // ==================== FUNGSI FORM BARANG ====================
  
  Future<void> _loadProdukData() async {
    try {
      final response = await _produkRepo.fetchPosts(1);
      setState(() {
        var data = response['posts'];
        if (data is List) {
          if (data.isNotEmpty && data.first is Postproduk) {
            _listProduk = data.cast<Postproduk>();
          } else {
            _listProduk = data.map((e) => Postproduk.fromJson(e)).toList();
          }
        }
      });
    } catch (e) {
      debugPrint("❌ Gagal memuat produk: $e");
    }
  }

  // Helper method untuk filter barang (exclude voucher dan kartu provider)
  List<Postproduk> _getFilteredBarang() {
    return _listProduk.where((produk) {
      String jenis = produk.jenis_barang?.toLowerCase() ?? '';
      return jenis != 'voucher' && jenis != 'kartu provider';
    }).toList();
  }

  void _hitungTotalBarang() {
    int harga = int.tryParse(_hargaControllerBarang.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int jumlah = int.tryParse(_jumlahControllerBarang.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      _totalControllerBarang.text = (harga * jumlah).toString();
    });
  }

  Future<void> _simpanPenjualanBarang() async {
    if (_formKeyBarang.currentState!.validate()) {
      setState(() => _isLoadingBarang = true);

      try {
        String hargaBersih = _hargaControllerBarang.text.replaceAll(RegExp(r'[^0-9]'), '');
        String jumlahBersih = _jumlahControllerBarang.text.replaceAll(RegExp(r'[^0-9]'), '');
        String namaBarang = _namaControllerBarang.text.trim();
        int jumlahInt = int.tryParse(jumlahBersih) ?? 0;
        int hargaInt = int.tryParse(hargaBersih) ?? 0;

        var cekStok = await _apiService.cekStokProduk(namaBarang);
        
        if (!cekStok['found']) {
          _showSnackBar("❌ Produk tidak ditemukan!", Colors.red);
          setState(() => _isLoadingBarang = false);
          return;
        }
        
        int stokTersedia = cekStok['stok'];
        if (stokTersedia < jumlahInt) {
          _showSnackBar("❌ Stok tidak cukup! Sisa: $stokTersedia", Colors.red);
          setState(() => _isLoadingBarang = false);
          return;
        }

        bool success = await _apiService.insertTransaksi(
          namaBarang,
          hargaBersih,
          jumlahBersih,
          _tglControllerBarang.text,
          _selectedJenisBarang,
          "Pemasukan",
          "-",
          "Penjualan barang",
        );

        if (!mounted) return;

        if (success) {
          _showSnackBar(
            "✅ Penjualan berhasil!\nStok berkurang $jumlahInt", 
            Colors.green
          );
          _clearFormBarang();
          _loadProdukData();
        } else {
          _showSnackBar("❌ Gagal menyimpan transaksi", Colors.red);
        }
      } catch (e) {
        _showSnackBar("Terjadi kesalahan: $e", Colors.red);
      } finally {
        if (mounted) setState(() => _isLoadingBarang = false);
      }
    }
  }

  void _clearFormBarang() {
    _namaControllerBarang.clear();
    _hargaControllerBarang.clear();
    _jumlahControllerBarang.clear();
    _totalControllerBarang.clear();
    _tglControllerBarang.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // ==================== FUNGSI FORM VOUCHER ====================
  
  void _hitungTotalVoucher() {
    double harga = double.tryParse(_hargaControllerVoucher.text) ?? 0;
    int jumlah = int.tryParse(_jumlahControllerVoucher.text) ?? 0;
    setState(() {
      _totalControllerVoucher.text = (harga * jumlah).toStringAsFixed(0);
    });
  }

  Future<void> _fetchVoucherData() async {
    try {
      final response = await http.get(Uri.parse('${_apiService.baseUrl}/produks-list'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        
        setState(() {
          _listVoucher = data.where((item) {
            final jenis = item['jenis_barang']?.toString().toLowerCase() ?? '';
            return (jenis == 'voucher' || jenis == 'kartu provider');
          }).map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      print("Koneksi Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isFetchingVoucher = false);
      }
    }
  }

  Future<void> _simpanPenjualanVoucher() async {
    if (!_formKeyVoucher.currentState!.validate()) return;

    if (_selectedVoucher == null) {
      _showSnackBar("⚠️ Silakan pilih voucher dari hasil pencarian", Colors.orange);
      return;
    }

    int jumlahInt = int.tryParse(_jumlahControllerVoucher.text) ?? 0;
    if (jumlahInt <= 0) {
      _showSnackBar("⚠️ Jumlah harus lebih dari 0", Colors.orange);
      return;
    }

    setState(() => _isSavingVoucher = true);

    bool success = await _apiService.insertTransaksi(
      _namaControllerVoucher.text,
      _hargaControllerVoucher.text,
      _jumlahControllerVoucher.text,
      _tanggalControllerVoucher.text,
      _selectedVoucher!['jenis_barang'] ?? "Voucher",
      "Pemasukan",
      _selectedVoucher!['nama_supplier'] ?? "-",
      "Penjualan Voucher: ${_namaControllerVoucher.text}",
    );

    setState(() => _isSavingVoucher = false);

    if (success) {
      String jumlah = _jumlahControllerVoucher.text;
      String namaVoucher = _namaControllerVoucher.text;
      
      _showSnackBar(
        "✅ Transaksi berhasil!\nStok Voucher '$namaVoucher' berkurang $jumlah unit", 
        Colors.green
      );
      _clearFormVoucher();
    } else {
      _showSnackBar("❌ Gagal menyimpan transaksi", Colors.red);
    }
  }

  void _clearFormVoucher() {
    _namaControllerVoucher.clear();
    _hargaControllerVoucher.clear();
    _jumlahControllerVoucher.clear();
    _totalControllerVoucher.clear();
    _selectedVoucher = null;
    _tanggalControllerVoucher.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // ==================== FUNGSI UMUM ====================
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // ==================== BUILD FORM BARANG ====================
  
  Widget _buildFormBarang() {
    // Filter produk untuk form Barang (exclude voucher & kartu provider)
    List<Postproduk> filteredBarang = _getFilteredBarang();
    
    return Form(
      key: _formKeyBarang,
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Autocomplete<Postproduk>(
            displayStringForOption: (Postproduk option) => option.Nama_Barang ?? '',
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Postproduk>.empty();
              // Gunakan filteredBarang untuk autocomplete
              return filteredBarang.where((p) => p.Nama_Barang!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (Postproduk selection) {
              setState(() {
                _namaControllerBarang.text = selection.Nama_Barang ?? '';
                _hargaControllerBarang.text = selection.Harga.toString();
                _selectedJenisBarang = selection.jenis_barang ?? "Barang";
              });
              _hitungTotalBarang();
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              if (textController.text.isEmpty && _namaControllerBarang.text.isNotEmpty) {
                textController.text = _namaControllerBarang.text;
              }
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                onChanged: (value) => _namaControllerBarang.text = value,
                decoration: const InputDecoration(
                  labelText: "Nama Barang *",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  helperText: "Hanya menampilkan produk (bukan voucher/kartu)",
                ),
                validator: (v) => v!.isEmpty ? "Nama barang wajib diisi" : null,
              );
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _hargaControllerBarang,
            readOnly: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Harga Jual *",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.payments_outlined),
              prefixText: "Rp ",
            ),
            validator: (v) => v!.isEmpty ? "Harga wajib diisi" : null,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _jumlahControllerBarang,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Jumlah Terjual *",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_list_numbered),
              helperText: "Stok akan berkurang sesuai jumlah ini",
            ),
            validator: (v) {
              if (v!.isEmpty) return "Jumlah wajib diisi";
              if ((int.tryParse(v) ?? 0) <= 0) return "Jumlah minimal 1";
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _totalControllerBarang,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Total Pendapatan",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calculate_outlined),
              prefixText: "Rp ",
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _tglControllerBarang,
            readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context, 
                initialDate: DateTime.now(), 
                firstDate: DateTime(2000), 
                lastDate: DateTime(2101)
              );
              if (picked != null) {
                setState(() => _tglControllerBarang.text = DateFormat('yyyy-MM-dd').format(picked));
              }
            },
            decoration: const InputDecoration(
              labelText: "Tanggal Transaksi", 
              border: OutlineInputBorder(), 
              prefixIcon: Icon(Icons.calendar_today_outlined)
            ),
          ),
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              onPressed: _isLoadingBarang ? null : _simpanPenjualanBarang,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5D48ED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoadingBarang
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SIMPAN PENJUALAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD FORM VOUCHER ====================
  
  Widget _buildFormVoucher() {
    return _isFetchingVoucher
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKeyVoucher,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                Autocomplete<Map<String, dynamic>>(
                  displayStringForOption: (option) => option['Nama_Barang'] ?? '',
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable.empty();
                    }
                    return _listVoucher.where((item) {
                      String nama = item['Nama_Barang']?.toString().toLowerCase() ?? '';
                      return nama.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (Map<String, dynamic> value) {
                    setState(() {
                      _selectedVoucher = value;
                      _namaControllerVoucher.text = value['Nama_Barang'] ?? '';
                      _hargaControllerVoucher.text = value['Harga']?.toString() ?? '0';
                      _hitungTotalVoucher();
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
                        helperText: "Hanya menampilkan voucher dan kartu provider",
                      ),
                      validator: (v) => v!.isEmpty ? "Pilih barang dulu" : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _hargaControllerVoucher,
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
                  controller: _jumlahControllerVoucher,
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
                  controller: _totalControllerVoucher,
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
                  controller: _tanggalControllerVoucher,
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
                        _tanggalControllerVoucher.text = DateFormat('yyyy-MM-dd').format(picked);
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
                    onPressed: _isSavingVoucher ? null : _simpanPenjualanVoucher,
                    child: _isSavingVoucher
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SIMPAN PENJUALAN", 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
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
                    "TRANSAKSI PENJUALAN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFF5D48ED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Penjualan Barang",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFF5D48ED) : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Penjualan Voucher",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _selectedTab == 0 ? _buildFormBarang() : _buildFormVoucher(),
            ),
          ),
        ],
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined, 
              color: const Color(0xFF1A437E), 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage()))
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined, 
              color: const Color(0xFFE51C23), 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporankeuangan()))
            ),
          ],
        ),
      ),
    );
  }
}