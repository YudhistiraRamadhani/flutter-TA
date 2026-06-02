import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apidatapelanggan.dart';
import 'package:flutter_application_1/model/postdatapelanggan.dart';
import 'package:flutter_application_1/screen/Tambahdatapelanggan.dart';
import 'package:flutter_application_1/screen/EditDatapelanggan.dart';
import 'package:flutter_application_1/screen/DetailDatapelanggan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';

class Datapelanggan extends StatefulWidget {
  const Datapelanggan({super.key});

  @override
  State<Datapelanggan> createState() => _DatapelangganState();
}

class _DatapelangganState extends State<Datapelanggan> {
  final apidatapelanggan api = apidatapelanggan();
  List<Postdatapelanggan> pelanggan = [];
  List<Postdatapelanggan> filteredPelanggan = [];
  List<String> selectedPelanggan = []; 
  
  bool isLoading = true;
  
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await api.fetchTransaksi(1);
      setState(() {
        pelanggan = data['datapelanggan'];
        filteredPelanggan = pelanggan;
        selectedPelanggan.clear(); 
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  void _filterSearch(String query) {
    setState(() {
      filteredPelanggan = pelanggan
          .where((item) =>
              item.nama_pelanggan!.toLowerCase().contains(query.toLowerCase()) ||
              item.no_whatsapp!.contains(query))
          .toList();
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedPelanggan = filteredPelanggan
            .map((item) => item.id.toString())
            .toList();
      } else {
        selectedPelanggan.clear();
      }
    });
  }

  void _onCheckboxChanged(String id, bool? value) {
    setState(() {
      if (value == true) {
        if (!selectedPelanggan.contains(id)) {
          selectedPelanggan.add(id);
        }
      } else {
        selectedPelanggan.remove(id);
      }
    });
  }

  void _showSendMessageDialog() {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final waController = TextEditingController();
    final pesanController = TextEditingController();
    
    TextEditingController? autocompleteNamaController;
    TextEditingController? autocompleteWaController;
    Postdatapelanggan? selectedPelangganData;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.send, color: Colors.blue),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Kirim Pesan ke Pelanggan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cari Pelanggan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Autocomplete<Postdatapelanggan>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<Postdatapelanggan>.empty();
                          return pelanggan.where((p) => 
                            p.nama_pelanggan!.toLowerCase().contains(textEditingValue.text.toLowerCase())
                          );
                        },
                        displayStringForOption: (Postdatapelanggan option) => option.nama_pelanggan ?? '',
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          autocompleteNamaController = textEditingController;
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              hintText: "Ketik nama pelanggan...", 
                              border: OutlineInputBorder(), 
                              prefixIcon: Icon(Icons.person, size: 20),
                              suffixIcon: Icon(Icons.search, size: 20),
                            ),
                            validator: (v) => selectedPelangganData == null && v!.trim().isEmpty 
                                ? "Pilih pelanggan terlebih dahulu" 
                                : null,
                            onChanged: (val) {
                              namaController.text = val;
                              if (selectedPelangganData != null) {
                                setDialogState(() {
                                  selectedPelangganData = null;
                                });
                              }
                            },
                          );
                        },
                        onSelected: (Postdatapelanggan selected) {
                          setDialogState(() {
                            selectedPelangganData = selected;
                          });
                          namaController.text = selected.nama_pelanggan ?? '';
                          waController.text = selected.no_whatsapp ?? '';
                          pesanController.text = selected.pesannotifikasi ?? '';
                          if (autocompleteWaController != null) {
                            autocompleteWaController!.text = selected.no_whatsapp ?? '';
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text("Nomor WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Autocomplete<Postdatapelanggan>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<Postdatapelanggan>.empty();
                          return pelanggan.where((p) => p.no_whatsapp!.contains(textEditingValue.text));
                        },
                        displayStringForOption: (Postdatapelanggan option) => option.no_whatsapp ?? '',
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          autocompleteWaController = textEditingController;
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: "Ketik nomor WA...", 
                              border: OutlineInputBorder(), 
                              prefixIcon: Icon(Icons.phone, size: 20),
                              suffixIcon: Icon(Icons.search, size: 20),
                            ),
                            validator: (v) => v!.trim().isEmpty ? "Nomor WA wajib diisi" : null,
                            onChanged: (val) {
                              waController.text = val;
                              if (selectedPelangganData != null) {
                                setDialogState(() {
                                  selectedPelangganData = null;
                                });
                              }
                            },
                          );
                        },
                        onSelected: (Postdatapelanggan selected) {
                          setDialogState(() {
                            selectedPelangganData = selected;
                          });
                          waController.text = selected.no_whatsapp ?? '';
                          namaController.text = selected.nama_pelanggan ?? '';
                          pesanController.text = selected.pesannotifikasi ?? '';
                          if (autocompleteNamaController != null) {
                            autocompleteNamaController!.text = selected.nama_pelanggan ?? '';
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text("Isi Pesan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: pesanController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: "Tulis pesan yang akan dikirim...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (v) => v!.trim().isEmpty ? "Pesan tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Pesan akan dikirim ke nomor WhatsApp pelanggan yang dipilih",
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (selectedPelangganData == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Silakan pilih pelanggan dari daftar autocomplete"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      String nomorTujuan = waController.text.trim();
                      String pesanToSend = pesanController.text.trim();
                      String namaPelanggan = namaController.text.trim();
                      
                      Navigator.pop(context);
                      
                      try {
                        bool success = await api.sendBroadcast(nomorTujuan, pesanToSend);
                        
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("✅ Pesan berhasil dikirim ke $namaPelanggan"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Gagal mengirim pesan. Cek koneksi internet dan log console."),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("❌ Error: $e"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("KIRIM PESAN"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBroadcastConfirmationDialog() {
    final pesanController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    List<Map<String, String>> targetPelanggan = [];
    
    for (String id in selectedPelanggan) {
      final p = pelanggan.firstWhere((item) => item.id.toString() == id);
      targetPelanggan.add({
        'id': id,
        'nama': p.nama_pelanggan ?? '-',
        'nomor': p.no_whatsapp ?? '',
      });
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.campaign, color: Colors.green),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Broadcast Pesan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📊 Ringkasan Pengiriman",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Target pengiriman: ${targetPelanggan.length} pelanggan",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Detail: ${targetPelanggan.take(3).map((p) => p['nama']).join(', ')}${targetPelanggan.length > 3 ? '...' : ''}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: targetPelanggan.map((p) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  "• ${p['nama']}: ${p['nomor']}",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "✏️ Isi Pesan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: pesanController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tulis pesan yang akan dikirim...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Pesan tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Pesan akan dikirim ke semua pelanggan yang dipilih",
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                String pesanToSend = pesanController.text.trim();
                
                final result = await api.sendBatchBroadcast(targetPelanggan, pesanToSend);
                
                if (mounted) {
                  setState(() {
                    selectedPelanggan.clear();
                  });
                  
                  String message = "✅ Berhasil: ${result['success']}, ❌ Gagal: ${result['fail']}";
                  
                  await loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: result['success']! > 0 ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              }
            },
            child: const Text("KIRIM KE SEMUA"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus pelanggan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              bool success = await api.deletePelanggan(id);
              if (success) {
                if (mounted) {
                  Navigator.pop(context);
                  loadData();
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, 
        height: 50,
        decoration: BoxDecoration(
          color: color, 
          shape: BoxShape.circle, 
          border: Border.all(color: Colors.black, width: 1.5)
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = filteredPelanggan.isNotEmpty && 
                         selectedPelanggan.length == filteredPelanggan.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5D48ED), 
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(70))
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
                    "DATA PELANGGAN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterSearch,
                    decoration: InputDecoration(
                      hintText: "Cari Nama atau WhatsApp...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                
                CheckboxListTile(
                  title: const Text("Pilih Semua", style: TextStyle(fontSize: 14)),
                  value: isAllSelected,
                  onChanged: _toggleSelectAll,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Tambahdatapelanggan())).then((v) => loadData()),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text("TAMBAH DATA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D48ED), 
                              foregroundColor: Colors.white, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: _showSendMessageDialog,
                            icon: const Icon(Icons.send, color: Colors.white, size: 18),
                            label: const Text("KIRIM PESAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, 
                              foregroundColor: Colors.white, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                        columns: const [
                          DataColumn(label: Text('PILIH')),
                          DataColumn(label: Text('NAMA')),
                          DataColumn(label: Text('WHATSAPP')),
                          DataColumn(label: Text('PESAN PROMO')),
                          DataColumn(label: Text('AKSI')),
                        ],
                        rows: filteredPelanggan.map((item) {
                          final isSelected = selectedPelanggan.contains(item.id.toString());
                          final bool hasPromo = item.pesannotifikasi != null && item.pesannotifikasi!.isNotEmpty;

                          return DataRow(
                            selected: isSelected,
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: isSelected, 
                                  onChanged: (val) => _onCheckboxChanged(item.id.toString(), val),
                                )
                              ),
                              DataCell(Text(item.nama_pelanggan ?? "-")),
                              DataCell(Text(item.no_whatsapp ?? "-")),
                              DataCell(
                                Icon(
                                  hasPromo ? Icons.chat_bubble : Icons.chat_bubble_outline,
                                  color: hasPromo ? Colors.orange : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.green, size: 20), 
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDatapelanggan(pelanggan: item))).then((v) => loadData())
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20), 
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditDatapelanggan(pelanggan: item))).then((v) => loadData())
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20), 
                                      onPressed: () => _confirmDelete(item.id.toString())
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5BC), 
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterIcon(icon: Icons.assignment, color: Colors.yellow[700]!, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Laporanpenjualan()))),
            _buildFooterIcon(icon: Icons.home, color: const Color(0xFF1A437E), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Landingpage()))),
            _buildFooterIcon(icon: Icons.payments, color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Laporankeuangan()))),
          ],
        ),
      ),
      floatingActionButton: selectedPelanggan.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: isLoading 
                  ? null 
                  : _showBroadcastConfirmationDialog,
              label: Text(
                isLoading 
                    ? "MENGIRIM..." 
                    : "BROADCAST (${selectedPelanggan.length})",
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.campaign),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}