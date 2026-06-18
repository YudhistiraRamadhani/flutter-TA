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
  bool isBroadcastSameMessage = false;
  String? detectedSameMessage;
  List<Postdatapelanggan> pelangganWithSameMessage = [];
  
  TextEditingController searchController = TextEditingController();
  TextEditingController promoMessageController = TextEditingController();

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
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        pelangganWithSameMessage = [];
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
      _checkSameMessageOnSelected();
    });
  }

  void _onCheckboxChanged(String id, bool? value) {
    setState(() {
      if (value == true) {
        final selectedData = pelanggan.firstWhere((p) => p.id.toString() == id);
        final selectedMessage = selectedData.pesannotifikasi ?? "";
        
        if (selectedMessage.isNotEmpty) {
          final pelangganWithSameMsg = pelanggan.where((p) => 
            p.pesannotifikasi != null && 
            p.pesannotifikasi == selectedMessage
          ).toList();
          
          for (var p in pelangganWithSameMsg) {
            if (!selectedPelanggan.contains(p.id.toString())) {
              selectedPelanggan.add(p.id.toString());
            }
          }
        } else {
          if (!selectedPelanggan.contains(id)) {
            selectedPelanggan.add(id);
          }
        }
      } else {
        selectedPelanggan.remove(id);
      }
      _checkSameMessageOnSelected();
    });
  }

  void _checkSameMessageOnSelected() {
    if (selectedPelanggan.isEmpty) {
      isBroadcastSameMessage = false;
      detectedSameMessage = null;
      pelangganWithSameMessage = [];
      return;
    }

    final selectedData = pelanggan.where((p) => selectedPelanggan.contains(p.id.toString())).toList();
    
    if (selectedData.isEmpty) {
      isBroadcastSameMessage = false;
      detectedSameMessage = null;
      pelangganWithSameMessage = [];
      return;
    }

    final firstSelectedMessage = selectedData.first.pesannotifikasi ?? "";
    
    if (firstSelectedMessage.isEmpty) {
      isBroadcastSameMessage = false;
      detectedSameMessage = null;
      pelangganWithSameMessage = [];
      return;
    }

    bool allHaveSameMessage = selectedData.every((p) => 
      (p.pesannotifikasi ?? "") == firstSelectedMessage
    );

    if (allHaveSameMessage && selectedData.length > 1) {
      final allWithSameMessage = pelanggan.where((p) => 
        (p.pesannotifikasi ?? "") == firstSelectedMessage
      ).toList();
      
      setState(() {
        isBroadcastSameMessage = true;
        detectedSameMessage = firstSelectedMessage;
        pelangganWithSameMessage = allWithSameMessage;
      });
    } else {
      setState(() {
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        pelangganWithSameMessage = [];
      });
    }
  }

  void _sendBroadcastSameMessage() async {
  if (pelangganWithSameMessage.isEmpty) return;

  setState(() => isLoading = true);

  int successCount = 0;
  int totalCount = pelangganWithSameMessage.length;

  for (var p in pelangganWithSameMessage) {
    if (p.no_whatsapp != null &&
        p.no_whatsapp!.isNotEmpty &&
        p.pesannotifikasi != null &&
        p.pesannotifikasi!.isNotEmpty) {

      bool success = await api.sendBroadcast(
        [
          {
            'target': p.no_whatsapp!,
          }
        ],
        p.pesannotifikasi!,
      );

      if (success) successCount++;
    }
  }

  if (mounted) {
    setState(() {
      isLoading = false;
      selectedPelanggan.clear();
      isBroadcastSameMessage = false;
      detectedSameMessage = null;
      pelangganWithSameMessage = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Broadcast pesan sama: Berhasil ke $successCount dari $totalCount pelanggan",
        ),
        backgroundColor:
            successCount > 0 ? Colors.green : Colors.red,
      ),
    );
  }
}

