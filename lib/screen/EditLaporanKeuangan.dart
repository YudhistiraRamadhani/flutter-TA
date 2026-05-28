import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';

class EditLaporanKeuangan extends StatefulWidget {
  final PostTransaksi data;
  const EditLaporanKeuangan({super.key, required this.data});

  @override
  State<EditLaporanKeuangan> createState() => _EditLaporanKeuanganState();
}

class _EditLaporanKeuanganState extends State<EditLaporanKeuangan> {
  final _formKey = GlobalKey<FormState>();
  final Apitransaksi _api = Apitransaksi();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _jumlahController;
  late TextEditingController _tanggalController;
  late TextEditingController _deskripsiController;
  late TextEditingController _supplierController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.data.Nama_Barang);
    _hargaController = TextEditingController(text: widget.data.Harga);
    _jumlahController = TextEditingController(text: widget.data.Jumlah);
    _supplierController = TextEditingController(text: widget.data.nama_supplier);
    _deskripsiController = TextEditingController(text: widget.data.deskripsi);
    _tanggalController = TextEditingController(
      text: widget.data.Tanggal != null 
          ? DateFormat('yyyy-MM-dd').format(widget.data.Tanggal!) 
          : ""
    );
  }

  Future<void> _update() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isSaving = true);
    
    // Konversi string ke int agar validasi 'numeric' atau 'integer' di Laravel lolos
    Map<String, dynamic> body = {
      "nama_barang": _namaController.text,
      "harga": int.tryParse(_hargaController.text) ?? 0,
      "jumlah": int.tryParse(_jumlahController.text) ?? 0,
      "tanggal": _tanggalController.text,
      "nama_supplier": _supplierController.text,
      "deskripsi": _deskripsiController.text,
      "jenis_barang": widget.data.jenis_barang,
      "jenis_transaksi": widget.data.jenis_transaksi,
    };

    bool success = await _api.updateLaporanKeuangan(widget.data.id.toString(), body);

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil Update!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal Update (Cek Log Server)"), backgroundColor: Colors.red),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT DATA LAPORAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D48ED),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_namaController, "Nama Barang", Icons.inventory_2),
              const SizedBox(height: 15),
              _buildField(_hargaController, "Harga Satuan", Icons.attach_money, type: TextInputType.number),
              const SizedBox(height: 15),
              _buildField(_jumlahController, "Jumlah", Icons.production_quantity_limits, type: TextInputType.number),
              const SizedBox(height: 15),
              _buildField(_supplierController, "Supplier", Icons.person_pin),
              const SizedBox(height: 15),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Tanggal Transaksi",
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isSaving ? null : _update,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("UPDATE LAPORAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v!.isEmpty ? "Bidang ini wajib diisi" : null,
    );
  }
}