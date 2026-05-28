Future<void> loadNotifikasi() async {
  final data = await NotifikasiService.fetchNotifikasi();

  for (var item in data) {
    DateTime waktu = DateTime.parse(item['waktu']);

    await NotificationService.scheduleNotification(
      title: item['judul'],
      body: item['pesan'],
      scheduledDate: waktu,
    );
  }
}