Future<Map<String, dynamic>> fetchDashboardData() async {
  // Menstimulasi jeda loading seolah-olah sedang mengambil data dari database
  await Future.delayed(const Duration(seconds: 1)); 
  
  // Ini data simulasi lokal (kamu bisa ubah angka ini untuk ngetes UI)
  return {
    "total_omzet": 4250000,
    "pesanan_aktif": 12,
    "stok_kritikal": 2,
    "total_piutang": 350000
  };
}