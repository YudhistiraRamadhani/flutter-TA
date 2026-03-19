import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';

class Tambahdatapelanggan extends StatefulWidget {
  @override
  _TambahdatapelangganState createState() => _TambahdatapelangganState();
}

class _TambahdatapelangganState extends State<Tambahdatapelanggan> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nama_pelangganController = TextEditingController();
  final TextEditingController _no_whatsappController = TextEditingController();
  final TextEditingController _tanggal_notifikasiController = TextEditingController();
  final TextEditingController _pesannotifikasiController = TextEditingController();

  final apidatapelanggan api = apidatapelanggan();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker( //datepicker untuk memilih tanggal
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5E5CE6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggal_notifikasiController.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> simpanData() async {
    if (_formKey.currentState!.validate()) {
      bool success = await api.insertdatapelanggan(
        _nama_pelangganController.text,
        _no_whatsappController.text,
        _tanggal_notifikasiController.text,
        _pesannotifikasiController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nama_pelangganController.dispose();
    _no_whatsappController.dispose();
    _tanggal_notifikasiController.dispose();
    _pesannotifikasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                "TAMBAH DATA PELANGGAN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), // jarak dari tepi layar
          child: Card( // card untuk memberikan efek bayangan dan border radius
              elevation: 2, 
             shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildLabelField("Nama pelanggan"),
                    TextFormField(
                      controller: _nama_pelangganController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama pelanggan wajib diisi";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildLabelField("No whatsapp"),
                    TextFormField(
                      controller: _no_whatsappController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nomor WA wajib diisi";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildLabelField("pesan notifikasi promo"),
                    TextFormField(
                      controller: _pesannotifikasiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: " pesan promo ",
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              _buildLabelField("tanggal pengiriman"),

                              TextFormField(
                                controller: _tanggal_notifikasiController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: "Belum dipilih",
                                    border: UnderlineInputBorder()),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 35,
                            color: Color(0xFF5E5CE6),
                          ),
                          onPressed: () => _selectDate(context),
                        )
                      ],
                    ),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: simpanData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A437E),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "simpan",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            _buildCircleIcon(
              Icons.assignment,
              Colors.yellow,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Laporanpenjualan()),
              ),
            ),

            _buildCircleIcon(
              Icons.home_outlined,
              const Color(0xFF1A437E),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Landingpage()),
              ),
            ),

            _buildCircleIcon(
              Icons.payments_outlined,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Laporankeuangan()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color, VoidCallback onTap) {
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
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}