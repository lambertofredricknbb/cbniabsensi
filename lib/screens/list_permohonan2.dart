import 'dart:async';
import 'dart:convert';

import 'package:absensi/animation/slide_up.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:absensi/screens/dashboard.dart';
import 'package:absensi/screens/detail_izin2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:absensi/widget/profil.dart';

class ListPermohonanPage2 extends StatefulWidget {
  @override
  _ListPermohonanPage2State createState() => _ListPermohonanPage2State();
}

class _ListPermohonanPage2State extends State<ListPermohonanPage2> {

  List data;
  String status;
  TextEditingController controller = new TextEditingController();
  String filter;

  //getUser
  String userID;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString("id");
    });
  }

  Future<String> getData() async {
    await getPref();

    var response = await http.post(
      Uri.encodeFull("http://202.137.6.90:8084/test/getpermissions3.php"),
      headers: {
        "Accept": "application/json"
      },
      body:{
        "user_id":userID
      },
    );

    if(response.statusCode==200){
      this.setState(() {
        data = json.decode(response.body)["data"];
        status = "1";
      });
    }else{
      print("Error");
      this.setState(() {
        status = "0";
      });
    }

    return "Success!";
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy HH:mm:ss').format(dateTime);
  }

  @override
  void initState(){
    super.initState();
    this.getData();
    Intl.defaultLocale = 'id_ID';
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf0f6ff),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  elevation: 10,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: (status == "1") ?
                      Column(
                        children: <Widget>[
                          TextField(
                            decoration: new InputDecoration(
                                isDense: true,
                                labelText: "Cari Permohonan",
                                suffixIcon: Icon(FontAwesomeIcons.search, color: Color(0xFF248afd), size: 15,),
                            ),
                            controller: controller,
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ListView.builder(
                              itemCount: data == null ? 0 : data.length,
                              itemBuilder: (BuildContext context, int index){
                                return
                                  filter == null || filter == ""
                                      ? InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailIzinPage2(data[index]["id"])),
                                      );
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: (data[index]["is_active"] == "0")
                                            ? Colors.red
                                            : (data[index]["is_pending"] == "0")
                                            ? Color(0xFF248afd)
                                            : (data[index]["is_pending"] == "1")
                                            ? Colors.green
                                            : Colors.red, width: 1),
                                      ),
                                      elevation: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(data[index]["employee_name"], style: TextStyle(fontWeight: FontWeight.bold),),
                                                Text("Remote Absen", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),),
                                                Text(_formatDate(DateTime.parse(data[index]["clock_in"]))),
                                              ],
                                            ),
                                            (data[index]["is_active"] == "0")
                                                ? Text("Canceled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                                                : (data[index]["is_pending"] == "0")
                                                ? Text("Open", style: TextStyle(color: Color(0xFF248afd), fontWeight: FontWeight.bold, fontSize: 15),)
                                                : (data[index]["is_pending"] == "1")
                                                ? Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),)
                                                : Text("Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                      : data[index]["employee_name"].toLowerCase().contains(filter.toLowerCase())
                                      ? InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: Colors.blue.withAlpha(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DetailIzinPage2(data[index]["id"])),
                                      );
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: (data[index]["is_active"] == "0")
                                              ? Colors.red
                                              : (data[index]["is_pending"] == "0")
                                              ? Color(0xFF248afd)
                                              : (data[index]["is_pending"] == "1")
                                              ? Colors.green
                                              : Colors.red, width: 1),
                                        ),
                                        elevation: 2,
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(data[index]["employee_name"], style: TextStyle(fontWeight: FontWeight.bold),),
                                                  Text("Remote Absen", style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),),
                                                  Text(_formatDate(DateTime.parse(data[index]["clock_in"]))),
                                                ],
                                              ),
                                              (data[index]["is_active"] == "0")
                                                  ? Text("Canceled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "0")
                                                  ? Text("Open", style: TextStyle(color: Color(0xFF248afd), fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : (data[index]["is_pending"] == "1")
                                                  ? Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),)
                                                  : Text("Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),),
                                            ],
                                          ),
                                        )
                                    ),
                                  )
                                      : Container();
                              },
                            ),
                          ),
                        ],
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
                                  onPressed: getData,
                                  child: Text(
                                    "Coba Lagi",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}