import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class formpiutang extends StatefulWidget {
  const formpiutang({super.key});

  @override
  State<formpiutang> createState() => _formpiutangState();
}

class _formpiutangState extends State<formpiutang> {
  final _formKey = GlobalKey<FormState>();
  final Apidatapiutang _apiService = Apidatapiutang();

  final _namaPelangganController = TextEditingController();
  final _noWaController = TextEditingController();
  final _namaBarangController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jumlahHutangController = TextEditingController();
  final _totalController = TextEditingController();
  final _pesanPenagihanController = TextEditingController();
  final _tanggalController = TextEditingController();

  List<Map<String, dynamic>> _pelangganList = [];
  List<Map<String, dynamic>> _produkList = [];
  bool _isSaving = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchDataPelanggan();
    _fetchDataProduk();
    _selectedDate = DateTime.now();
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    _pesanPenagihanController.text = "";
    
    _hargaController.addListener(_hitungTotal);
    _jumlahHutangController.addListener(_hitungTotal);
  }

  void _hitungTotal() {
    try {
      String hargaText = _hargaController.text;
      String jumlahText = _jumlahHutangController.text;
      
      int harga = 0;
      int jumlah = 0;
      
      if (hargaText.isNotEmpty) {
        String cleanHarga = hargaText.replaceAll(RegExp(r'[^0-9]'), '');
        harga = int.tryParse(cleanHarga) ?? 0;
      }
      
      if (jumlahText.isNotEmpty) {
        String cleanJumlah = jumlahText.replaceAll(RegExp(r'[^0-9]'), '');
        jumlah = int.tryParse(cleanJumlah) ?? 0;
      }
      
      int total = harga * jumlah;
      _totalController.text = _formatRupiah(total.toString());
    } catch (e) {
      print("Error hitung total: $e");
      _totalController.text = "Rp 0";
    }
  }

  void _fetchDataPelanggan() async {
    try {
      final data = await _apiService.getPelanggan();
      print('Data Pelanggan dari API: $data');
      
      if (mounted) {
        setState(() {
          _pelangganList = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetch pelanggan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data pelanggan: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _fetchDataProduk() async {
    try {
      final data = await _apiService.getProduk();
      print('Data Produk dari API: $data');
      
      if (mounted) {
        setState(() {
          _produkList = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetch produk: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data produk: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatRupiah(String angka) {
    if (angka.isEmpty) return "Rp 0";
    String cleanAngka = angka.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanAngka.isEmpty) return "Rp 0";
    int nominal = int.tryParse(cleanAngka) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(nominal);
  }

  String _formatNumber(dynamic number) {
    int parsedNumber = 0;
    if (number is int) {
      parsedNumber = number;
    } else if (number is String) {
      parsedNumber = int.tryParse(number) ?? 0;
    }
    return NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(parsedNumber);
  }

  int _parseHarga(dynamic harga) {
    if (harga is int) {
      return harga;
    } else if (harga is String) {
      return int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      int jumlahHutangInt = int.tryParse(_jumlahHutangController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int hargaInt = int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      String tanggal = _tanggalController.text;

      bool success = await _apiService.insertdatapiutang(
        _namaPelangganController.text,
        jumlahHutangInt,
        _namaBarangController.text,
        hargaInt,
        "Belum Lunas",
        _noWaController.text,
        _pesanPenagihanController.text,
        tanggal,
      );

      setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Simpan!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal Simpan!"), backgroundColor: Colors.red),
        );
      }
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
                    "TAMBAH DATA PIUTANG",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              const Text("Nama Pelanggan *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAutocompletePelanggan(),

              const SizedBox(height: 16),
              const Text("Nomor WhatsApp *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInput(_noWaController, "Contoh: 08123xxx", Icons.phone, type: TextInputType.phone),

              const SizedBox(height: 16),
              const Text("Nama Barang *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAutocompleteProduk(),

              const SizedBox(height: 16),
              const Text("Harga Satuan *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInput(_hargaController, "Harga otomatis terisi", Icons.money, type: TextInputType.number, isNumber: true, enabled: false),

              const SizedBox(height: 16),
              const Text("Jumlah *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInput(_jumlahHutangController, "Masukkan jumlah", Icons.receipt, type: TextInputType.number, isNumber: true),

              const SizedBox(height: 16),
              const Text("Total Hutang *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInput(_totalController, "Total otomatis", Icons.calculate, type: TextInputType.number, enabled: false),

              const SizedBox(height: 16),
              const Text("Tanggal *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: _buildInput(
                    _tanggalController, 
                    "Pilih tanggal", 
                    Icons.calendar_today,
                    type: TextInputType.datetime,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // const Text("Pesan Penagihan", style: TextStyle(fontWeight: FontWeight.bold)),
              // const SizedBox(height: 8),
              // _buildInput(
              //   _pesanPenagihanController, 
              //   "Ketik pesan penagihan di sini...", 
              //   Icons.message, 
              //   lines: 5,
              // ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SIMPAN DATA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
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
              color: Colors.yellow[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan())),
            ),
            _buildFooterIcon(
              icon: Icons.home_outlined,
              color: const Color(0xFF1A437E),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Laporankeuangan())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompletePelanggan() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), 
        borderRadius: BorderRadius.circular(4)
      ),
      child: Autocomplete<Map<String, dynamic>>(
        displayStringForOption: (option) => option['nama_pelanggan']?.toString() ?? '',
        optionsBuilder: (TextEditingValue textValue) {
          if (textValue.text.isEmpty) {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          return _pelangganList.where((p) {
            final namaPelanggan = p['nama_pelanggan']?.toString().toLowerCase() ?? '';
            return namaPelanggan.contains(textValue.text.toLowerCase());
          });
        },
        onSelected: (Map<String, dynamic> selection) {
          setState(() {
            _namaPelangganController.text = selection['nama_pelanggan']?.toString() ?? '';
            _noWaController.text = selection['no_whatsapp']?.toString() ?? '';
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          controller.text = _namaPelangganController.text;
          controller.addListener(() {
            _namaPelangganController.text = controller.text;
          });
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10), 
              border: InputBorder.none, 
              isDense: true,
              hintText: "Cari nama pelanggan...",
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    final namaPelanggan = option['nama_pelanggan']?.toString() ?? 'Tanpa Nama';
                    final noWhatsapp = option['no_whatsapp']?.toString() ?? '-';
                    return ListTile(
                      title: Text(namaPelanggan),
                      subtitle: Text(noWhatsapp),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAutocompleteProduk() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9), 
        borderRadius: BorderRadius.circular(4)
      ),
      child: Autocomplete<Map<String, dynamic>>(
        displayStringForOption: (option) => option['Nama_Barang']?.toString() ?? '',
        optionsBuilder: (TextEditingValue textValue) {
          if (textValue.text.isEmpty) {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          return _produkList.where((p) {
            final namaBarang = p['Nama_Barang']?.toString().toLowerCase() ?? '';
            return namaBarang.contains(textValue.text.toLowerCase());
          });
        },
        onSelected: (Map<String, dynamic> selection) {
          setState(() {
            _namaBarangController.text = selection['Nama_Barang']?.toString() ?? '';
            int harga = _parseHarga(selection['Harga']);
            _hargaController.text = harga.toString();
            _hitungTotal();
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          controller.text = _namaBarangController.text;
          controller.addListener(() {
            _namaBarangController.text = controller.text;
          });
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10), 
              border: InputBorder.none, 
              isDense: true,
              hintText: "Cari nama barang...",
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    final namaBarang = option['Nama_Barang']?.toString() ?? 'Tanpa Nama';
                    final harga = _parseHarga(option['Harga']);
                    final stok = option['Stok'] ?? 0;
                    final jenisBarang = option['jenis_barang']?.toString() ?? '';
                    
                    String subtitle = "Harga: Rp ${_formatNumber(harga)} | Stok: $stok";
                    if (jenisBarang.isNotEmpty) {
                      subtitle += " | $jenisBarang";
                    }
                    
                    return ListTile(
                      title: Text(namaBarang),
                      subtitle: Text(subtitle),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, 
      {TextInputType type = TextInputType.text, int lines = 1, bool isNumber = false, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: lines,
      enabled: enabled,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: enabled ? const Color(0xFFD9D9D9) : const Color(0xFFEEEEEE),
      ),
      validator: (v) {
        if (enabled && (v == null || v.isEmpty)) {
          if (controller == _pesanPenagihanController) {
            return null;
          }
          return "Wajib diisi";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _noWaController.dispose();
    _namaBarangController.dispose();
    _hargaController.dispose();
    _jumlahHutangController.dispose();
    _totalController.dispose();
    _pesanPenagihanController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
}