void _sendBroadcast() async {
  if (selectedPelanggan.isEmpty) return;

  setState(() => isLoading = true);

  try {
    int successCount = 0;

    for (String id in selectedPelanggan) {

      final p = pelanggan.firstWhere(
        (item) => item.id.toString() == id,
      );

      String nomor = p.no_whatsapp!;

      String isiPesan =
          (p.pesannotifikasi != null &&
                  p.pesannotifikasi!.isNotEmpty)
              ? p.pesannotifikasi!
              : "";

      if (isiPesan.isNotEmpty) {

        bool success = await api.sendBroadcast(
          [
            {
              'target': nomor,
            }
          ],
          isiPesan,
        );

        if (success) successCount++;
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        selectedPelanggan.clear();
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        pelangganWithSameMessage = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Berhasil mengirim $successCount dari ${selectedPelanggan.length} pesan",
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

  } catch (e) {

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _sendSelectedPromoMessage() async {
    if (selectedPelanggan.isEmpty) return;

    final message = promoMessageController.text.trim();
    if (message.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesan promo tidak boleh kosong"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final targets = pelanggan
        .where((p) => selectedPelanggan.contains(p.id.toString()) && p.no_whatsapp != null && p.no_whatsapp!.isNotEmpty)
        .map((p) => {'target': p.no_whatsapp!})
        .toList();

    if (targets.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pilih pelanggan dengan nomor WhatsApp valid"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      bool success;
      if (targets.length <= 20) {
        success = await api.sendBroadcast(targets, message);
      } else {
        final result = await api.sendBatchBroadcast(targets, message);
        success = result['success'] == targets.length;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          promoMessageController.clear();
          selectedPelanggan.clear();
          isBroadcastSameMessage = false;
          detectedSameMessage = null;
          pelangganWithSameMessage = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? "Pesan berhasil dikirim ke ${targets.length} pelanggan" : "Gagal mengirim pesan ke pelanggan",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim: $e"), backgroundColor: Colors.red),
        );
      }
    }
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

  // ================= FORM POP-UP PESAN PROMO + AUTOCOMPLETE =================
  void _showFormPesanPromoDialog() {
    final formKeyPromo = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final waController = TextEditingController();
    final promoController = TextEditingController();
    
    TextEditingController? autocompleteNamaController;
    TextEditingController? autocompleteWaController;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buat Pesan Promo Pelanggan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Form(
              key: formKeyPromo,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nama Pelanggan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Autocomplete<Postdatapelanggan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<Postdatapelanggan>.empty();
                      return pelanggan.where((p) => p.nama_pelanggan!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (Postdatapelanggan option) => option.nama_pelanggan ?? '',
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      autocompleteNamaController = textEditingController;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(hintText: "Cari nama...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person, size: 20)),
                        validator: (v) => v!.trim().isEmpty ? "Nama wajib diisi" : null,
                        onChanged: (val) {
                          namaController.text = val;
                        },
                      );
                    },
                    onSelected: (Postdatapelanggan selected) {
                      namaController.text = selected.nama_pelanggan ?? '';
                      waController.text = selected.no_whatsapp ?? '';
                      promoController.text = selected.pesannotifikasi ?? '';
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
                        decoration: const InputDecoration(hintText: "Cari nomor WA...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone, size: 20)),
                        validator: (v) => v!.trim().isEmpty ? "Nomor WA wajib diisi" : null,
                        onChanged: (val) {
                          waController.text = val;
                        },
                      );
                    },
                    onSelected: (Postdatapelanggan selected) {
                      waController.text = selected.no_whatsapp ?? '';
                      namaController.text = selected.nama_pelanggan ?? '';
                      promoController.text = selected.pesannotifikasi ?? '';
                      if (autocompleteNamaController != null) {
                        autocompleteNamaController!.text = selected.nama_pelanggan ?? '';
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text("Isi Teks Pesan Promo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: promoController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: "Tulis draf promo toko di sini...", border: OutlineInputBorder()),
                    validator: (v) => v!.trim().isEmpty ? "Pesan promo tidak boleh kosong" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D48ED)),
              onPressed: () async {
                if (formKeyPromo.currentState!.validate()) {
                  Navigator.pop(context);
                  setState(() => isLoading = true);
                  try {
                    final nomor = waController.text.trim();
                    final pesan = promoController.text.trim();

                    bool success = false;
                    if (nomor.isNotEmpty && pesan.isNotEmpty) {
                      success = await api.sendBroadcast(
                        [
                          {'target': nomor},
                        ],
                        pesan,
                      );
                    }

                    if (mounted) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? "Pesan berhasil dikirim!" : "Gagal mengirim pesan",
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text("KIRIM", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
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
                
                if (isBroadcastSameMessage)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Terpilih ${selectedPelanggan.length} pelanggan dengan PESAN SAMA. Akan mengirim ke ${pelangganWithSameMessage.length} pelanggan yang memiliki pesan '${detectedSameMessage}'.",
                            style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                          ),
                        ),
                      ],
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
                            onPressed: _showFormPesanPromoDialog,
                            icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
                            label: const Text("PESAN PROMO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange, 
                              foregroundColor: Colors.white, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedPelanggan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          "Tulis pesan promo untuk pelanggan terpilih",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: promoMessageController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Tulis pesan promo...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _sendSelectedPromoMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              isLoading ? "MENGIRIM..." : "KIRIM KE ${selectedPelanggan.length}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                              DataCell(Row(
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
                              )),
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
                  : (isBroadcastSameMessage ? _sendBroadcastSameMessage : _sendBroadcast),
              label: Text(
                isLoading 
                    ? "MENGIRIM..." 
                    : (isBroadcastSameMessage 
                        ? "BROADCAST PESAN SAMA (${pelangganWithSameMessage.length})" 
                        : "KIRIM KE ${selectedPelanggan.length}"),
                style: const TextStyle(fontSize: 12),
              ),
              icon: Icon(isBroadcastSameMessage ? Icons.broadcast_on_personal : Icons.campaign),
              backgroundColor: isBroadcastSameMessage ? Colors.orange : Colors.green,
            )
          : null,
    );
  }
}