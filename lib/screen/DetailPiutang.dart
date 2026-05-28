import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';

class DetailPiutang extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPiutang({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailPiutang> createState() => _DetailPiutangState();
}

class _DetailPiutangState extends State<DetailPiutang> {
  final Apidatapiutang apiService = Apidatapiutang();
  late Map<String, dynamic> currentData;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    currentData = widget.data;
    print('Data piutang: $currentData');
  }

  // Fungsi untuk memproses pelunasan
  Future<void> _prosesPelunasan() async {
    setState(() => isProcessing = true);
    try {
      bool success = await apiService.updateStatusLunas(currentData['id']);
      
      if (success) {
        setState(() {
          currentData['status'] = "Lunas";
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Status berhasil diperbarui menjadi Lunas"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Gagal memperbarui status");
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Format Rupiah dengan pemisah ribuan
  String _formatRupiah(dynamic angka) {
    int nominal = 0;
    if (angka is int) {
      nominal = angka;
    } else if (angka is String) {
      // Hapus semua non-digit
      String cleanNumber = angka.replaceAll(RegExp(r'[^0-9]'), '');
      nominal = int.tryParse(cleanNumber) ?? 0;
    } else if (angka is double) {
      nominal = angka.toInt();
    }
    
    // Format dengan pemisah ribuan
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(nominal);
  }

  // Format angka biasa (tanpa Rp) untuk jumlah
  String _formatNumber(dynamic angka) {
    int nominal = 0;
    if (angka is int) {
      nominal = angka;
    } else if (angka is String) {
      // Hapus semua non-digit
      String cleanNumber = angka.replaceAll(RegExp(r'[^0-9]'), '');
      nominal = int.tryParse(cleanNumber) ?? 0;
    } else if (angka is double) {
      nominal = angka.toInt();
    }
    
    // Format dengan pemisah ribuan (tanpa Rp)
    return NumberFormat('#,###').format(nominal);
  }

  // Format tanggal
  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      DateTime date = DateTime.parse(tanggal);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  // Hitung total hutang (jika ada harga dan jumlah hutang)
  int _getTotalHutang() {
    dynamic harga = currentData['harga'];
    dynamic jumlah = currentData['jumlah_hutang'];
    
    int hargaInt = 0;
    int jumlahInt = 0;
    
    // Parse harga
    if (harga is int) {
      hargaInt = harga;
    } else if (harga is String) {
      hargaInt = int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else if (harga is double) {
      hargaInt = harga.toInt();
    }
    
    // Parse jumlah
    if (jumlah is int) {
      jumlahInt = jumlah;
    } else if (jumlah is String) {
      jumlahInt = int.tryParse(jumlah.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else if (jumlah is double) {
      jumlahInt = jumlah.toInt();
    }
    
    // Jika data mengandung harga*jumlah, gunakan itu
    if (currentData['total'] != null) {
      dynamic total = currentData['total'];
      if (total is int) return total;
      if (total is String) return int.tryParse(total.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    
    // Jika tidak, hitung dari harga * jumlah
    return hargaInt * jumlahInt;
  }

  @override
  Widget build(BuildContext context) {
    bool isLunas = currentData['status']?.toString().toLowerCase() == "lunas";
    
    // Ambil data dengan aman
    String namaPelanggan = currentData['nama_pelanggan'] ?? '-';
    String namaBarang = currentData['nama_barang'] ?? '-';
    dynamic harga = currentData['harga'] ?? 0;
    dynamic jumlahHutang = currentData['jumlah_hutang'] ?? 0;
    String status = currentData['status'] ?? 'Belum Lunas';
    String tanggal = currentData['date'] ?? currentData['tanggal'] ?? '-';
    String pesanPenagihan = currentData['pesanpenagihan'] ?? currentData['pesan_penagihan'] ?? '-';
    String noWhatsapp = currentData['no_whatsapp'] ?? '-';
    
    // Hitung total hutang
    int totalHutang = _getTotalHutang();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    "DETAIL PIUTANG",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.receipt_long, size: 80, color: Color(0xFF5D48ED)),
              const SizedBox(height: 20),
              
              // Informasi Piutang
              _buildInfoRow("ID Transaksi", currentData['id']?.toString() ?? '-'),
              const SizedBox(height: 12),
              _buildInfoRow("Tanggal", _formatTanggal(tanggal)),
              const SizedBox(height: 12),
              _buildInfoRow("Pelanggan", namaPelanggan),
              const SizedBox(height: 12),
              _buildInfoRow("No WhatsApp", noWhatsapp),
              const SizedBox(height: 12),
              _buildInfoRow("Nama Barang", namaBarang),
              const SizedBox(height: 12),
              _buildInfoRow("Harga Satuan", _formatRupiah(harga)),
              const SizedBox(height: 12),
              // PERBAIKAN: Jumlah menggunakan format angka biasa (tanpa Rp)
              _buildInfoRow("Jumlah", _formatNumber(jumlahHutang)),
              const SizedBox(height: 12),
              _buildInfoRow("Total Hutang", _formatRupiah(totalHutang)),
              const SizedBox(height: 12),
              _buildStatusRow("Status", status),
              
              // Pesan Penagihan (jika ada)
              if (pesanPenagihan != '-' && pesanPenagihan.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 12),
                    _buildPesanRow("Pesan Penagihan", pesanPenagihan),
                  ],
                ),
              
              const SizedBox(height: 40),
              
              // TOMBOL AKSI
              isLunas 
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                        const SizedBox(width: 10),
                        Text(
                          "Transaksi ini telah lunas",
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isProcessing ? null : _showConfirmDialog,
                      icon: isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        "BAYAR LUNAS SEKARANG",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  // Row untuk info teks biasa
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  // Row khusus status dengan warna
  Widget _buildStatusRow(String label, String value) {
    bool lunas = value.toLowerCase() == "lunas";
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lunas ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              lunas ? "LUNAS" : "BELUM LUNAS",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: lunas ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Row khusus untuk pesan penagihan (multi-line)
  Widget _buildPesanRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pelunasan"),
        content: const Text("Apakah Anda yakin ingin mengubah status data ini menjadi LUNAS?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _prosesPelunasan();
            }, 
            child: const Text(
              "Ya, Lunas",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF00E5BC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterIcon(
            Icons.assignment,
            Colors.yellow[600]!,
            () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Laporanpenjualan())),
          ),
          _buildFooterIcon(
            Icons.home_outlined,
            const Color(0xFF1A437E),
            () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Landingpage())),
          ),
          _buildFooterIcon(
            Icons.payments_outlined,
            Colors.red,
            () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Laporankeuangan())),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, Color color, VoidCallback onTap) {
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
}