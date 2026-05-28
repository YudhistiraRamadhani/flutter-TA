import 'package:flutter/material.dart';
// import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_application_1/service/Notivicationservice.dart';
//import 'screen/Landingpage.dart';
//import 'screen/Landingpagenew.dart';
//import 'screen/Formpenagihan.dart';
//import 'screen/TransaksiBarang.dart';
import 'package:flutter_application_1/screen/Dasboard.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
// WidgetsFlutterBinding.ensureInitialized();
WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

// tz_data.initializeTimeZones();
// tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

// await _requestPermissions();

// await NotificationService.init();


// openAlarmSetting();

// await NotificationService.testNotif();


// await NotificationService.loadNotifikasiDariLaravel();

runApp(const MyApp());
}


// Future<void> _requestPermissions() async {
// if (await Permission.notification.isDenied) {
//  await Permission.notification.request();
// }

// if (await Permission.scheduleExactAlarm.isDenied) {
// await Permission.scheduleExactAlarm.request();
//  }
// }


void openAlarmSetting() {
final intent = AndroidIntent(
 action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
);
intent.launch();
}

class MyApp extends StatelessWidget {
const MyApp({super.key});
 @override
Widget build(BuildContext context) {
 return MaterialApp(
 debugShowCheckedModeBanner: false,
home:  Dasboard(),
);
 }
}