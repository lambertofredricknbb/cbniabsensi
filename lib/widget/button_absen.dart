import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:absensi/widget/camera.dart';
import 'package:absensi/animation/slide_up.dart';

import 'package:camera/camera.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:absensi/widget/camera2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonAbsenWidget extends StatefulWidget {
  @override
  _ButtonAbsenWidgetState createState() => new _ButtonAbsenWidgetState();
}

class _ButtonAbsenWidgetState extends State<ButtonAbsenWidget> {

  //getUser
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userID = preferences.getString("id");
    setState(() {
      getAbsen(userID);
      getWfh(userID);
    });
  }

  //getAbsen
  String dataabsen;
  var content;

  Future<String> getAbsen(String userID) async {

    final response = await http.post(
      "http://202.137.6.90:8084/cbni-intranet/attendance/getabsen",
      body: {
        "emp_id":userID,
      },
    );

    if (response.statusCode == 200){

      content = json.decode(response.body);

      if(content['status'] == 'true'){

        if(content['data'][0]['clock_in'] != null && content['data'][0]['clock_out'] == null ){

          setState(() {
            dataabsen = "1";
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
      setState(() {
        dataabsen = "error";
      });
    }

    return dataabsen;

  }

  //getWfh
  String datawfh;
  var contentwfh;

  Future<String> getWfh(String userID) async {

    final response = await http.post(
      "http://202.137.6.90:8084/cbni-intranet/attendance/getwfh",
      body: {
        "emp_id":userID,
      },
    );

    if (response.statusCode == 200){

      contentwfh = json.decode(response.body);

      if(contentwfh['status'] == 'true'){

          setState(() {
            datawfh = "1";
          });

      }else{

        setState(() {
          datawfh = "0";
        });

      }

    }else{
      setState(() {
        datawfh = "error";
      });
    }

    return datawfh;
  }

  //timer
  String _timeString, _dateString;
  Timer _timer;

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy (E)').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    Intl.defaultLocale = 'id_ID';
    _timeString = _formatDateTime(DateTime.now());
    _dateString = _formatDate(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //camera
  void _showCamera(String title) async {

    final cameras = await availableCameras();
    final camera = cameras.last;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicturePage(camera: camera, title: title,),
      ),
    );

  }

  //camera remote
  void _showCamera2(String title) async {

    final cameras = await availableCameras();
    final camera = cameras.last;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicturePage2(camera: camera, title: title,),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (dataabsen == "0") ?
      SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SlideUp(
              1,
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFF248afd), width: 1),
                ),
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        _timeString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _dateString,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          color: Color(0xFF248afd),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "Off Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "On Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
            SlideUp(
              1.5,
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          color: Color(0xFF248afd),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            onTap: () {
                              _showCamera("Masuk");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text(
                                    "MASUK",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (datawfh == "1") ? Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          color: Color(0xFF248afd),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            onTap: () {
                              _showCamera2("Remote Masuk");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "KELUAR",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (datawfh == "1") ? Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ) :
      (dataabsen == "1") ?
      SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SlideUp(
              1,
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFF248afd), width: 1),
                ),
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        _timeString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _dateString,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "Off Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          color: Color(0xFF248afd),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "On Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
            SlideUp(
              1.5,
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "MASUK",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (datawfh == "1") ? Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          color: Color(0xFF248afd),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            onTap: () {
                              _showCamera("Keluar");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text(
                                    "KELUAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        (datawfh == "1") ? Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          color: Color(0xFF248afd),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            onTap: () {
                              _showCamera2("Remote Keluar");
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ) :
      (dataabsen == "2") ?
      SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SlideUp(
              1,
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFF248afd), width: 1),
                ),
                elevation: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        _timeString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _dateString,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "Off Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "On Duty",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF248afd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
            SlideUp(
              1.5,
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "MASUK",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signInAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "KELUAR",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF248afd), width: 1),
                          ),
                          elevation: 5,
                          child: InkWell(
                            splashColor: Colors.white.withAlpha(50),
                            child: Container(
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.signOutAlt,
                                    color: Color(0xFF248afd),
                                    size: 40,
                                  ),
                                  Text(
                                    "REMOTE",
                                    style: TextStyle(
                                      color: Color(0xFF248afd),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlideUp(
              1,
                Text(
                    "Terjadi Kesalahan"
                )
            ),
            SizedBox(height: 10,),
            SlideUp(
              1,
                FlatButton(
                  color: Color(0xFF248afd),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: getPref,
                  child: Text(
                    "Coba Lagi",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

}