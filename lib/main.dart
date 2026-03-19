import 'package:flutter/material.dart';
  //import 'package:flutter_application_1/screen/Laporankeuangan.dart';
 //import 'package:flutter_application_1/screen/Tambahdatapelanggan.dart';
//import 'package:flutter_application_1/screen/Transaksi.dart';
//import 'package:flutter_application_1/screen/Datapiutang.dart';
 //import 'package:flutter_application_1/screen/Dataproduk.dart';
//import 'package:flutter_application_1/screen/Landingpage.dart';
  //import 'package:flutter_application_1/screen/Transaksi.dart';
 //import 'package:flutter_application_1/screen/Tambahdatabarang.dart';
 //import 'package:flutter_application_1/screen/Laporantransaksi.dart';
//import 'package:flutter_application_1/screen/Datapelanggan.dart';
import 'package:flutter_application_1/screen/Landingpage.dart';
 //import 'package:flutter_application_1/screen/Detailproduk.dart';
//import 'package:flutter_application_1/screen/EditDataproduk.dart';
//import 'package:flutter_application_1/screen/Laporanpenjualan.dart';
//import 'package:flutter_application_1/screen/formpiutang.dart';
import 'package:intl/date_symbol_data_local.dart';
void main () async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      
      ),
 home:   Landingpage(),
     
    
   
    );
    
  }   
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
      
// child: ElevatedButton(
//   onPressed:() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => Laporankeuangan()),
    
//     );
//   },
//     child: Text('Laporan Keuangan'),
// ),
     
//       ),
      
//     );
//   }
// }

