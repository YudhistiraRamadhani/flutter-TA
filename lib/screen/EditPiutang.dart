import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORT INI DITAMBAHKAN
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart';

class EditPiutang extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditPiutang({super.key, required this.data});

  @override
  State<EditPiutang> createState() => _EditPiutangState();
}

class _EditPiutangState extends State<EditPiutang> {
  final _formKey = GlobalKey<FormState>();
  final Apidatapiutang _apiService = Apidatapiutang();
  bool _isLoading = false;

  late TextEditingController _namaController;
  late TextEditingController _noWaController;
  late TextEditingController _barangController;
  late TextEditingController _hargaController;
  late TextEditingController _hutangController;
  late TextEditingController _tanggalController;
  late TextEditingController _pesanPenagihanController;
  String? _status;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi controller dengan data yang ada
    _namaController = TextEditingController(text: widget.data['nama_pelanggan']?.toString() ?? '');
    _noWaController = TextEditingController(text: widget.data['no_whatsapp']?.toString() ?? '');
    _barangController = TextEditingController(text: widget.data['nama_barang']?.toString() ?? '');
    _hargaController = TextEditingController(text: widget.data['harga']?.toString() ?? '0');
    _hutangController = TextEditingController(text: widget.data['jumlah_hutang']?.toString() ?? '0');
    _pesanPenagihanController = TextEditingController(text: widget.data['pesanpenagihan']?.toString() ?? widget.data['pesan_penagihan']?.toString() ?? '');
    _tanggalController = TextEditingController(text: widget.data['date']?.toString() ?? '');
    _status = widget.data['status']?.toString() ?? 'Belum Lunas';
    
    // Set selected date jika ada
    if (widget.data['date'] != null && widget.data['date'].toString().isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.data['date'].toString());
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      } catch (e) {
        _selectedDate = DateTime.now();
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }
    } else {
      _selectedDate = DateTime.now();
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
  }

  // Fungsi untuk memilih tanggal
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

  Future<void> _update() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Konversi data ke format yang sesuai dengan backend
      int hargaInt = int.tryParse(_hargaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int jumlahHutangInt = int.tryParse(_hutangController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      Map<String, dynamic> body = {
        "nama_pelanggan": _namaController.text,
        "no_whatsapp": _noWaController.text,
        "nama_barang": _barangController.text,
        "harga": hargaInt,
        "jumlah_hutang": jumlahHutangInt,
        "status": _status,
        "date": _tanggalController.text,
        "pesanpenagihan": _pesanPenagihanController.text,
      };

      // Hapus field yang nilainya null (optional)
      body.removeWhere((key, value) => value == null);

      bool success = await _apiService.updatePiutang(widget.data['id'].toString(), body);
      
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil Update Data"), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true); // True untuk trigger refresh di halaman list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal Update: Periksa inputan atau koneksi"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT PIUTANG"),
        backgroundColor: const Color(0xFF5D48ED),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Transaksi (Readonly, untuk info saja)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        const Text("ID Transaksi: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.data['id']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form Fields
                  _buildField(_namaController, "Nama Pelanggan *", Icons.person),
                  const SizedBox(height: 15),
                  
                  _buildField(_noWaController, "Nomor WhatsApp *", Icons.phone, type: TextInputType.phone),
                  const SizedBox(height: 15),
                  
                  _buildField(_barangController, "Nama Barang *", Icons.shopping_cart),
                  const SizedBox(height: 15),
                  
                  _buildField(_hargaController, "Harga Satuan *", Icons.money, isNumber: true),
                  const SizedBox(height: 15),
                  
                  _buildField(_hutangController, "Jumlah Hutang *", Icons.receipt, isNumber: true),
                  const SizedBox(height: 15),
                  
                  // Field Tanggal
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildField(_tanggalController, "Tanggal *", Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Dropdown Status
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: "Status *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Belum Lunas", child: Text("Belum Lunas")),
                      DropdownMenuItem(value: "Lunas", child: Text("Lunas")),
                    ],
                    onChanged: (v) => setState(() => _status = v),
                    validator: (v) => v == null ? "Status wajib dipilih" : null,
                  ),
                  const SizedBox(height: 15),
                  
                  // Pesan Penagihan (Text Area)
                  _buildField(
                    _pesanPenagihanController, 
                    "Pesan Penagihan", 
                    Icons.message,
                    lines: 4,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _update,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D48ED),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "SIMPAN PERUBAHAN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    TextInputType type = TextInputType.text, 
    bool isNumber = false,
    int lines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : type,
      maxLines: lines,
      inputFormatters: isNumber ? [
        FilteringTextInputFormatter.digitsOnly,
      ] : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        hintText: "Masukkan $label",
      ),
      validator: (v) {
        // Field yang wajib diisi (tanpa Pesan Penagihan)
        if (label != "Pesan Penagihan" && (v == null || v.isEmpty)) {
          return "Field ini wajib diisi";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noWaController.dispose();
    _barangController.dispose();
    _hargaController.dispose();
    _hutangController.dispose();
    _tanggalController.dispose();
    _pesanPenagihanController.dispose();
    super.dispose();
  }
}