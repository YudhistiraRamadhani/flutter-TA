import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/postdatapelanggan.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';

class EditDatapelanggan extends StatefulWidget {
  final Postdatapelanggan pelanggan;

  const EditDatapelanggan({Key? key, required this.pelanggan}) : super(key: key);

  @override
  _EditDatapelangganState createState() => _EditDatapelangganState();
}

class _EditDatapelangganState extends State<EditDatapelanggan> {
  final apidatapelanggan api = apidatapelanggan();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk menampung inputan
  late TextEditingController _namaController;
  late TextEditingController _waController;
  late TextEditingController _notifController;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data lama pelanggan berdasarkan ID yang dipilih
    _namaController = TextEditingController(text: widget.pelanggan.nama_pelanggan);
    _waController = TextEditingController(text: widget.pelanggan.no_whatsapp);
    _notifController = TextEditingController(text: widget.pelanggan.pesannotifikasi);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose();
    _notifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "EDIT DATA PELANGGAN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 48), 
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Pelanggan", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),
              const Text("No. WhatsApp", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _waController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                validator: (value) => value!.isEmpty ? "Nomor WA tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),
              const Text("Pesan Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notifController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),
              
              // TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D48ED),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // 1. Tampilkan Loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // 2. Siapkan Data
                      Map<String, dynamic> dataUpdate = {
                        "nama_pelanggan": _namaController.text,
                        "no_whatsapp": _waController.text,
                        "pesannotifikasi": _notifController.text,
                      };

                      // 3. Eksekusi API
                      // Pastikan di apidatapelanggan.dart fungsi updatePelanggan sudah menggunakan jsonEncode
                      bool success = await api.updatePelanggan(
                        widget.pelanggan.id.toString(), 
                        dataUpdate
                      );

                      if (mounted) {
                        Navigator.pop(context); // Tutup loading

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Data pelanggan berhasil diperbarui")),
                          );
                          // Kembali ke Datapelanggan.dart dan memicu loadData()
                          Navigator.pop(context, true); 
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Gagal memperbarui data. Cek koneksi server.")),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    "SIMPAN PERUBAHAN", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}