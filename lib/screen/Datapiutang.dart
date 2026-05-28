import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/apidatapiutang.dart';
import 'package:flutter_application_1/model/postdatapiutang.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/DetailPiutang.dart';
import 'package:flutter_application_1/screen/formpiutang.dart';
import 'package:flutter_application_1/screen/EditPiutang.dart';

class Datapiutang extends StatefulWidget {
  const Datapiutang({super.key});

  @override
  _DatapiutangState createState() => _DatapiutangState();
}

class _DatapiutangState extends State<Datapiutang> {
  final Apidatapiutang _apiService = Apidatapiutang();
  
  List<Postdatapiutang> dataPiutang = [];
  List<Postdatapiutang> filteredPiutang = [];
  List<String> selectedPiutang = []; 
  
  bool isLoading = true;
  bool isBroadcastSameMessage = false;
  String? detectedSameMessage;
  List<Postdatapiutang> piutangWithSameMessage = [];

  TextEditingController searchController = TextEditingController();

  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      List<dynamic> responseData = await _apiService.getdatapiutang();
      List<Postdatapiutang> data = responseData.map((json) => Postdatapiutang.fromJson(json)).toList();
      
      // LOGIKA SORTING DESCENDING (TERBARU DI ATAS BERDASARKAN TANGGAL / ID)
      data.sort((a, b) {
        if (a.date != null && b.date != null && a.date!.isNotEmpty && b.date!.isNotEmpty) {
          try {
            DateTime dateA = DateTime.parse(a.date!);
            DateTime dateB = DateTime.parse(b.date!);
            return dateB.compareTo(dateA); 
          } catch (e) {
            print("Error parsing date during sort: $e");
          }
        }
        return b.id.compareTo(a.id);
      });

      if (mounted) {
        setState(() {
          dataPiutang = data;
          _applyFilters();
          selectedPiutang.clear();
          isBroadcastSameMessage = false;
          detectedSameMessage = null;
          piutangWithSameMessage = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredPiutang = dataPiutang.where((item) {
        final matchesSearch = item.nama_pelanggan.toLowerCase().contains(query) || 
                             item.nama_barang.toLowerCase().contains(query);

        bool matchesMonth = true;
        bool matchesYear = true;
        
        if (item.date != null && item.date!.isNotEmpty) {
          try {
            DateTime dt = DateTime.parse(item.date!);
            matchesMonth = selectedMonth == null || dt.month == selectedMonth;
            matchesYear = selectedYear == null || dt.year == selectedYear;
          } catch (e) {
            print("Error parsing date: ${item.date}");
          }
        }

        return matchesSearch && matchesMonth && matchesYear;
      }).toList();
    });
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Tahun"),
          content: SizedBox(
            width: 300, height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDate: DateTime.now(),
              selectedDate: DateTime(selectedYear ?? DateTime.now().year),
              onChanged: (DateTime dateTime) {
                setState(() {
                  selectedYear = dateTime.year;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ),
        );
      },
    );
  }

