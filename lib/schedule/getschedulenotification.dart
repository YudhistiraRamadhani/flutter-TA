import 'package:flutter_application_1/service/Notivicationservice.dart';
Future<void> fetchAndSchedule() async {
  final response = await http.get(Uri.parse('https://192.168.1.9/api/notifikasi'));
  
  if (response.statusCode == 200) {
    List data = json.decode(response.body);
    for (var item in data) {
      DateTime scheduledTime = DateTime.parse(item['scheduled_at']);
      
      Notivicationservice.scheduleNotification(
        id: item['id'],
        title: item['title'],
        body: item['body'],
        scheduledDate: scheduledTime,
      );
    }
  }
}