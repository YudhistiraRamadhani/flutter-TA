import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apitransaksi.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
import 'package:flutter_application_1/screen/Transaksi.dart'; 

class Laporankeuangan extends StatefulWidget {
  @override
  _LaporankeuanganState createState() => _LaporankeuanganState();
}

class _LaporankeuanganState extends State<Laporankeuangan> {
  final Apitransaksi api = Apitransaksi();
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = []; // Untuk menampung hasil filter
  
  int totalPemasukan = 0;
  int totalPengeluaran = 0;
  bool _isLoading = true;

  // State untuk Filter dan Search (Disamakan dengan Laporan Penjualan)
  String? _selectedYear; 
  String? _selectedMonth;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _listMonths = ["Semua", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await api.fetchTransaksi();
      setState(() {
        _allData = data['transaksi'];
        _filteredData = _allData;
        _hitungTotal(_filteredData);
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Filter Manual (Disamakan dengan logika Laporan Penjualan)
  void _runFilter() {
    String query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _filteredData = _allData.where((item) {
        // Karena item biasanya map dari API, sesuaikan akses key-nya
        final namaBarang = item.Nama_Barang.toString().toLowerCase();
        final matchesSearch = namaBarang.contains(query);
        
        // Parsing tanggal untuk filter tahun & bulan
        DateTime? tgl = DateTime.tryParse(item.Tanggal.toString());
        
        final matchesYear = _selectedYear == null || 
                            _selectedYear == "Semua" || 
                            tgl?.year.toString() == _selectedYear;
        
        final matchesMonth = _selectedMonth == null || 
                             _selectedMonth == "Semua" || 
                             tgl?.month.toString().padLeft(2, '0') == _selectedMonth;
        
        return matchesSearch && matchesYear && matchesMonth;
      }).toList();

      _hitungTotal(_filteredData); // Hitung ulang total setelah filter
    });
  }

  void _hitungTotal(List<dynamic> data) {
    totalPemasukan = 0;
    totalPengeluaran = 0;
    for (var item in data) {
      int harga = int.tryParse(item.Harga.toString()) ?? 0;
      int jumlah = int.tryParse(item.Jumlah.toString()) ?? 0;
      int subtotal = harga * jumlah;

      if (item.jenis_transaksi == 'Pemasukan') {
        totalPemasukan += subtotal;
      } else {
        totalPengeluaran += subtotal;
      }
    }
  }

  Future<void> _selectYear(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Tahun"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000), 
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
              selectedDate: (_selectedYear == null || _selectedYear == "Semua")
                  ? DateTime.now()
                  : DateTime(int.parse(_selectedYear!)),
              onChanged: (DateTime dateTime) {
                setState(() => _selectedYear = dateTime.year.toString());
                _runFilter();
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedYear = "Semua");
                _runFilter();
                Navigator.pop(context);
              },
              child: const Text("Tampilkan Semua"),
            ),
          ],
        );
      },
    );
  }

  String formatRupiah(int nominal) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "LAPORAN KEUANGAN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // BARIS FILTER & SEARCH (Identik dengan Laporan Penjualan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Text("tahun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 5),
                InkWell(
                  onTap: () => _selectYear(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedYear ?? "Pilih", style: const TextStyle(fontSize: 12)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildDropdown(
                  value: _selectedMonth,
                  hint: "Bln",
                  items: _listMonths,
                  onChanged: (val) { 
                    _selectedMonth = val; 
                    _runFilter(); 
                  },
                ),
                const Spacer(),
                Container(
                  width: 130, height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), 
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _runFilter(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 12, left: 10),
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // SUMMARY CARDS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildSummaryCard("Pemasukan", totalPemasukan, Colors.green),
                const SizedBox(width: 10),
                _buildSummaryCard("Pengeluaran", totalPengeluaran, Colors.red),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // LABA BERSIH BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (totalPemasukan - totalPengeluaran) >= 0 ? Colors.blue[800] : Colors.red[900],
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("LABA BERSIH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(formatRupiah(totalPemasukan - totalPengeluaran), 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // TABEL DATA
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredData.isEmpty 
                ? const Center(child: Text("Data tidak ditemukan"))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                          border: TableBorder.all(color: Colors.grey[300]!),
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Barang/Voucher')),
                            DataColumn(label: Text('Pemasukan')),
                            DataColumn(label: Text('Pengeluaran')),
                            DataColumn(label: Text('Tanggal')),
                          ],
                          rows: _filteredData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            int subtotal = int.parse(item.Harga.toString()) * int.parse(item.Jumlah.toString());
                            bool isMasuk = item.jenis_transaksi == 'Pemasukan';
                            
                            String displayVoucher = (item.Voucher == null || item.Voucher == '-') ? "" : "(${item.Voucher})";
                            String formattedDate = item.Tanggal.toString().length >= 10 
                                ? item.Tanggal.toString().substring(0, 10) : item.Tanggal.toString();

                            return DataRow(cells: [
                              DataCell(Text("${index + 1}")),
                              DataCell(Text("${item.Nama_Barang}\n$displayVoucher")),
                              DataCell(Text(isMasuk ? formatRupiah(subtotal) : "-", style: const TextStyle(color: Colors.green))),
                              DataCell(Text(!isMasuk ? formatRupiah(subtotal) : "-", style: const TextStyle(color: Colors.red))),
                              DataCell(Text(formattedDate)),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),

      // FOOTER DISAMAKAN
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Landingpage())),
            ),
            _buildFooterIcon(
              icon: Icons.payments_outlined,
              color: Colors.red,
              onTap: () {}, // Halaman aktif
            ),
          ],
        ),
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildDropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isDense: true,
          hint: Text(hint, style: const TextStyle(fontSize: 11)),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFooterIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color)
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            Text(formatRupiah(value), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}