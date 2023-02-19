import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  DateTime _lastTime;
  String _duration;
  Timer _ticker;

  //getUser
  String userID;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  //getAbsen
  String dataabsen;
  String clockIn;
  var content;

  getAbsen() async {

    final response = await http.post(
      "http://202.137.6.90:8084/test/getabsen.php",
      body: {
        "user_id":userID,
      },
    );

    if (response.statusCode == 200){

      content = json.decode(response.body);

      if(content['status'] == 'true'){

        if(content['data'][0]['clock_in'] != null && content['data'][0]['clock_out'] == null ){

          setState(() {
            dataabsen = "1";
            clockIn = content['data'][0]['clock_in'];
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

  @override
  void initState() {
    super.initState();
    getPref();
    getAbsen();
    DateTime now = DateTime.parse("2020-04-02 08:17:19");
    final lastPressString = now.toIso8601String();
    _lastTime = lastPressString!=null ? DateTime.parse(lastPressString) : DateTime.now();
    _updateTimer();
    _ticker = Timer.periodic(Duration(seconds:1),(_)=>_updateTimer());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
        ],
      ),
    );
  }

}