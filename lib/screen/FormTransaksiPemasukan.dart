import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:flutter_application_1/api/repository.dart';
import 'package:flutter_application_1/model/postproduk.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class FormTransaksiPemasukan extends StatefulWidget {
  const FormTransaksiPemasukan({super.key});

  @override
  State<FormTransaksiPemasukan> createState() => _FormTransaksiPemasukanState();
}

class _FormTransaksiPemasukanState extends State<FormTransaksiPemasukan> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyVoucher = GlobalKey<FormState>();
  final _formKeyBarang = GlobalKey<FormState>();
  
  final Apitransaksi _apiService = Apitransaksi();
  final Repository _produkRepo = Repository();

  // State Logic
  bool _isLoading = false;
  List<dynamic> _listVoucherRaw = [];
  List<Postproduk> _listProdukBarang = [];
  Map<String, dynamic>? _selectedVoucher;

  // Controllers Voucher
  final TextEditingController _vNamaController = TextEditingController();
  final TextEditingController _vHargaController = TextEditingController();
  final TextEditingController _vJumlahController = TextEditingController();
  final TextEditingController _vTglController = TextEditingController();
  final TextEditingController _vTotalController = TextEditingController();

  // Controllers Barang
  final TextEditingController _bNamaController = TextEditingController();
  final TextEditingController _bHargaController = TextEditingController();
  final TextEditingController _bJumlahController = TextEditingController();
  final TextEditingController _bTglController = TextEditingController();
  final TextEditingController _bTotalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Inisialisasi Tanggal
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _vTglController.text = today;
    _bTglController.text = today;

    // Load Data
    _fetchVoucherData();
    _loadProdukBarangData();

    // Listeners Total
    _vJumlahController.addListener(() => _hitungTotal('voucher'));
    _vHargaController.addListener(() => _hitungTotal('voucher'));
    _bJumlahController.addListener(() => _hitungTotal('barang'));
    _bHargaController.addListener(() => _hitungTotal('barang'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vNamaController.dispose(); _vHargaController.dispose(); _vJumlahController.dispose(); _vTglController.dispose(); _vTotalController.dispose();
    _bNamaController.dispose(); _bHargaController.dispose(); _bJumlahController.dispose(); _bTglController.dispose(); _bTotalController.dispose();
    super.dispose();
  }

  // --- LOGIC SECTION ---

  void _hitungTotal(String type) {
    if (type == 'voucher') {
      double harga = double.tryParse(_vHargaController.text) ?? 0;
      int jumlah = int.tryParse(_vJumlahController.text) ?? 0;
      _vTotalController.text = (harga * jumlah).toStringAsFixed(0);
    } else {
      int harga = int.tryParse(_bHargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int jumlah = int.tryParse(_bJumlahController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      _bTotalController.text = (harga * jumlah).toString();
    }
    setState(() {});
  }

  Future<void> _fetchVoucherData() async {
    try {
      final response = await http.get(Uri.parse('${_apiService.baseUrl}/produks-list'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        setState(() {
          _listVoucherRaw = data.where((item) {
            final jenis = item['jenis_barang']?.toString().toLowerCase() ?? '';
            return (jenis == 'voucher' || jenis == 'kartu provider');
          }).toList();
        });
      }
    } catch (e) { debugPrint("Error Voucher: $e"); }
  }

  Future<void> _loadProdukBarangData() async {
    try {
      final response = await _produkRepo.fetchPosts(1);
      var data = response['posts'];
      setState(() {
        if (data is List) {
          _listProdukBarang = data.map((e) => e is Postproduk ? e : Postproduk.fromJson(e)).toList();
        }
      });
    } catch (e) { debugPrint("Error Barang: $e"); }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _submitVoucher() async {
    if (!_formKeyVoucher.currentState!.validate() || _selectedVoucher == null) return;
    setState(() => _isLoading = true);
    
    bool success = await _apiService.insertTransaksi(
      _vNamaController.text, _vHargaController.text, _vJumlahController.text,
      _vTglController.text, _selectedVoucher!['jenis_barang'] ?? "Voucher",
      "Pemasukan", _selectedVoucher!['nama_supplier'] ?? "-", "Penjualan Voucher: ${_vNamaController.text}"
    );

    setState(() => _isLoading = false);
    if (success) {
      _showSnackBar("✅ Transaksi Voucher Berhasil!", Colors.green);
      Navigator.pop(context, true);
    } else {
      _showSnackBar("❌ Gagal simpan transaksi", Colors.red);
    }
  }

  Future<void> _submitBarang() async {
    if (!_formKeyBarang.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      var cekStok = await _apiService.cekStokProduk(_bNamaController.text.trim());
      if (!cekStok['found'] || cekStok['stok'] < (int.tryParse(_bJumlahController.text) ?? 0)) {
        _showSnackBar("❌ Stok tidak cukup! Sisa: ${cekStok['stok']}", Colors.red);
        return;
      }

      bool success = await _apiService.insertTransaksi(
        _bNamaController.text, _bHargaController.text, _bJumlahController.text,
        _bTglController.text, "Barang", "Pemasukan", "-", "Penjualan barang"
      );

      if (success) {
        _showSnackBar("✅ Penjualan Barang Berhasil!", Colors.green);
        _bNamaController.clear(); _bHargaController.clear(); _bJumlahController.clear();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                ListTile(
                  leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  title: const Text("TRANSAKSI PEMASUKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: "VOUCHER", icon: Icon(Icons.confirmation_number_outlined, size: 20)),
                    Tab(text: "BARANG", icon: Icon(Icons.inventory_2_outlined, size: 20)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormVoucher(),
          _buildFormBarang(),
        ],
      ),
      bottomNavigationBar: _buildCustomFooter(),
    );
  }

  Widget _buildFormVoucher() {
    return Form(
      key: _formKeyVoucher,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Autocomplete<Map<String, dynamic>>(
              displayStringForOption: (opt) => opt['Nama_Barang'] ?? '',
              optionsBuilder: (val) => val.text.isEmpty ? const Iterable.empty() : _listVoucherRaw.where((i) => i['Nama_Barang'].toString().toLowerCase().contains(val.text.toLowerCase())).map((e) => Map<String, dynamic>.from(e)),
              onSelected: (val) {
                _selectedVoucher = val;
                _vNamaController.text = val['Nama_Barang'];
                _vHargaController.text = val['Harga'].toString();
              },
              fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextFormField(
                controller: ctrl, focusNode: focus,
                decoration: const InputDecoration(labelText: "Cari Voucher", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                validator: (v) => v!.isEmpty ? "Pilih voucher" : null,
              ),
            ),
            const SizedBox(height: 15),
            _buildReadOnlyField(_vHargaController, "Harga Jual", Icons.payments, prefix: "Rp "),
            const SizedBox(height: 15),
            _buildTextField(_vJumlahController, "Jumlah Terjual", Icons.sell, isNumber: true),
            const SizedBox(height: 15),
            _buildReadOnlyField(_vTotalController, "Total Pendapatan", Icons.calculate, prefix: "Rp ", isBold: true),
            const SizedBox(height: 30),
            _buildSubmitButton("SIMPAN VOUCHER", _submitVoucher),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBarang() {
    return Form(
      key: _formKeyBarang,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Autocomplete<Postproduk>(
              displayStringForOption: (opt) => opt.Nama_Barang ?? '',
              optionsBuilder: (val) => val.text.isEmpty ? const Iterable.empty() : _listProdukBarang.where((p) => p.Nama_Barang!.toLowerCase().contains(val.text.toLowerCase())),
              onSelected: (val) {
                _bNamaController.text = val.Nama_Barang!;
                _bHargaController.text = val.Harga.toString();
              },
              fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextFormField(
                controller: ctrl, focusNode: focus,
                decoration: const InputDecoration(labelText: "Nama Barang", border: OutlineInputBorder(), prefixIcon: Icon(Icons.shopping_bag)),
                validator: (v) => v!.isEmpty ? "Pilih barang" : null,
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(_bHargaController, "Harga Jual", Icons.payments_outlined, isNumber: true, prefix: "Rp "),
            const SizedBox(height: 15),
            _buildTextField(_bJumlahController, "Jumlah Terjual", Icons.format_list_numbered, isNumber: true),
            const SizedBox(height: 15),
            _buildReadOnlyField(_bTotalController, "Total Pendapatan", Icons.calculate_outlined, prefix: "Rp "),
            const SizedBox(height: 30),
            _buildSubmitButton("SIMPAN BARANG", _submitBarang),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, String? prefix}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon), prefixText: prefix),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _buildReadOnlyField(TextEditingController ctrl, String label, IconData icon, {String? prefix, bool isBold = false}) {
    return TextFormField(
      controller: ctrl, readOnly: true,
      style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.green : Colors.black),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon), prefixText: prefix, filled: true, fillColor: Colors.grey[50]),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPres) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: FilledButton(
        onPressed: _isLoading ? null : onPres,
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5D48ED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCustomFooter() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFF00E5BC), borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _footerIcon(Icons.assignment, const Color(0xFFFDB515), () => Navigator.push(context, MaterialPageRoute(builder: (c) => Laporanpenjualan()))),
          _footerIcon(Icons.home_outlined, const Color(0xFF1A437E), () => Navigator.push(context, MaterialPageRoute(builder: (c) => const Landingpage()))),
          _footerIcon(Icons.payments_outlined, const Color(0xFFE51C23), () => Navigator.push(context, MaterialPageRoute(builder: (c) => Laporankeuangan()))),
        ],
      ),
    );
  }

  Widget _footerIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.5)),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}