import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:absensi/screens/splash.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Absensi 2021",
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(),
    );
  }
}
