import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Landingpagenew extends StatefulWidget {
  const Landingpagenew({super.key});

  @override
  State<Landingpagenew> createState() => _LandingPageNewState();
}

class _LandingPageNewState extends State<Landingpagenew> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: const [
                  Text(
                    'SELAMAT DATANG DI PUSAT KONTROL JS CELL!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'JS CELL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Utama Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  // --- MENU GRID ---
                  _buildMenuGrid(),
                  
                  const SizedBox(height: 25),
                  const Text(
                    'Rangkuman Analitis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // --- STATISTIC CHARTS ---
                  Row(
                    children: [
                      Expanded(child: _buildLineChartCard('Laporan Penjualan', 'Rp 175.000', const Color(0xFFD97706))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildLineChartCard('Laba Bersih', '49.3%', const Color(0xFF0D9488))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFinancialPieChart(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Widget untuk Grid Menu
  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.description, 'label': 'Laporan', 'color': const Color(0xFFE0F2FE)},
      {'icon': Icons.settings_suggest, 'label': 'Fitur', 'color': const Color(0xFFFEE2E2)},
      {'icon': Icons.payments, 'label': 'Harga', 'color': const Color(0xFFFEF3C7)},
      {'icon': Icons.reviews, 'label': 'Testimoni', 'color': const Color(0xFFDCFCE7)},
      {'icon': Icons.play_circle_fill, 'label': 'Mulai', 'color': const Color(0xFFE0F2FE)},
      {'icon': Icons.person, 'label': 'Profil', 'color': const Color(0xFFF3E8FF)},
      {'icon': Icons.settings, 'label': 'Setting', 'color': const Color(0xFFF1F5F9)},
      {'icon': Icons.help, 'label': 'Bantuan', 'color': const Color(0xFFE2E8F0)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(items[index]['icon'], color: const Color(0xFF1E3A8A)),
              const SizedBox(height: 8),
              Text(items[index]['label'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk Grafik Garis (Penjualan/Laba)
  Widget _buildLineChartCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 4),
                    ],
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Grafik Lingkaran (Keuangan)
  Widget _buildFinancialPieChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Analisis Laporan Keuangan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 35, title: '35%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.red, value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.green, value: 10, title: '10%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Bottom Navigation
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
        BottomNavigationBarItem(icon: CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Text('JS', style: TextStyle(color: Colors.white, fontSize: 12))), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Keamanan'),
      ],
    );
  }
}