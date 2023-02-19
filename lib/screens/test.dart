import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => new _TestPageState();
}

class _TestPageState extends State<TestPage> {

  String dataabsen;
  var content;

  Future<String> getAbsen() async {

    final response = await http.post(
      "http://202.137.6.90:8084/test/getabsen.php",
      body: {
        "user_id":"300"
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
      print('Request failed with status: ${response.statusCode}.');
    }

    return dataabsen;

  }

  @override
  void initState() {
    super.initState();
    getAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder<String>(
        future: getAbsen(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if(snapshot.hasData){
            return Center(
              child: Text(dataabsen),
            );
          }else if(snapshot.hasError){
            return Center(
              child: Text("Error"),
            );
          }else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[500]),
              ),
            );
          }
        },
      ),
    );
  }

}