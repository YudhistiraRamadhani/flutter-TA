import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // INIT
  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Klik notif: ${details.payload}");
      },
    );

    const channel = AndroidNotificationChannel(
      'daily_channel',
      'Notifikasi Harian',
      description: 'Channel notifikasi',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // LOAD DARI LARAVEL
  static Future<void> loadNotifikasiDariLaravel() async {
    print("MASUK loadNotifikasiDariLaravel");

    try {
      final url = Uri.parse('http://10.214.100.162:8000/api/notifikasi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        print("DATA API: $data");

        // 🔥 HAPUS NOTIF LAMA BIAR TIDAK DOUBLE
        await _notifications.cancelAll();

        for (var item in data) {
          if (item['waktu'] == null) continue;

          List<String> parts = item['waktu'].split(':');

          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);

          print("DARI API: ${item['waktu']}");
          print("JADWAL: $hour:$minute");

          await scheduleDaily(
            id: item['id'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: item['judul'] ?? "Tanpa Judul",
            body: item['pesan'] ?? "Tidak ada pesan",
            hour: hour,
            minute: minute,
          );
        }
      } else {
        print("API ERROR: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR API: $e");
    }
  }

  // SCHEDULE SESUAI JAM DATABASE
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    print("MASUK scheduleDaily");

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 🔥 Kalau sudah lewat → besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("NOW: $now");
    print("SCHEDULE (REAL): $scheduledDate");

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Notifikasi Harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      // 🔥 WAJIB agar berulang tiap hari
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("NOTIF BERHASIL DIJADWALKAN");
  }

  // TEST MANUAL
  static Future<void> testNotif() async {
    await _notifications.show(
      999,
      "TEST",
      "Notif langsung muncul!",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Notifikasi Harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}