import 'package:flutter/material.dart';
import 'dart:async';

import 'package:absensi/screens/login.dart';

import 'package:absensi/animation/slide_down.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {

  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF248afd),
      body: Center(
        child: SlideDown(
          1,
          Image.asset("assets/images/cbn.png", fit: BoxFit.contain,),
        ),
      ),
    );
  }

}