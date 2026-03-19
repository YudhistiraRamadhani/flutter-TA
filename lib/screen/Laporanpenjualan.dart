import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/apitransaksi.dart'; 
import 'package:flutter_application_1/model/posttransaksi.dart'; 
import 'package:flutter_application_1/screen/Laporankeuangan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';

class Laporanpenjualan extends StatefulWidget {
  @override
  _LaporanpenjualanState createState() => _LaporanpenjualanState();
}

class _LaporanpenjualanState extends State<Laporanpenjualan> {
  final Apitransaksi apiService = Apitransaksi();
  List<PostTransaksi> _allTransaksi = []; 
  List<PostTransaksi> _filteredData = []; 
  
  bool _isLoading = true;
  String? _selectedYear; 
  String? _selectedMonth;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _listMonths = ["Semua", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- LOGIKA LOAD DATA DENGAN FILTER PEMASUKAN ---
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await apiService.fetchTransaksi();
      
      // Mengambil list mentah dari API
      List<PostTransaksi> rawData = List<PostTransaksi>.from(data['transaksi']);

      setState(() {
        // HANYA ambil data dengan jenis_transaksi 'Pemasukan'
        _allTransaksi = rawData.where((item) => item.jenis_transaksi == 'Pemasukan').toList();
        
        _filteredData = _allTransaksi;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load data: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA FILTER (PENCARIAN, BULAN, TAHUN) ---
  void _runFilter() {
    String query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _filteredData = _allTransaksi.where((t) {
        // Filter Nama Barang
        final matchesSearch = t.Nama_Barang.toLowerCase().contains(query);
        
        // Filter Tahun
        final matchesYear = _selectedYear == null || 
                            _selectedYear == "Semua" || 
                            t.Tanggal?.year.toString() == _selectedYear;
        
        // Filter Bulan
        final matchesMonth = _selectedMonth == null || 
                             _selectedMonth == "Semua" || 
                             t.Tanggal?.month.toString().padLeft(2, '0') == _selectedMonth;
        
        return matchesSearch && matchesYear && matchesMonth;
      }).toList();
    });
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
                setState(() {
                  _selectedYear = dateTime.year.toString();
                });
                _runFilter();
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedYear = "Semua";
                });
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
                "LAPORAN PENJUALAN",
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
          // BARIS FILTER & SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Text("Tahun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                    setState(() => _selectedMonth = val); 
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
          // TABEL DATA
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredData.isEmpty 
                ? const Center(child: Text("Data penjualan tidak ditemukan"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                          border: TableBorder.all(color: Colors.grey[300]!),
                          columns: const [
                            DataColumn(label: Text('NO')),
                            DataColumn(label: Text('Nama\nBarang')),
                            DataColumn(label: Text('Harga')),
                            DataColumn(label: Text('Jumlah')),
                            DataColumn(label: Text('Voucher')),
                            DataColumn(label: Text('Tanggal')),
                          ],
                          rows: List<DataRow>.generate(_filteredData.length, (index) {
                            final item = _filteredData[index];
                            String tgl = item.Tanggal != null 
                                ? "${item.Tanggal!.day.toString().padLeft(2,'0')}-${item.Tanggal!.month.toString().padLeft(2,'0')}-${item.Tanggal!.year}" 
                                : "-";
                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(item.Nama_Barang)),
                              DataCell(Text(item.Harga)),
                              DataCell(Text(item.Jumlah)),
                              DataCell(Text(item.Voucher)),
                              DataCell(Text(tgl)),
                            ]);
                          }),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // Helper UI Footer
  Widget _buildBottomNav(BuildContext context) {
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
            icon: Icons.assignment,
            color: Colors.yellow[600]!,
            onTap: () {}, // Sudah di halaman Laporan Penjualan
          ),
          _buildFooterIcon(
            icon: Icons.home_outlined,
            color: const Color(0xFF1A437E),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Landingpage())),
          ),
          _buildFooterIcon(
            icon: Icons.payments_outlined,
            color: Colors.red,
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Laporankeuangan())),
          ),
        ],
      ),
    );
  }

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
          value: value, 
          isDense: true,
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
}