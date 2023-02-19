import 'dart:async';
import 'dart:convert' as convert;

import 'package:absensi/animation/slide_down.dart';
import 'package:absensi/screens/intranet_izin.dart';
import 'package:absensi/widget/chooserequest.dart';
import 'package:flutter/material.dart';
import 'package:absensi/animation/slide_up.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:absensi/screens/list_izin.dart';
import 'package:absensi/screens/list_permohonan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

import 'package:absensi/widget/profil.dart';

import 'package:absensi/screens/login.dart';
import 'package:absensi/screens/intranet.dart';
import 'package:absensi/screens/absensi.dart';
import 'package:absensi/screens/izin.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  //timer
  DateTime _lastTime;
  String _duration;
  Timer _ticker;

  //getUser
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userID = preferences.getString("id");
    setState(() {
      getAbsen(userID);
    });
  }

  //getAbsen
  String dataabsen;
  String clockIn;
  var content;

  //getConfig
  int appVersion = 0;
  int curVersion = 1;

  getAbsen(String userID) async {

    final response = await http.post(
      "http://202.137.6.90:8084/cbni-intranet/attendance/getabsen",
        body: {'emp_id': userID}
    );

    if (response.statusCode == 200){

      content = convert.jsonDecode(response.body);

      if(content['status'] == 'true'){

        if(content['data'][0]['clock_in'] != null && content['data'][0]['clock_out'] == null ){

          setState(() {
            dataabsen = "1";
            DateTime now = DateTime.parse(content['data'][0]['clock_in']);
            final lastPressString = now.toIso8601String();
            _lastTime = lastPressString!=null ? DateTime.parse(lastPressString) : DateTime.now();
            _updateTimer();
            _ticker = Timer.periodic(Duration(seconds:1),(_)=>_updateTimer());
          });

        }else if(content['data'][0]['clock_in'] != null && content['data'][0]['clock_out'] != null ){

          setState(() {
            dataabsen = "2";
          });

        }

      }else{

        setState(() {
          dataabsen = "0";
        });

      }

    }else{
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Berhasil";

  }

  getConfig() async {
    final response = await http
        .get(Uri.encodeFull("http://202.137.6.90:8084/cbni-intranet/attendance/getconfig"),
      headers: {"Accept": "application/json"},
    );

    var content = convert.json.decode(response.body);

    if (response.statusCode == 200){

      final content = convert.json.decode(response.body);

      if(content['status'] == 'true'){

        setState(() {
          appVersion = int.parse(content['data'][5]['value1']);
        });

      }

    }else{
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Berhasil";
  }

  @override
  void initState() {
    super.initState();
    getPref();
    getConfig();
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _updateTimer() {
    final duration = DateTime.now().difference(_lastTime);
    final newDuration = _formatDuration(duration);
    setState(() {
      _duration = newDuration;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  //logout
  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.clear();
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
      backgroundColor: Color(0xFFf0f6ff),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              ProfilWidget(),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: (appVersion != curVersion) ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            child: Card(
                              color: Color(0xFF248afd),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Anda Belum Memperbaharui Aplikasi.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SlideUp(
                            1.5,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Alert(
                                            context: context,
                                            type: AlertType.warning,
                                            title: "Oppss",
                                            desc: "Yakin ingin keluar ?",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Oke",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => logOut(),
                                                color: Colors.red[900],
                                              ),
                                              DialogButton(
                                                child: Text(
                                                  "Batal",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                color: Color(0xFF248afd),
                                              )
                                            ],
                                          ).show();
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.powerOff,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Keluar',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideDown(2,
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                "Versi 7.0",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      (dataabsen == "0") ?
                      Container(
                        width: double.infinity,
                        child: Card(
                          color: Color(0xFF248afd),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Kamu belum absen hari ini.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ) :
                      (dataabsen == "1") ?
                      Container(
                        width: double.infinity,
                        child: Card(
                          color: Color(0xFF248afd),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Waktu Bekerja", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                Text(_duration, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ) :
                      Container(
                        width: double.infinity,
                        child: Card(
                          color: Color(0xFF248afd),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text("Terima kasih untuk pekerjaan hari ini.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                      ),
                          SlideUp(
                            1,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AbsenPage(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.clock,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Absensi'),
                                  ],
                                ),
                                /*Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: Color(0xFF248afd), width: 1),
                                    ),
                                    elevation: 5,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      splashColor: Colors.blue.withAlpha(30),
                                      onTap: () {
                                        print('Card tapped.');
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        child: Icon(
                                          FontAwesomeIcons.userClock,
                                          color: Color(0xFF248afd),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text('Data Absen'),
                                ],
                              ),*/
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              //IzinPage(),
                                              IntranetIzinPage(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.fileAlt,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Izin'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ListIzinPage(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.history,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Data Izin'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SlideUp(
                            1.5,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChooseRequestWidget(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.download,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Permohonan',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                /*
                              Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(color: Color(0xFF248afd), width: 1),
                                    ),
                                    elevation: 5,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      splashColor: Colors.blue.withAlpha(30),
                                      onTap: () {
                                        print('Card tapped.');
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        child: Icon(
                                          FontAwesomeIcons.users,
                                          color: Color(0xFF248afd),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Tim Saya',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),*/
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  IntranetPage(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.globeAsia,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Intranet',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Color(0xFF248afd), width: 1),
                                      ),
                                      elevation: 5,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        splashColor: Colors.blue.withAlpha(30),
                                        onTap: () {
                                          Alert(
                                            context: context,
                                            type: AlertType.warning,
                                            title: "Oppss",
                                            desc: "Yakin ingin keluar ?",
                                            buttons: [
                                              DialogButton(
                                                child: Text(
                                                  "Oke",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => logOut(),
                                                color: Colors.red[900],
                                              ),
                                              DialogButton(
                                                child: Text(
                                                  "Batal",
                                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                                color: Color(0xFF248afd),
                                              )
                                            ],
                                          ).show();
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(
                                            FontAwesomeIcons.powerOff,
                                            color: Color(0xFF248afd),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Keluar',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          SlideDown(2,
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                "Versi 1.0",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