  void _filterSearch(String query) {
    _applyFilters();
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedPiutang = filteredPiutang
            .where((item) {
              // Hanya pilih yang belum lunas DAN memiliki pesan valid
              final isNotLunas = item.status.toString().toLowerCase() != "lunas";
              final message = (item.pesanpenagihan ?? "").toString().trim();
              final isValidMessage = message.isNotEmpty && message != "-" && message.length >= 3;
              return isNotLunas && isValidMessage;
            })
            .map((item) => item.id.toString())
            .toList();
      } else {
        selectedPiutang.clear();
      }
      _checkSameMessageOnSelected();
    });
  }

  // Fungsi untuk memeriksa apakah pesan valid
  bool _isValidMessage(String? message) {
    if (message == null) return false;
    final msg = message.toString().trim();
    return msg.isNotEmpty && msg != "-" && msg.length >= 3;
  }

  // Fungsi untuk mendapatkan pesan yang valid
  String? _getValidMessage(Postdatapiutang item) {
    final message = (item.pesanpenagihan ?? "").toString().trim();
    if (_isValidMessage(message)) {
      return message;
    }
    return null;
  }

  // Logika checkbox dengan deteksi pesan sama
  void _onCheckboxChanged(String id, bool? value) {
    setState(() {
      if (value == true) {
        if (!selectedPiutang.contains(id)) {
          selectedPiutang.add(id);
        }

        // Ambil draf pesan dari item terpilih
        final selectedData = dataPiutang.firstWhere((p) => p.id.toString() == id);
        final selectedMessage = _getValidMessage(selectedData);
        
        if (selectedMessage != null) {
          // Hanya pilih item dengan pesan yang SAMA PERSIS dan belum lunas
          for (var item in filteredPiutang) {
            final currentMessage = _getValidMessage(item);
            final isNotLunas = item.status.toString().toLowerCase() != "lunas";
            
            if (currentMessage == selectedMessage && isNotLunas) {
              String itemIdStr = item.id.toString();
              if (!selectedPiutang.contains(itemIdStr)) {
                selectedPiutang.add(itemIdStr);
              }
            }
          }
        }
      } else {
        selectedPiutang.remove(id);
        
        // Saat membatalkan centang, hapus item dengan pesan yang sama
        final unselectedData = dataPiutang.firstWhere((p) => p.id.toString() == id);
        final unselectedMessage = _getValidMessage(unselectedData);
        
        if (unselectedMessage != null) {
          for (var item in filteredPiutang) {
            final currentMessage = _getValidMessage(item);
            if (currentMessage == unselectedMessage) {
              selectedPiutang.remove(item.id.toString());
            }
          }
        }
      }
      _checkSameMessageOnSelected();
    });
  }

  // Deteksi pesan sama yang dipilih
  void _checkSameMessageOnSelected() {
    if (selectedPiutang.isEmpty) {
      setState(() {
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        piutangWithSameMessage = [];
      });
      return;
    }

    final selectedData = filteredPiutang.where((p) => selectedPiutang.contains(p.id.toString())).toList();
    
    if (selectedData.isEmpty) {
      setState(() {
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        piutangWithSameMessage = [];
      });
      return;
    }

    // Ambil pesan dari item pertama yang VALID
    String? firstValidMessage;
    
    for (var item in selectedData) {
      final msg = _getValidMessage(item);
      if (msg != null) {
        firstValidMessage = msg;
        break;
      }
    }
    
    if (firstValidMessage == null) {
      setState(() {
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        piutangWithSameMessage = [];
      });
      return;
    }

    // Cek apakah SEMUA item yang dipilih memiliki pesan yang SAMA
    bool allHaveSameMessage = selectedData.every((p) {
      final msg = _getValidMessage(p);
      if (msg == null) return true;
      return msg == firstValidMessage;
    });

    int validMessageCount = selectedData.where((p) => _getValidMessage(p) != null).length;

    if (allHaveSameMessage && selectedData.length > 1 && validMessageCount >= 2) {
      final allWithSameMessage = filteredPiutang.where((p) {
        final msg = _getValidMessage(p);
        final isNotLunas = p.status.toString().toLowerCase() != "lunas";
        return msg == firstValidMessage && isNotLunas;
      }).toList();
      
      if (allWithSameMessage.length >= 2) {
        setState(() {
          isBroadcastSameMessage = true;
          detectedSameMessage = firstValidMessage; 
          piutangWithSameMessage = allWithSameMessage;
        });
      } else {
        setState(() {
          isBroadcastSameMessage = false;
          detectedSameMessage = null;
          piutangWithSameMessage = [];
        });
      }
    } else {
      setState(() {
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        piutangWithSameMessage = [];
      });
    }
  }

  // PERBAIKAN: Fungsi format Rupiah dengan pemisah ribuan
  String _formatRupiah(int nominal) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(nominal);
  }

  // Fungsi tambahan untuk format angka tanpa simbol Rp (opsional)
  String _formatNumber(int nominal) {
    return NumberFormat('#,###').format(nominal);
  }

  void _sendBroadcastSameMessage() async {
    if (piutangWithSameMessage.isEmpty) return;

    setState(() => isLoading = true);

    int successCount = 0;
    int totalCount = piutangWithSameMessage.length;

    for (var p in piutangWithSameMessage) {
      final message = _getValidMessage(p);
      if (p.no_whatsapp.isNotEmpty && message != null) {
        bool success = await _apiService.sendBroadcast(p.no_whatsapp, message);
        if (success) successCount++;
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        selectedPiutang.clear();
        isBroadcastSameMessage = false;
        detectedSameMessage = null;
        piutangWithSameMessage = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Broadcast pesan sama: Berhasil ke $successCount dari $totalCount pelanggan"),
          backgroundColor: successCount > 0 ? Colors.green : Colors.red,
        ),
      );
      loadData();
    }
  }

  void _sendBroadcast() async {
    if (selectedPiutang.isEmpty) return;
    
    List<Postdatapiutang> selectedData = filteredPiutang
        .where((item) => selectedPiutang.contains(item.id.toString()))
        .toList();
    
    if (selectedData.isEmpty) return;
    
    setState(() => isLoading = true);
    
    try {
      int successCount = 0;
      int skipCount = 0;
      
      for (var item in selectedData) {
        String? message = _getValidMessage(item);
        
        if (message == null) {
          skipCount++;
          continue;
        }
        
        bool success = await _apiService.sendBroadcast(item.no_whatsapp, message);
        if (success) successCount++;
      }
      
      if (mounted) {
        String snackbarMsg = "";
        if (successCount > 0 && skipCount > 0) {
          snackbarMsg = "Berhasil mengirim $successCount pesan, $skipCount data tanpa pesan dilewati";
        } else if (successCount > 0) {
          snackbarMsg = "Berhasil mengirim $successCount pesan";
        } else if (skipCount > 0) {
          snackbarMsg = "Tidak ada pesan yang dikirim (semua data tidak memiliki draf penagihan)";
        } else {
          snackbarMsg = "Gagal mengirim pesan";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMsg),
            backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
          ),
        );
        
        setState(() {
          selectedPiutang.clear();
          isBroadcastSameMessage = false;
          detectedSameMessage = null;
          piutangWithSameMessage = [];
        });
        loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus data ini?\n\nData yang dihapus tidak dapat dikembalikan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => isLoading = true);
                
                try {
                  bool success = await _apiService.deletePiutang(id.toString());
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.green),
                      );
                      await loadData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal menghapus data"), backgroundColor: Colors.red),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => isLoading = false);
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showFormPesanPenagihanDialog() {
    final formKeyPromo = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final waController = TextEditingController();
    final penagihanController = TextEditingController();
    
    TextEditingController? autocompleteNamaController;
    TextEditingController? autocompleteWaController;

    Postdatapiutang? pelangganTerpilih;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buat Pesan Penagihan Piutang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Form(
              key: formKeyPromo,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nama Pelanggan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Autocomplete<Postdatapiutang>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<Postdatapiutang>.empty();
                      return dataPiutang.where((p) => p.nama_pelanggan.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (Postdatapiutang option) => option.nama_pelanggan,
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      autocompleteNamaController = textEditingController;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(hintText: "Cari nama...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person, size: 20)),
                        validator: (v) => v!.trim().isEmpty ? "Nama wajib diisi" : null,
                        onChanged: (val) {
                          namaController.text = val;
                          pelangganTerpilih = null;
                        },
                      );
                    },
                    onSelected: (Postdatapiutang selected) {
                      pelangganTerpilih = selected;
                      namaController.text = selected.nama_pelanggan;
                      waController.text = selected.no_whatsapp;
                      penagihanController.text = selected.pesanpenagihan ?? '';
                      if (autocompleteWaController != null) {
                        autocompleteWaController!.text = selected.no_whatsapp;
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text("Nomor WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Autocomplete<Postdatapiutang>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<Postdatapiutang>.empty();
                      return dataPiutang.where((p) => p.no_whatsapp.contains(textEditingValue.text));
                    },
                    displayStringForOption: (Postdatapiutang option) => option.no_whatsapp,
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
                          pelangganTerpilih = null;
                        },
                      );
                    },
                    onSelected: (Postdatapiutang selected) {
                      pelangganTerpilih = selected;
                      waController.text = selected.no_whatsapp;
                      namaController.text = selected.nama_pelanggan;
                      penagihanController.text = selected.pesanpenagihan ?? '';
                      if (autocompleteNamaController != null) {
                        autocompleteNamaController!.text = selected.nama_pelanggan;
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text("Isi Teks Pesan Penagihan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: penagihanController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: "Tulis draf tagihan piutang di sini...", border: OutlineInputBorder()),
                    validator: (v) => v!.trim().isEmpty ? "Pesan tidak boleh kosong" : null,
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
                    bool res;
                    if (pelangganTerpilih != null) {
                      Map<String, dynamic> bodyUpdate = pelangganTerpilih!.toJson();
                      bodyUpdate["nama_pelanggan"] = namaController.text.trim();
                      bodyUpdate["no_whatsapp"] = waController.text.trim();
                      bodyUpdate["pesanpenagihan"] = penagihanController.text.trim();
                      
                      res = await _apiService.updatePiutang(pelangganTerpilih!.id.toString(), bodyUpdate);
                    } else {
                      Map<String, dynamic> bodyNew = {
                        "nama_pelanggan": namaController.text.trim(),
                        "no_whatsapp": waController.text.trim(),
                        "pesanpenagihan": penagihanController.text.trim(),
                        "nama_barang": "-",
                        "jumlah_hutang": 0,
                        "status": "Piutang"
                      };
                      res = await _apiService.updatePiutang("0", bodyNew);
                    }

                    if (res) {
                      loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draf penagihan berhasil disimpan!"), backgroundColor: Colors.green));
                      }
                    } else {
                      setState(() => isLoading = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan draf"), backgroundColor: Colors.red));
                      }
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
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

  Widget _buildStatusBadge(String status) {
    bool isLunas = status.toString().toLowerCase() == "lunas";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLunas ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        isLunas ? "LUNAS" : "PIUTANG",
        style: TextStyle(
          color: isLunas ? Colors.green : Colors.red, 
          fontSize: 10, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = filteredPiutang.isNotEmpty && 
                         selectedPiutang.length == filteredPiutang.where((item) {
                           final isNotLunas = item.status.toString().toLowerCase() != "lunas";
                           final isValid = _isValidMessage(item.pesanpenagihan);
                           return isNotLunas && isValid;
                         }).length;

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
                    "DATA PIUTANG",
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
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: _filterSearch,
                        decoration: InputDecoration(
                          hintText: "Cari Nama Pelanggan atau Barang...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Bulan",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              value: selectedMonth,
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(DateFormat('MMMM', 'id').format(DateTime(2024, index + 1))),
                                );
                              }),
                              onChanged: (val) {
                                setState(() => selectedMonth = val);
                                _applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(selectedYear?.toString() ?? "Tahun"),
                              onPressed: _showYearPicker,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                selectedMonth = null;
                                selectedYear = null;
                              });
                              _applyFilters();
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                
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
                            "Terpilih ${selectedPiutang.length} tagihan dengan PESAN SAMA. Akan mengirim ke ${piutangWithSameMessage.length} data yang memiliki draf pesan '${(detectedSameMessage?.length ?? 0) > 30 ? '${detectedSameMessage?.substring(0, 30)}...' : detectedSameMessage}'.",
                            style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                CheckboxListTile(
                  title: const Text("Pilih Semua (Piutang Belum Lunas dengan Pesan Valid)", style: TextStyle(fontSize: 14)),
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const formpiutang())).then((_) => loadData()),
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
                            onPressed: _showFormPesanPenagihanDialog,
                            icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
                            label: const Text("PESAN PENAGIHAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                          DataColumn(label: Text('NAMA PELANGGAN')),
                          DataColumn(label: Text('NAMA BARANG')),
            
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('PESAN')),
                          DataColumn(label: Text('AKSI')),
                        ],
                        rows: filteredPiutang.map((item) {
                          final itemIdString = item.id.toString();
                          final isSelected = selectedPiutang.contains(itemIdString);
                          
                          bool isLunas = item.status.toString().toLowerCase() == "lunas";
                          bool hasPesan = _isValidMessage(item.pesanpenagihan);
                          
                          return DataRow(
                            selected: isSelected,
                            cells: [
                              DataCell(
                                Checkbox(
                                  value: isSelected,
                                  onChanged: isLunas ? null : (val) => _onCheckboxChanged(itemIdString, val),
                                )
                              ),
                              DataCell(Text(item.nama_pelanggan)),
                              DataCell(Text(item.nama_barang)),
                              // PERBAIKAN: Format Rupiah dengan pemisah ribuan
                          
                              DataCell(_buildStatusBadge(item.status)),
                              // KOLOM PESAN - Icon message berwarna jika ada pesan, abu-abu jika tidak
                              DataCell(
                                Icon(
                                  hasPesan ? Icons.message : Icons.message_outlined,
                                  color: hasPesan ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20), 
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditPiutang(data: item.toJson()))).then((_) => loadData())
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20), 
                                    onPressed: () => _confirmDelete(item.id)
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailPiutang(data: item.toJson())),
                                      );
                                    },
                                    tooltip: "Detail",
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
      floatingActionButton: selectedPiutang.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: isLoading ? null : (isBroadcastSameMessage ? _sendBroadcastSameMessage : _sendBroadcast),
              label: Text(
                isLoading 
                    ? "MENGIRIM..." 
                    : (isBroadcastSameMessage 
                        ? "BROADCAST PESAN SAMA (${piutangWithSameMessage.length})" 
                        : "KIRIM KE ${selectedPiutang.length}"),
                style: const TextStyle(fontSize: 12),
              ),
              icon: Icon(isBroadcastSameMessage ? Icons.broadcast_on_personal : Icons.campaign),
              backgroundColor: isBroadcastSameMessage ? Colors.orange : Colors.green,
            )
          : null,
    );
  }
}