import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';
import 'package:flutter_application_1/model/postdatapelanggan.dart';

class DetailDatapelanggan extends StatefulWidget {
  final Postdatapelanggan pelanggan;
  const DetailDatapelanggan({super.key, required this.pelanggan});

  @override
  State<DetailDatapelanggan> createState() => _DetailDatapelangganState();
}

class _DetailDatapelangganState extends State<DetailDatapelanggan> {
  final apidatapelanggan api = apidatapelanggan();
  late TextEditingController _pesanController;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _pesanController = TextEditingController(text: widget.pelanggan.pesannotifikasi ?? "");
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  void _kirimPesanSingle() async {
    if (widget.pelanggan.no_whatsapp == null || widget.pelanggan.no_whatsapp!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor WhatsApp tidak valid!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_pesanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesan tidak boleh kosong!"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isSending = true);
    try {
      // Membungkus nomor WhatsApp ke dalam List<Map<String, String>>
      // karena API mengharapkan List, bukan String tunggal
      List<Map<String, String>> targetPelanggan = [
        {
          'id': widget.pelanggan.id.toString(),
          'nama': widget.pelanggan.nama_pelanggan ?? '',
          'nomor': widget.pelanggan.no_whatsapp!,
        }
      ];
      
      String pesanToSend = _pesanController.text.trim();
      
      // Menggunakan sendBatchBroadcast karena API mengharapkan List
      final result = await api.sendBatchBroadcast(targetPelanggan, pesanToSend);
      
      if (mounted) {
        setState(() => isSending = false);
        
        // PERBAIKAN: Mengecek null safety dengan aman
        int successCount = result['success'] ?? 0;
        int failCount = result['fail'] ?? 0;
        
        if (successCount > 0 && failCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Pesan berhasil dikirim via Fonnte!"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (successCount > 0 && failCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ Sebagian pesan terkirim: Berhasil $successCount, Gagal $failCount"),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Gagal mengirim pesan via Fonnte"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("DETAIL DATA PELANGGAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF5D48ED),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF5D48ED)),
                      title: const Text("Nama Pelanggan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(widget.pelanggan.nama_pelanggan ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone_android, color: Colors.green),
                      title: const Text("Nomor WhatsApp", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(widget.pelanggan.no_whatsapp ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.message, color: Color(0xFF5D48ED)),
                      title: const Text("Pesan Notifikasi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(widget.pelanggan.pesannotifikasi ?? "-", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Edit / Kirim Pesan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pesanController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tulis pesan disini...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5D48ED), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isSending ? null : _kirimPesanSingle,
                icon: isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_to_mobile),
                label: Text(isSending ? "MENGIRIM..." : "KIRIM VIA FONNTE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}